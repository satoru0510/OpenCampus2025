for(var i=0; i < depth; i++){
    let s = document.getElementById("selects");
    s.insertAdjacentHTML("beforeend", `
        <select id="gate${i}" size="1" onchange="draw();">
            <option selected></option>
            <option>Rx</option>
            <option>Ry</option>
            <option>Rz</option>
            <option>CNOT</option>
            <option>CZ</option>
            <option>SWAP</option>
        </select>
    `)
}