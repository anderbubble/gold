        //By: Zoe Johns
        // javascript file for functions performed on fields section on modify and query pages

        //counter to track how many field rows we're displaying
        var fieldCount = 1;


        //this function sets the valid operators for the selected
        //field to display based on that field's type
        function setOperators(evt){//attribute, value, modifying){
            //have to use event object to get refrence to object that event happened to:
            var source = getElement(evt);
            if(source) {
                var attribute = document.getElementById(source.id);
                var value = attribute[attribute.selectedIndex].text;  //this[selectedIndex].text
                modifying = true;
                if(source.parentNode.parentNode.className == "fieldqueryrow")
                    modifying = false;
                var comboNumber = parseInt(attribute.name, 10);
                var type;
                for(var i = 0; i < attributes.length; i++){
                    if(attributes[i] == value){
                        type = dataTypes[i];
                    }
                }
                var operatorCombo = document.getElementById(new String(comboNumber) + "fieldOperator");
                if(modifying){
                    //first clear out old values after = since every type gets those:
                    for(i=operatorCombo.length; i > 1; i--) {
                        operatorCombo[i] = null;
                    } 
                    if((type == "Integer") || (type == "Currency")){
                        for(var i = 2; i <= 3; i++)
                           operatorCombo[i] = new Option(operators[i][0], operators[i][1]);
                    }
                    setFieldValueInput(comboNumber, value);
                }else{
                    var count=6;
                    //first clear out old values after max, min, sum, & avg since every type gets those:
                    for(i=operatorCombo.length; i > 4; i--) {
                        operatorCombo[i] = null;
                    } 
                    if((type == "TimeStamp") || (type == "Integer")  || (type == "Currency")){
                        if(type == "Integer" || (type == "Currency")) count = 8;
                        for(var i = 5; i <= count; i++)
                           operatorCombo[i] = new Option(operators[i][0], operators[i][1]);
                    }
                }
                changeFields(attribute, value, modifying);
            }else{
                alert("Error finding event's html element.");
            }
        }  




        function changeFields(attribute, value, modifying){
            var comboNumber = parseInt(attribute.name, 10);
            if((value == "") && (fieldCount > 1) && (comboNumber != fieldCount)){
                var fieldrow = document.getElementById("field" + new String(comboNumber));
                var parent = document.getElementById("fields");
                parent.removeChild(fieldrow);
            }else if((comboNumber == fieldCount) && (value != ""))
                newFieldRow(modifying);
            
        }



        //creates a new row under the fields to display header
        function newFieldRow(modifying){
            fieldCount = fieldCount +1;
            var insertPoint = document.getElementById("fields");
            var newRow = document.createElement("div");

            var rowName = new String(fieldCount);
            rowName = "field" + rowName;
            newRow.setAttribute("id", rowName);
            if(modifying) setClass(newRow, "fieldmodifyrow");//newRow.setAttribute("class", "fieldmodifyrow");
            else setClass(newRow, "fieldqueryrow");//newRow.setAttribute("class", "fieldqueryrow");
            var newAttributeList = createAttributeSelect(false, modifying);
            newRow.appendChild(newAttributeList);
            var newOperatorList = createOperatorSelect(modifying);
            newRow.appendChild(newOperatorList);
            if(modifying){
                //have to do div for value input outside of createFieldValueInput function because
                //can call createFieldValueInput or Select multiple times (for each time fieldName changes)
                var valInput = createFieldValueInput(fieldCount);
                var newDiv = document.createElement("div");
                setClass(newDiv, "fieldValue");//newDiv.setAttribute("class", "fieldValue");
                newDiv.setAttribute("id", new String(fieldCount) + "fieldValue" + "Div");
                newDiv.appendChild(valInput);
                newRow.appendChild(newDiv);
            }
            insertPoint.appendChild(newRow);
            //unhideBlocks();
        }




        //creates the operator select box for fields to display
        function createOperatorSelect(modifying){
            var newSelect = document.createElement("select");
            var name = new String(fieldCount);
            name = name +  "fieldOperator"
            newSelect.setAttribute("name",name);
            newSelect.setAttribute("id",name);

            var newDiv = document.createElement("div");
            setClass(newDiv, "fieldOperator");// newDiv.setAttribute("class", "fieldOperator");
            newDiv.setAttribute("id", name + "Div");
            
            var optionText;
            var count = 5;
            if(modifying) count = 2;
            for(var i = 0; i < count; i++){
                var newOption = document.createElement("option");
                newOption.setAttribute("value", operators[i][1]);
                optionText = document.createTextNode(operators[i][0]);
                newOption.appendChild(optionText);
                newSelect.appendChild(newOption);
            }
            
            newDiv.appendChild(newSelect);
            return newDiv;
        }

/////////////////////////////////////////////////////////////////////////
//        These functions only used on fields in modify section
/////////////////////////////////////////////////////////////////////////

        function setFieldValueInput(comboNumber, value){
            var oldChild = document.getElementById(new String(comboNumber)+"fieldValue");
            var keyIndex = 0;
            for(var i = 0; i < attributes.length; i++){
                if(attributes[i] == value){
                    keyIndex = i;
                }
                
            }
            
            //if we have an array in the keys array at keyIndex, that means we need to make a select object:
            if(keys[keyIndex].length > 0){
                //make a new select object with options:
                var newChild = createFieldValueSelect(keyIndex, comboNumber);
            }
            else{
                var newChild = createFieldValueInput(comboNumber);
            }

            document.getElementById(new String(comboNumber)+"fieldValue" +"Div").replaceChild(newChild, oldChild);
            
        }


        //creates the field value input box
        function createFieldValueInput(comboNumber){
            var newInput = document.createElement("input");
            var name = new String(comboNumber);
            name = name +  "fieldValue"
            newInput.setAttribute("name",name);
            newInput.setAttribute("id",name);
            return newInput;
        }

        function createFieldValueSelect(keyIndex, comboNumber){
            var newSelect = document.createElement("select");
            var name = new String(comboNumber);
                name = name + "fieldValue";
            
            newSelect.setAttribute("name",name);
            newSelect.setAttribute("id",name);
                        
            var optionText;
            var newOption;
            for(var i = 0; i < keys[keyIndex].length; i++){
                newOption = document.createElement("option");
                newOption.setAttribute("value", keys[keyIndex][i]);
                optionText = document.createTextNode(keys[keyIndex][i]);
                newOption.appendChild(optionText);
                newSelect.appendChild(newOption);
            }
            return newSelect;
        }



        function setFieldsLists(){
            var attributeValue="";// = document.getElementById(new String(1) + "fieldName").value;
            var operatorValue="";// = document.getElementById(new String(1) + "fieldOperator").value;
            var fieldValueValue="";// = document.getElementById(new String(1) + "fieldValue").value;
                        
            //fields & operators & fieldValues:
            for(var i = 1; i <= fieldCount; i++){
                if(document.getElementById(new String(i) + "fieldName"))
                    attributeValue = attributeValue + "," + document.getElementById(new String(i) + "fieldName").value;
                if(document.getElementById(new String(i) + "fieldOperator"))
                    operatorValue = operatorValue + "," + document.getElementById(new String(i) + "fieldOperator").value;
                if(document.getElementById(new String(i) + "fieldValue"))
                    fieldValueValue = fieldValueValue + "," + document.getElementById(new String(i) + "fieldValue").value;
            }
            document.getElementById("fieldNames").value = attributeValue;
            document.getElementById("fieldOperators").value = operatorValue;
            if(document.getElementById("fieldValues")) document.getElementById("fieldValues").value = fieldValueValue;

            //alert(attributeValue);
            //alert(operatorValue);
            //alert(fieldValueValue);

        }
