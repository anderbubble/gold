        //counter to track how many field rows we're displaying
        var fieldCount = 1;
        //counter to track how many search condition rows we're displaying
        var conditionCount = 1;

        //array of operators for what to display
        var operators = new Array();
        operators[0] = new Array("", "");
        operators[1] = new Array("sort-asc", "Sort");
	operators[2] = new Array("sort-desc","Tros");
	operators[3] = new Array("unique","Distinct");
	operators[4] = new Array("groupby","GroupBy");
        operators[5] = new Array("max","Max");
        operators[6] = new Array("min","Min");
        operators[7] = new Array("sum","Sum");
        operators[8] = new Array("avg","Average");

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
        

        //this function sets the valid operators for the selected
        //field to display based on that field's type
        function setOperators(attribute, value){
            var comboNumber = parseInt(attribute.name, 10);
            var type;
            var count=6;
            for(var i = 0; i < attributes.length; i++){
                if(attributes[i] == value){
                    type = dataTypes[i];
                }
            }
            //alert("type="+type);
            var operatorCombo = document.getElementById(new String(comboNumber) + "operator");
            
            //first clear out old values aftconditionOperatorser max, min, sum, & avg since every type gets those:
            for(i=operatorCombo.length; i > 4; i--) {
                operatorCombo[i] = null;
            } 
            if((type == "TimeStamp") || (type == "Integer") || (type == "Currency")){
                if(type == "Integer" || type == "Currency") count = 8;
                for(var i = 5; i <= count; i++)
                   operatorCombo[i] = new Option(operators[i][0], operators[i][1]);
            }
            //alert("count:"+count);
        }            
            

        
        //this function creates a new row under the search conditions header
        function newConditionRow(){
            conditionCount = conditionCount +1;
            var insertPoint = document.getElementById("conditions");
            var newRow = document.createElement("div");
            rowName = new String(conditionCount);
            rowName = "condition" + rowName;
            newRow.setAttribute("id", rowName);
                
            newRow.appendChild(createConjunctionSelect());
            newRow.appendChild(createGroupingSelect());
            newRow.appendChild(createAttributeSelect(true));
            newRow.appendChild(createConditionOperatorSelect());
            newRow.appendChild(createValueInput());
            newRow.appendChild(createUngroupingSelect());
            newRow.appendChild(createGroupHiddenField());
                
            insertPoint.appendChild(newRow);
        }
        
        //creates the conjuction select box
        function createConjunctionSelect(){
            var newSelect = document.createElement("select");
            var name = new String(conditionCount);
            name = name +  "conjunction"
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
            
            return newSelect;
        }

        //creates the grouping select box
        function createGroupingSelect(){
            var newSelect = document.createElement("select");
            var name = new String(conditionCount);
            name = name +  "grouping"
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
                newOption.setAttribute("value", paren);
                optionText = document.createTextNode(paren);
                newOption.appendChild(optionText);
                newSelect.appendChild(newOption);
                paren = paren + "(";
            }
            return newSelect;
        }

        
        //creates the condition operator select box
        function createConditionOperatorSelect(){
            var newSelect = document.createElement("select");
            var name = new String(conditionCount);
            name = name +  "conditionOperator"
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
            return newSelect;
        }


        //creates the value input box
        function createValueInput(){
            var newInput = document.createElement("input");
            var name = new String(conditionCount);
            name = name +  "value"
            newInput.setAttribute("name",name);
            newInput.setAttribute("id",name);
            return newInput;
        }

        //creates the ungrouping select box
        function createUngroupingSelect(){
            var newSelect = document.createElement("select");
            var name = new String(conditionCount);
            name = name +  "ungrouping"
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
            return newSelect;
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
            
        //creates a new row under the fields to display header
        function newFieldRow(){
            fieldCount = fieldCount +1;
            var insertPoint = document.getElementById("fields");
            var newRow = document.createElement("div");
            rowName = new String(fieldCount);
            rowName = "field" + rowName;
            newRow.setAttribute("id", rowName);
                
            var newAttributeList = createAttributeSelect(false);
            newRow.appendChild(newAttributeList);

            var newOperatorList = createOperatorSelect();
            newRow.appendChild(newOperatorList);
                
            insertPoint.appendChild(newRow);
        }
            
        //creates the attributes select box
        function createAttributeSelect(forConditions){
            var newSelect = document.createElement("select");
            var name;
            if(forConditions){
                name = new String(conditionCount);
                name = name +  "name"
            }else {
                name = new String(fieldCount);
                name = name +  "attribute"
                newSelect.setAttribute("onChange", "setOperators(this, this[selectedIndex].text);")
            }
            newSelect.setAttribute("name",name);
            newSelect.setAttribute("id",name);
                        
            var optionText;
            var newOption;
            for(var i = 0; i < attributes.length; i++){
                newOption = document.createElement("option");
                newOption.setAttribute("value", attributes[i]);
                optionText = document.createTextNode(attributes[i]);
                newOption.appendChild(optionText);
                newSelect.appendChild(newOption);
            }
            return newSelect;
        }


        //creates the operator select box for fields to display
        function createOperatorSelect(){
            var newSelect = document.createElement("select");
            var name = new String(fieldCount);
            name = name +  "operator"
            newSelect.setAttribute("name",name);
            newSelect.setAttribute("id",name);
            
            var optionText;
            for(var i = 0; i < 5; i++){
                var newOption = document.createElement("option");
                newOption.setAttribute("value", operators[i][1]);
                optionText = document.createTextNode(operators[i][0]);
                newOption.appendChild(optionText);
                newSelect.appendChild(newOption);
            }
            return newSelect;
        }

            
        function submitForm(){
            //assign to hidden variables:
            setLists();

            document.inputForm.target = "resultFrame";
            document.inputForm.action = "results.jsp";
            document.inputForm.submit();
        }


        function setLists(){
            var value;
            var attributeValue = document.getElementById(new String(1) + "attribute").value;
            var operatorValue = document.getElementById(new String(1) + "operator").value;
            var nameValue = document.getElementById(new String(1) + "name").value;
            var valueValue = document.getElementById(new String(1) + "value").value;
            var conditionOperatorValue = document.getElementById(new String(1) + "conditionOperator").value;
            var conjunctionValue = document.getElementById(new String(1) + "conjunction").value;
            var groupValue = document.getElementById(new String(1) + "group").value;
            
            //first do fields & operators:
            for(var i = 2; i <= fieldCount; i++){
                attributeValue = attributeValue + "," + document.getElementById(new String(i) + "attribute").value;
                operatorValue = operatorValue + "," + document.getElementById(new String(i) + "operator").value;
            }
            document.getElementById("attributes").value = attributeValue;
            document.getElementById("operators").value = operatorValue;


            //then do conditions(conjunction, group, name, condtionoperator, and value):
            for(var i = 2; i <= conditionCount; i++){
                nameValue = nameValue + "," + document.getElementById(new String(i) + "name").value;
                valueValue = valueValue + "," + document.getElementById(new String(i) + "value").value;
                conditionOperatorValue = conditionOperatorValue + "," + document.getElementById(new String(i) + "conditionOperator").value;
                conjunctionValue = conjunctionValue + "," + document.getElementById(new String(i) + "conjunction").value;
                groupValue = groupValue + "," + document.getElementById(new String(i) + "group").value;
            }
            document.getElementById("names").value = nameValue;
            document.getElementById("values").value = valueValue;
            document.getElementById("conditionOperators").value = conditionOperatorValue;
            document.getElementById("conjunctions").value = conjunctionValue;
            document.getElementById("groups").value = groupValue;
        }
