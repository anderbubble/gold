            
//creates the attributes select box for all 3 of these: modify, query fields section & condition section
function createAttributeSelect(forCondition, modifying){
    var newSelect = document.createElement("select");
    var name;
    var newDiv = document.createElement("div");
    if(forCondition){
        name = new String(conditionCount);
        name = name + "conditionName";
        //newSelect.setAttribute("onchange", "changeConditions(this, this[selectedIndex].text, false);");
        setonchangeCondition(newSelect);
        setClass(newDiv, "conditionName");
        //newDiv.setAttribute("class", "conditionName");
        newDiv.setAttribute("id", name);
    }
    else{
        name = new String(fieldCount);
        name = name + "fieldName";
        setonchangeField(newSelect);
        setClass(newDiv, "fieldName");
    }
    newSelect.setAttribute("name",name);
    newSelect.setAttribute("id",name);
    newDiv.setAttribute("id", name + "Div");

    var optionText;
    var newOption;
    for(var i = 0; i < attributes.length; i++){
        newOption = document.createElement("option");
        newOption.setAttribute("value", attributes[i]);
        optionText = document.createTextNode(attributes[i]);
        newOption.appendChild(optionText);
        newSelect.appendChild(newOption);
    }

    newDiv.appendChild(newSelect);
    return newDiv;
}


function setonchangeField(elem){
    if(navigator.org == "microsoft") {
        elem.attachEvent("onchange", setOperators);
    }
    else {
        elem.addEventListener("change", setOperators, false);
    }
}



function setonchangeCondition(elem){
    if(navigator.org == "microsoft") {
        elem.attachEvent("onchange", changeConditions);
    }
    else {
        elem.addEventListener("change", changeConditions, true);
    }
}

function setClass(elem, className){
    if(navigator.org == "microsoft") {
        elem.setAttribute("className", className); 
    }
    else {
        elem.setAttribute("class", className); 
    }
}


function getElement(evt) {
    evt = (evt) ? evt : ((window.event) ? window.event : "");

    if (evt) {
        var elem;
        if (evt.target) {
            elem = (evt.target.nodeType == 3) ? evt.target.parentNode : evt.target;
        }
        else {
            elem = evt.srcElement;//document.getElementById(evt.id);//
        }
        return elem;
    }
    else {
        alert("No event received.")
    }
} 



function setValue(id, value){
    //alert("id=" +id + ", value=" + value);
    var element = document.getElementById(id);

    if(!document.getElementById(id)){
        element = document.getElementById(id+"Yes");
        if(!document.getElementById(id+"Yes")) 
            return;
    }

    tagName = element.tagName;

    switch(tagName){
        case "INPUT":
            type = element.type;
            switch(type){
                case "text":
                    element.value = value;
                    break; 
                case "radio":
                    if(value=='True')
                        document.getElementById(id + "Yes").checked = "true";
                    else 
                        document.getElementById(id + "No").checked = "true";                        
                    break; 
            }
            break;
        case "SELECT":
            //loop thru options and deselect the default one (if there was one):
            for(var i = 0; i != element.options.length; i++){
                element.options[i].selected = "false"
            }
            //loop thru options and select the matching one:
            for(var i = 0; i != element.options.length; i++){
                //alert("element.options[i]: " + element.options[i])
                if(element.options[i].value == value) 
                    element.options[i].selected = "true"
            }

    }
}



function initCombo(combo, initValue){
    for(i=0; i != combo.length; i++) {
        if(combo[i].value == initValue) {
            combo[i].selected = true;
            break;
        }
    }
}




/*
Functions used on the complex object's create and modify pages:
Create Account &
Modify Project (so far)
*/

        //the purpose of this function is to:
        //  this method only called from modify_complex_object_javascript when loading existing info
        //  1)make visible the users/projects/machines radios that are associated with
        //    the loaded project and fills in the appropriate radio for if it is active or not
        //  2)select these users/projects/machines in the select combo box
        //type should be either "User", "Project", or "Machine"
        function setMembersValue(object, type, name, active, allowDescOrAdmin){
            //alert("object="+object+", type=" + type + ", name=" + name + ", active=" + active);
            //#1, select this one in the combo select box:
            var selectbox = document.getElementById(type);
            
            var found = false;
            for(i = 0; i != selectbox.options.length; i++) {
                if(selectbox.options[i].value == name){
                    selectbox.options[i].selected = true;
                    found = true;
                }
            }
            if(!found && document.getElementById(type+name)) document.getElementById(type+name).checked=true;
            if(found && document.getElementById(type+"SPECIFIC")) document.getElementById(type+"SPECIFIC").checked=true;
            
            //#2, make the lines with radio buttons of this user/project/machine visible
            //make the div's display be block (starts out as "none")
            //alert(name+type+"ActivationRow");
            document.getElementById(name+type+"ActivationRow").style.display = "block";
            
            //if active is 'f' change the radio that's selected:
            
            if(active == 'False')
                document.getElementById(name+type+"Active").checked = 'true';

            if(allowDescOrAdmin && allowDescOrAdmin == 'True'){
                if(document.getElementById(name+type+"AllowDesc"))
                    document.getElementById(name+type+"AllowDesc").checked = 'true';

                if(document.getElementById(name+type+"Admin"))
                    document.getElementById(name+type+"Admin").checked = 'true';
            }
            //last, set the hidden input's that store what is selected:
            setMembers(type, object);        
        }
        
        
        
        //type should be either "User", "Project", or "Machine" 
        function changeActivationTable(type){
            //for each option, if it is selected make that activation row visible,
            //otherwise make it invisible
            //alert("type: "+ type);
            var selectbox = document.getElementById(type);
            
            for(i = 0; i != selectbox.options.length; i++) {
              if(selectbox.options[i].value != ""){
                if(selectbox.options[i].selected == true)
                    document.getElementById(selectbox.options[i].value+type+"ActivationRow").style.display = "block";
                else if(document.getElementById(selectbox.options[i].value+type+"ActivationRow").style.display == "block")
                    document.getElementById(selectbox.options[i].value+type+"ActivationRow").style.display = "none";
              }
            }

            //Check the checkboxes too if they are there:
            var specials = new Array("ANY", "MEMBERS");
            for(i = 0; i != specials.length; i++) {
                if(document.getElementById(new String(type + specials[i]))){
                    //alert(specials[i]+type+"ActivationRow");
                    if(document.getElementById(new String(type + specials[i])).checked)
                        document.getElementById(specials[i]+type+"ActivationRow").style.display = "block";
                    else if(document.getElementById(specials[i]+type+"ActivationRow").style.display == "block")
                        document.getElementById(specials[i]+type+"ActivationRow").style.display = "none";
                }
            }
        }
        
        
        //object is either Project or Account. type is either User, Project, or Machine
        function setMembers(type, object){
            //1. get hidden input that stores the array:
            //hidden ones named "Project[thing]" and "Project[thing]Active"
            //alert(type +", " + object);
            var nameSelect = document.getElementById(type);
            var hiddenElementNames = document.getElementById(object+nameSelect.name);
            var hiddenElementActives;
            
            if(document.getElementById(object+nameSelect.name+"Active")) hiddenElementActives = document.getElementById(object+nameSelect.name+"Active");
            if(document.getElementById(object+nameSelect.name+"Access")) hiddenElementActives = document.getElementById(object+nameSelect.name+"Access");
            
            var hiddenElementAllowDesc;
            var usingAllowDesc = false;
            var hiddenElementAdmin;
            var usingAdmin = false;
            if(document.getElementById(object+nameSelect.name+"AllowDesc")){
                hiddenElementAllowDesc =  document.getElementById(object+nameSelect.name+"AllowDesc");
                usingAllowDesc = true;
            }
            if(document.getElementById(object+nameSelect.name+"Admin")){
                hiddenElementAdmin =  document.getElementById(object+nameSelect.name+"Admin");
                usingAdmin = true;
            }
            
            //reset the values
            hiddenElementNames.value = "";
            hiddenElementActives.value = "";
            if(usingAllowDesc) hiddenElementAllowDesc.value = "";
            if(usingAdmin) hiddenElementAdmin.value = "";
            //2. loop thru those selected on the list and add to arrays
            
            for(var i = 0; i != nameSelect.options.length; i++){
                if(nameSelect.options[i].selected){
                    hiddenElementNames.value   = hiddenElementNames.value    + nameSelect.options[i].value+ ",";
                    hiddenElementActives.value = hiddenElementActives.value  + getActiveValue(nameSelect.options[i].value, type)+ ",";
                    if(usingAllowDesc) hiddenElementAllowDesc.value = hiddenElementAllowDesc.value  + getAllowDescValue(nameSelect.options[i].value, type)+ ",";
                    if(usingAdmin) hiddenElementAdmin.value = hiddenElementAdmin.value  + getAdminValue(nameSelect.options[i].value, type)+ ",";
                }
            }

            //Check the checkboxes too if they are there:
            var specials = new Array("ANY", "MEMBERS");
            for(i = 0; i != specials.length; i++) {
                if(document.getElementById(new String(type + specials[i]))){
                    if(document.getElementById(new String(type + specials[i])).checked){
                        hiddenElementNames.value   = hiddenElementNames.value    + specials[i] + ",";
                        hiddenElementActives.value = hiddenElementActives.value  + getActiveValue(specials[i], type)+ ",";
                        if(usingAllowDesc) hiddenElementAllowDesc.value = hiddenElementAllowDesc.value  + getAllowDescValue(specials[i], type)+ ",";
                        if(usingAdmin) hiddenElementAdmin.value = hiddenElementAdmin.value  + getAdminValue(specials[i], type)+ ",";
                    }
                }
            }

            //alert("1: "+hiddenElementNames.value);
            //alert("2: "+hiddenElementActives.value);
            //if(usingAllowDesc) alert("3: "+hiddenElementAllowDesc.value);
        }
        
        /*old-not used anymore
        function setProjectMembers(object, type){
            //1. get hidden input that stores the array:
            //hidden ones named "Project[thing]" and "Project[thing]Active"
            //alert(type);
            var nameSelect = document.getElementById(type);
            var hiddenElementNames = document.getElementById(object+nameSelect.name);
            var hiddenElementActives = document.getElementById(object+nameSelect.name+"Active");
            
            
            //reset the values
            hiddenElementNames.value = "";
            hiddenElementActives.value = "";
            //2. loop thru those selected on the list and add to arrays
            
            for(var i = 0; i != nameSelect.options.length; i++){
                if(nameSelect.options[i].selected){
                    hiddenElementNames.value   = hiddenElementNames.value    + nameSelect.options[i].value+ ",";
                    hiddenElementActives.value = hiddenElementActives.value  + getActiveValue(nameSelect.options[i].value, nameSelect.name)+ ",";
                }
            }
            //alert("!: "+hiddenElementNames.value);
            //alert("#: "+hiddenElementActives.value);
        }
        */


        function getActiveValue(who, type){
            //alert("getActive: " + who+ type);
            if(document.getElementById(who+type+"Active").checked)
                return "False";
            else
                return "True";
        }
        
        function getAllowDescValue(who, type){
            if(document.getElementById(who+type+"AllowDesc").checked)
                return "True";
            else
                return "False";
        }  
        function getAdminValue(who, type){
            if(document.getElementById(who+type+"Admin").checked)
                return "True";
            else
                return "False";
        }        


        function toggleSelect(selectName){
            if(document.getElementById(new String(selectName + 'SPECIFIC')).checked )
                document.getElementById(selectName).disabled = false;
            else
                document.getElementById(selectName).disabled = true;
        }




//new window function copied from EUS application 
function newWindow(windowName, url, winWidth, maxHeight) {
    var winHeight = ((screen.availHeight-100) > maxHeight) ? maxHeight : screen.availHeight-100;

    var nw=window.open(url, windowName, "scrollbars,status,resizable,width=" + winWidth + ",height=" + winHeight);
    if(!nw) return null;

    if(parseInt(navigator.appVersion) >= 4) {
        var nwLeft = parseInt((screen.availWidth - winWidth) / 2);
        var nwTop = parseInt((screen.availHeight - winHeight) / 2);

        if(parseInt(navigator.appVersion) >= 4) {
            nw.moveTo(nwLeft, nwTop-50);
        }
    }
    nw.focus();

    return nw;
}