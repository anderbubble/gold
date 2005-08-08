
//counter to track how many search condition rows we're displaying
var optionCount = 1;


function changeOptions(evt){
    var source = getElement(evt);
    if(source) {
      
        var attribute = document.getElementById(source.id);
        var value = attribute.value; 

        var comboNumber = parseInt(attribute.name, 10);
        if((value == "") && (optionCount > 1) && (comboNumber != optionCount)){
            var optionrow = document.getElementById("option" + new String(comboNumber));
            var parent = document.getElementById("options");
            parent.removeChild(optionrow);
        }else if((comboNumber == optionCount) && (value != ""))
            newOptionRow();
    }else{
        alert("Error finding event's html element.");
    }
}



//this function creates a new row under the options header
function newOptionRow(){
    optionCount = optionCount +1;
    var insertPoint = document.getElementById("options");
    var newRow = document.createElement("div");
    var rowName = new String(optionCount);
    rowName = "option" + rowName;
    newRow.setAttribute("id", rowName);
    setClass(newRow, "optionrow");

    newRow.appendChild(createOptionInput("Name"));
    newRow.appendChild(createOptionInput("Value"));

    insertPoint.appendChild(newRow);
}


//creates the value input box
function createOptionInput(type){
    //1optionValueDiv
    var newDiv = document.createElement("div");
    var rowName = new String(optionCount);
    rowName = rowName + "option" +type +"Div";
    newDiv.setAttribute("id", rowName);
    setClass(newDiv, "option" + type);



    var newInput = document.createElement("input");
    var name = new String(optionCount);
    name = name + "option" + type;
    newInput.setAttribute("name",name);
    newInput.setAttribute("id",name);
    if(type == "Name"){
        setonchangeOption(newInput);
    }
    newDiv.appendChild(newInput)
    return newDiv;
}


function setonchangeOption(elem){
    if(navigator.org == "microsoft") {
        elem.attachEvent("onchange", changeOptions);
    }
    else {
        elem.addEventListener("change", changeOptions, false);
    }
}


function setOptionsList(){
    var optionNames="";
    var optionValues="";

    //optionNames & optionValues:
    for(var i = 1; i <= optionCount; i++){
        if(document.getElementById(new String(i) + "optionName"))
            optionNames = optionNames + "," + document.getElementById(new String(i) + "optionName").value;
        if(document.getElementById(new String(i) + "optionValue"))
            optionValues = optionValues + "," + document.getElementById(new String(i) + "optionValue").value;
    }
    document.getElementById("optionName").value = optionNames;
    document.getElementById("optionValue").value = optionValues;
}
