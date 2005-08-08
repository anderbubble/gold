var operators = new Array();
operators[0] = new Array("matches","Match");
operators[1] = new Array(">","GT");
operators[2] = new Array("<","LT");
operators[3] = new Array(">=","GE");
operators[4] = new Array("<=","LE");
operators[5] = new Array("==","EQ");
//operators[6] = new Array("!=","NE");<- added in setOperators function, not here anymore


function modifyObject(instance){
    submitForm(instance);
}


function submitForm(instance){
    var action = document.loadForm.myaction.value;
    var counter = 0;
    var countSelected = 0;
    if(action == "Modify"){    
        var keyValues = instance.split(",");
        setCondition(keyValues, 0, 1);
    }else{
        if(checkBoxIds.length != 0) {
            for(var i = 0; i != checkBoxIds.length; i++){
                var checkbox = document.getElementById(checkBoxIds[i]);
                if(document.getElementById(checkBoxIds[i]) && checkbox.checked == true){
                    countSelected++;
                }
            }
            for(var i = 0; i != checkBoxIds.length; i++){
                var checkbox = document.getElementById(checkBoxIds[i]);
                if(document.getElementById(checkBoxIds[i]) && checkbox.checked == true){
                    counter++;
                    //alert("setting: " + primaryKeyValues[i]);
                    var keyValues = primaryKeyValues[i].split(",");
                    setCondition(keyValues, counter, countSelected);
                }
            }
        }
    }

    //alert("conditionNames: " + document.loadForm.conditionNames.value);
    //alert("conditionValues: " + document.loadForm.conditionValues.value);
    //alert("conjunctions: " + document.loadForm.conjunctions.value);
    //alert("groups: " + document.loadForm.groups.value);
    if(action == "Modify"){
        var myobject = new String(document.loadForm.myobject.value).toLowerCase();
        document.loadForm.target = "action";

        if(myobject == "project" || myobject == "account" || myobject == "role")
            document.loadForm.action = "modify_" + myobject + ".jsp";
        else document.loadForm.action = "modify_template.jsp";
        document.loadForm.submit();
    }else if(counter == 0){
        alert("Select the " +new String(document.loadForm.myobject.value).toLowerCase() +"(s) you would like to " + new String(action).toLowerCase());
    }else{
        document.loadForm.target = "results";
        document.loadForm.action = "results.jsp";
        document.loadForm.submit();
    }
}



function setCondition(keyValues, counter, countSelected){
    document.loadForm.conditionNames.value;
    document.loadForm.conditionValues.value;
    document.loadForm.conjunctions.value;
    document.loadForm.groups.value;


    var conditionNames = "";
    var conditionValues = "";
    var conjunctions = "";
    var groups = "";

    var keys = primaryKeyNames.split(",");
    if(keys[keys.length -1] == "") 
        keys.pop();

    if(keyValues[keyValues.length -1] == "") 
        keyValues.pop();

    //now set: conditionNames, conditionValues, conditionOperators, conjunctions, groups
    //need to construct this syntax: ('type' = 'resource' and 'name' = 'processors') or (...) or (...)
    for(var j = 0; j != keys.length; j++){
        var groupVal = 0;
        //set the keyname & value:
        conditionNames = conditionNames + keys[j] + ",";
        conditionValues = conditionValues + keyValues[j] + ",";
        //alert("name: " + keys[j] + ", value " + keyValues[j]);
        if((j == 0) && (keys.length > 1)){
            //set the paren value for the first one when there's more than one pkey & this is the first one:
            //groups = groups + "1,";
            groupVal = 1;
            //except on the very first condition, set the first pkey's conjunction to or
            if(counter > 1) conjunctions = conjunctions + "or,";
            else conjunctions =  conjunctions + ",";
        }else if((j == keys.length-1) && (keys.length > 1)){
            //set the paren value for the first one when there's more than one pkey & this is the last one:
            //groups = groups + "-1,";
            groupVal = -1;
            //every pkey after the first one get's an 'and' as the conjunction
            conjunctions = conjunctions + "and,";
        }else if (keys.length > 1){
            //groups = groups + "0,";
            conjunctions = conjunctions + "and,";
        }else{
            //we need to add to the group in both cases:
            //if there's only 1 pk, then we also need to add an or to the conjunction if
            //its not the first one
            //alert("counter: " + counter + " conditionNames: " + conditionNames +" conditionValues: " + conditionValues);
            if(counter > 1)
                conjunctions = conjunctions + "or,";
            else
                conjunctions = conjunctions + ",";
        }
        //if this is the first one selected, it needs 1 added to the group
        //if the last -1 added).
        if(counter == 1)
            groupVal = groupVal + 1;
        if(counter == countSelected)
            groupVal = groupVal - 1;

        groups = groups + groupVal.toString() + ",";

        //alert("counter: " + counter + " conditionNames: " + conditionNames +" conditionValues: " + conditionValues + " conjunctions: " + conjunctions + " groups: "+ groups);
    }

    document.loadForm.conditionNames.value  += conditionNames;
    document.loadForm.conditionValues.value += conditionValues;
    document.loadForm.conjunctions.value += conjunctions;
    document.loadForm.groups.value += groups;
}

function setOperators(dataTypeIndex){
    var combo = document.searchForm.conditionOperators;
    //first clear out any previous values, except for the first "select operator bla bla" one
    for(i=combo.length-1; i >= 1; i--) 
        combo[i] = null;
    
    if(dataTypeIndex < 0) return;

    //now set the valid operators based on the datatype
    //operators is 7 long, we use on or more of these:

    if(dataTypes[dataTypeIndex] == 'String' || dataTypes[dataTypeIndex] == 'AutoGen'){
        //for string, use first and bottom one.
        combo[1] = new Option(operators[0][0], operators[0][1]);
        combo[2] = new Option(operators[operators.length-1][0], operators[operators.length-1][1]);
        //default select the "matches" one:
        combo[1].selected = "true";
    }else if(dataTypes[dataTypeIndex] == 'Boolean'){
        //for bools only use the last one
        combo[1] = new Option(operators[operators.length-1][0], operators[operators.length-1][1]);
        //default select the "==" one:
        combo[1].selected = "true";
    }else {
        //for the rest of the datatypes, use all but the top, "matches" one
        for(i=1; i < operators.length; i++) 
            combo[i] = new Option(operators[i][0], operators[i][1]);
        //default select the "==" one:
        combo[i-1].selected = "true";
    }

    //every type gets "!="
    combo[combo.length]= new Option("!=", "NE");
}


