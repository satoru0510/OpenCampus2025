using Electron

using Plots, Images, Dates, Yao, JSON

dict = JSON.parsefile("config.json")
const nq = dict["nqubits"]
const depth = dict["depth"]
const nshots = dict["nshots"]
CircuitStyles.barrier_for_chain[] = true

function str_to_cir(str)
    str == "none" && return chain(nq)
    str == "Rx" && return chain(nq, [put(i => Rx(0)) for i in 1:nq])
    str == "Ry" && return chain(nq, [put(i => Ry(0)) for i in 1:nq])
    str == "Rz" && return chain(nq, [put(i => Rz(0)) for i in 1:nq])
    str == "CNOT" && return chain(nq, [cnot(i,i+1) for i in 1 : nq-1]..., )
    str == "CZ" && return chain(nq, [cz(i,i+1) for i in 1 : nq-1]...,)
    str == "SWAP" && return chain(nq, [swap(i,i+1) for i in 1 : nq-1]..., )
    error()
end

function generate_image(cir)
    rm("../assets/tmp/",recursive=true)
	mkdir("../assets/tmp")
    filename = string(Dates.format(now(), "yyyymmddHHMMSS"),"_circuit.svg")
    vizcircuit(cir; filename="../assets/tmp/$filename")
	return filename
end

function generate_plot(data)
    Plots.plot(fontfamily="IPAMincho", size=(450,300))
    plot!(data; legend=:none, xlabel="最適化の繰り返し回数", ylabel="誤差")
    rm("../assets/tmp2/",recursive=true)
	mkdir("../assets/tmp2")
    filename = string(Dates.format(now(), "yyyymmddHHMMSS"),"_plot.svg")
    savefig("../assets/tmp2/$filename")
	return filename
end

export run_demo
function run_demo()
    app = Application()

    main_html_uri = string("file:///", replace(joinpath(@__DIR__, "main.html"), '\\' => '/'))

    win = Window(app, URI(main_html_uri))

    ElectronAPI.setBounds(win, Dict("width"=>1200, "height"=>600))

    ch = msgchannel(win)

    function callback(arg)
        len = min(length(arg), 15)
        str = ""
        for i in 1:len
            str = string(length(arg)-i+1, ":&emsp;", arg[end-i+1].value, "<br>") * str
        end
        # str = string(length(arg), ": ", arg[end].value, "<br>hello")
        run(win,"setLabel(\"$(str)\");")
        false
    end

    while true
        try 
            global request = take!(ch)
            println("request: $(request)")
        catch 
            println("channel closed")
            break
        end

        global circuit = chain(nq)

        for i in 0:depth-1
            global circuit
            push!(circuit, str_to_cir(request["g$i"]))
        end

        if request["cmd"] == "draw"
            filename = generate_image(circuit)
            run(win,"setImage(\"../assets/tmp/$(filename)\");")
        elseif request["cmd"] == "run"
            # st = zero_state(nq)
            # apply!(st, circuit)
            # res = measure(st; nshots) .|> Int
            # println(res)
            # fn = generate_plot(res)
            # run(win,"setPlot(\"../assets/tmp2/$(fn)\");")
            global nparams = circuit |> nparameters
            res = run_qcl(;callback)
            testset_idx = 901:1000
            acc = accuracy([xc_train[:,i] for i in testset_idx], res.minimizer, y_train[idx_01[testset_idx]])
            res_str = "100枚の画像のうち、$(round(Int, acc*100))枚の画像を正しく判別できました。<br>"
            res_str *= "実行時間：$(res.time_run)秒<br>"
            run(win,"setResult(\"$(res_str)\");")
            data = [res.trace[i].value for i in 1:length(res.trace)]
            fn_plot = generate_plot(data)
            run(win,"setPlot(\"../assets/tmp2/$(fn_plot)\");")
            GC.gc()
            run(win,"setProgress(\"\");")
        end

        println("regenerate window")
    end
end
include("qcl.jl")
println("initialization completed")