
        //counter to track how many search condition rows we're displaying
        var conditionCount = 1;


        //array of operators for search condition
        var conditionOperators = new Array();
        conditionOperators[0] = new Array("", "");
        conditionOperators[1] = new Array("==","EQ");
        conditionOperators[2] = new Array("!=","NE");
        conditionOperators[3] = new Array(">","GT");
        conditionOperators[4] = new Array("<","LT");
        conditionOperators[5] = new Array(">=","GE");
        conditionOperators[6] = new Array("<=","LE");
        conditionOperators[7] = new Array("matches","Match");



        //this function sets the value for the group by adding the
        //two selects" grouping and ungrouping:
        function setGroup(combo){
            var inty = parseInt(combo.name, 10);
            var grouping = document.getElementById(new String(inty) + "grouping");
            var ungrouping = document.getElementById(new String(inty) + "ungrouping");
            
            var groupVal = parseInt(grouping[grouping.selectedIndex].value);
            var ungroupingVal = parseInt(ungrouping[ungrouping.selectedIndex].value);
            //alert("groupVal: " + groupVal);
            //alert("ungroupingVal:" + ungroupingVal);
            var hiddenField = document.getElementById(new String(inty) + "group");
            hiddenField.value = groupVal + ungroupingVal;
            
            //alert("group value =" + hiddenField.value);
        }
        

        function changeConditions(evt){//attribute, value){
            var source = getElement(evt);
            if(source) {
                var attribute = document.getElementById(source.id);
                var value = attribute[attribute.selectedIndex].text; 

                var comboNumber = parseInt(attribute.name, 10);
                if((value == "") && (conditionCount > 1) && (comboNumber != conditionCount)){
                    var conditionrow = document.getElementById("condition" + new String(comboNumber));
                    var parent = document.getElementById("conditions");
                    parent.removeChild(conditionrow);
                }else if((comboNumber == conditionCount) && (value != ""))
                    newConditionRow();
            }else{
                alert("Error finding event's html element.");
            }
        }

       
        //this function creates a new row under the search conditions header
        function newConditionRow(){
            conditionCount = conditionCount +1;
            var insertPoint = document.getElementById("conditions");
            var newRow = document.createElement("div");
            var rowName = new String(conditionCount);
            rowName = "condition" + rowName;
            newRow.setAttribute("id", rowName);
            setClass(newRow, "conditionrow");//newRow.setAttribute("class", "conditionrow");
                
            newRow.appendChild(createConjunctionSelect());
            newRow.appendChild(createGroupingSelect());
            newRow.appendChild(createAttributeSelect(true));
            newRow.appendChild(createConditionOperatorSelect());
            newRow.appendChild(createConditionValueInput());
            newRow.appendChild(createUngroupingSelect());
            newRow.appendChild(createGroupHiddenField());
                
            insertPoint.appendChild(newRow);
        }
        
        //creates the conjuction select box
        function createConjunctionSelect(){
            var name = new String(conditionCount);
            name = name +  "conjunction"

            var newDiv = document.createElement("div");
            setClass(newDiv, "conjunction");//newDiv.setAttribute("class", "conjunction");
            newDiv.setAttribute("id", name + "Div");

            var newSelect = document.createElement("select");
            
            newSelect.setAttribute("name",name);
            newSelect.setAttribute("id",name);
            var newOption = document.createElement("option");
                newOption.setAttribute("value", "");
            var optionText = document.createTextNode("");
                newOption.appendChild(optionText);
                newSelect.appendChild(newOption);
            
                newOption = document.createElement("option");
                newOption.setAttribute("value", "And");
                optionText = document.createTextNode("And");
                newOption.appendChild(optionText);
                newSelect.appendChild(newOption);

                newOption = document.createElement("option");
                newOption.setAttribute("value", "Or");
                optionText = document.createTextNode("Or");
                newOption.appendChild(optionText);
                newSelect.appendChild(newOption);
            
           
            newDiv.appendChild(newSelect);
            return newDiv;
        }

        //creates the grouping select box
        function createGroupingSelect(){
            var name = new String(conditionCount);
            name = name +  "grouping"
            var newDiv = document.createElement("div");
            setClass(newDiv, "grouping");//newDiv.setAttribute("class", "grouping");
            newDiv.setAttribute("id", name + "Div");

            var newSelect = document.createElement("select");
            
            newSelect.setAttribute("name",name);
            newSelect.setAttribute("id",name);
            newSelect.setAttribute("onchange","setGroup(this);");
            var newOption = document.createElement("option");
                newOption.setAttribute("value", "0");
            var optionText = document.createTextNode("");
                newOption.appendChild(optionText);
                newSelect.appendChild(newOption);
            
            //loop 3 times for (, ((, and ((( values
            var paren = new String("(");
            for(var i = 1; i <=3; i++){
                newOption = document.createElement("option");
                newOption.setAttribute("value", i);
                optionText = document.createTextNode(paren);
                newOption.appendChild(optionText);
                newSelect.appendChild(newOption);
                paren = paren + "(";
            }
            
            newDiv.appendChild(newSelect);
            return newDiv;
        }

        
        //creates the condition operator select box
        function createConditionOperatorSelect(){
            var name = new String(conditionCount);
            name = name +  "conditionOperator"
            var newDiv = document.createElement("div");
            setClass(newDiv, "conditionOperator");//newDiv.setAttribute("class", "conditionOperator");
            newDiv.setAttribute("id", name + "Div");

            var newSelect = document.createElement("select");
            
            newSelect.setAttribute("name",name);
            newSelect.setAttribute("id",name);
            
            var optionText;
            for(var i = 0; i < conditionOperators.length; i++){
                var newOption = document.createElement("option");
                newOption.setAttribute("value", conditionOperators[i][1]);
                optionText = document.createTextNode(conditionOperators[i][0]);
                newOption.appendChild(optionText);
                newSelect.appendChild(newOption);
            }
            
            newDiv.appendChild(newSelect);
            return newDiv;
        }


        //creates the value input box
        function createConditionValueInput(){
            var name = new String(conditionCount);
            name = name +  "conditionValue"
            var newDiv = document.createElement("div");
            setClass(newDiv, "conditionValue");//newDiv.setAttribute("class", "conditionValue");
            newDiv.setAttribute("id", name + "Div");

            var newInput = document.createElement("input");
            newInput.setAttribute("name",name);
            newInput.setAttribute("id",name);
            
            newDiv.appendChild(newInput);
            return newDiv;
        }

        //creates the ungrouping select box
        function createUngroupingSelect(){
            var name = new String(conditionCount);
            name = name +  "ungrouping"
            var newDiv = document.createElement("div");
            setClass(newDiv, "ungrouping");//newDiv.setAttribute("class", "ungrouping");
            newDiv.setAttribute("id", name + "Div");

            var newSelect = document.createElement("select");
            newSelect.setAttribute("name",name);
            newSelect.setAttribute("id",name);
            newSelect.setAttribute("onchange","setGroup(this);");
            var newOption = document.createElement("option");
                newOption.setAttribute("value", "0");
            var optionText = document.createTextNode("");
                newOption.appendChild(optionText);
                newSelect.appendChild(newOption);
            
            var paren = new String(")");
            for(var i = 1; i <=3; i++){
                newOption = document.createElement("option");
                newOption.setAttribute("value", new String(i*(-1)));
                optionText = document.createTextNode(paren);
                newOption.appendChild(optionText);
                newSelect.appendChild(newOption);
                paren = paren + ")";
            }
            
            newDiv.appendChild(newSelect);
            return newDiv;
        }

        //creates the hidden filed group
        function createGroupHiddenField(){
            var newInput = document.createElement("input");
            newInput.setAttribute("type", "hidden");
            newInput.setAttribute("value", "0");
            var name = new String(conditionCount);
            name = name +  "group"
            newInput.setAttribute("name",name);
            newInput.setAttribute("id",name);
            return newInput;
        }
            




        function setConditionsLists(){
            var nameValue="";// = document.getElementById(new String(1) + "conditionName").value;
            var conditionValueValue="";// = document.getElementById(new String(1) + "conditionValue").value;
            var conditionOperatorValue="";// = document.getElementById(new String(1) + "conditionOperator").value;
            var conjunctionValue="";// = document.getElementById(new String(1) + "conjunction").value;
            var groupValue="";// = document.getElementById(new String(1) + "group").value;

            //conditions(conjunction, group, name, condtionoperator, and value):
            for(var i = 1; i <= conditionCount; i++){
                if(document.getElementById(new String(i) + "conditionName"))
                    nameValue = nameValue + "," + document.getElementById(new String(i) + "conditionName").value;
                if(document.getElementById(new String(i) + "conditionValue"))
                    conditionValueValue = conditionValueValue + "," + document.getElementById(new String(i) + "conditionValue").value;
                if(document.getElementById(new String(i) + "conditionOperator"))
                    conditionOperatorValue = conditionOperatorValue + "," + document.getElementById(new String(i) + "conditionOperator").value;
                if(document.getElementById(new String(i) + "conjunction"))
                    conjunctionValue = conjunctionValue + "," + document.getElementById(new String(i) + "conjunction").value;
                if(document.getElementById(new String(i) + "group"))
                    groupValue = groupValue + "," + document.getElementById(new String(i) + "group").value;
            }
            document.getElementById("conditionNames").value = nameValue;
            //alert(nameValue);
            document.getElementById("conditionValues").value = conditionValueValue;
            //alert(conditionValueValue);
            document.getElementById("conditionOperators").value = conditionOperatorValue;
            //alert(conditionOperatorValue);
            document.getElementById("conjunctions").value = conjunctionValue;
            //alert(conjunctionValue);
            document.getElementById("groups").value = groupValue;
            //alert(groupValue);
        }
