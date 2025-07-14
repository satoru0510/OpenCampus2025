const fs = require('fs');
const data = JSON.parse(fs.readFileSync("config.json"));
const depth = data["depth"];

function draw(){
  var gates = new Array(depth);
  for(var i=0; i < depth; i++){
    gates[i] = document.getElementById(`gate${i}`).value;
  }
  let jsonString = makeJsonString("draw", gates);
  let jsonData = JSON.parse(jsonString);
  sendMessageToJulia(jsonData);
}

function reset(){
  for(var i=0; i < depth; i++){
    document.getElementById(`gate${i}`).options[0].selected = true;
  }
  draw();
}

function makeJsonString(cmd, gates){
  // let jsonString = `{"g1":"${g1}", "g2":"${g2}", "g3":"${g3}"}`;
  let jsonString = `{"cmd":"${cmd}",`;
  for(var i=0; i < depth; i++){
    jsonString = jsonString + `"g${i}":"${gates[i]}"`;
    if(i != depth-1){
      jsonString = jsonString + ", "
    }
  }
  jsonString = jsonString + "}";

  return jsonString;
}

function setImage(file_path){
  let imageElement = document.getElementById("circuit_image");
  imageElement.src = file_path;
}

function setPlot(file_path){
  let imageElement = document.getElementById("plot_image");
  imageElement.src = file_path;
}

function setLabel(str){
  let txtelem = document.getElementById("lab");
  txtelem.innerHTML = str
}

function setResult(str){
  let txtelem = document.getElementById("result");
  txtelem.innerHTML = str
}

function setProgress(path){
  document.getElementById("progress").src = path
}

function run(){
  setProgress("../assets/load-30_256.gif")
  setResult("")
  setLabel("")
  setPlot("")
  var gates = new Array(depth);
  for(var i=0; i < depth; i++){
    gates[i] = document.getElementById(`gate${i}`).value;
  }
  let jsonString = makeJsonString("run", gates);
  let jsonData = JSON.parse(jsonString);
  sendMessageToJulia(jsonData);
}

// setInterval(draw, 100);
