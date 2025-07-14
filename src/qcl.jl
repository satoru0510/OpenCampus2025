using Yao, Plots, LinearAlgebra
import MultivariateStats, MLDatasets, Optim, StatsBase

trainset = MLDatasets.MNIST(split=:train)
x_train, y_train = trainset[:]
idx_01 = findall(y_train) do x
    x == 0 || x == 1
end

pca = MultivariateStats.fit(MultivariateStats.PCA, reshape(x_train[:,:,idx_01[1:1000]], 28*28, 1000); maxoutdim=nq)
xc_train = MultivariateStats.predict(pca, reshape(x_train[:,:,idx_01[1:1000]], 28*28, 1000))
for i in 1:1000
    normalize!(view(xc_train, :, i))
end
xc_train *= 2π

function U(x)
    chain(nq,
        repeat(H),
        [put(i => Rz(x[i])) for i in 1:nq]...,
        [put((i,i+1) => rot(kron(Z,Z), x[i])) for i in 1:nq-1]...,
    )
end

function ansatz(x, θ)
    cir = dispatch(circuit, θ)
    chain(nq, U(x), cir)
end

function predict(x, θ)
    obs = sum(kron(nq, i=>Z) for i in 1:nq)
    st = zero_state(nq) |> ansatz(x, θ)
    real(expect(obs, st) / 2 + 0.5)
end

function loss(x, θ, y)
    ret = 0.0
    for i in 1:length(x)
        p = predict(x[i], θ)
        ret += (p - y[i])^2
    end
    ret
end

function grad_obs(x, θ)
    obs = sum(kron(nq, i=>Z) for i in 1:nq)
    init = zero_state(nq)
    expect'(obs, init=>ansatz(x, θ))[2][2nq:2nq-1+nparams]
end

function grad_loss(x, θ, y)
    len = length(x)
    ret = zeros(length(θ))
    for i in 1:length(x)
        p = predict(x[i], θ)
        go = grad_obs(x[i], θ)
        ret += (p - y[i]) * go
    end
    ret
end

function callback(arg)
    # θ = arg[end].metadata["x"]
    # cf = confusion([xc_train[:,i] for i in 1:900], θ, y_train[idx_01[1:900]])
    # println(cf)
    # println(arg[end].value)
    # flush(stdout)
    # IJulia.clear_output(true)
    # history = map(x -> x.value, arg)
    # plt = Plots.plot(history; legend=:none)
    # display(plt)
    println(length(arg), ": ", arg[end].value)
    false
end

function run_qcl(;callback=callback)
    trainset_idx = StatsBase.sample(1:900, 300; replace=false)
    option = Optim.Options(;store_trace=true, g_abstol=1e-3, extended_trace=true, time_limit=30, callback)
    Optim.optimize(
        θ -> loss([view(xc_train, :, i) for i in trainset_idx], θ, view(y_train, idx_01[trainset_idx])),
        θ -> grad_loss([xc_train[:,i] for i in trainset_idx], θ, y_train[idx_01[trainset_idx]]),
        # θ -> grad_loss_sample([xc_train[:,i] for i in trainset_idx], θ, view(y_train, idx_01[trainset_idx]), 50),
        rand(nparams),
        # Optim.LBFGS(),
        option;
        inplace = false,
    )
end

function accuracy(x, θ, y)
    len = length(x)
    fcount = 0
    for i in 1:len
        p = predict(x[i], θ) |> round
        if p != y[i]
            fcount += 1
        end
    end
    1 - fcount / len
end