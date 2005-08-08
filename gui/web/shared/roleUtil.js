        var ua = window.navigator.userAgent.toLowerCase();
        if ((i = ua.indexOf('msie')) != -1) navigator.org = "microsoft";
        var classAttributeName = (navigator.org == "microsoft") ? "className" : "class";



        function submitForm(){
            //alert("permissionsObjectArray: "+ permissionsObjectArray);
            //alert("permissionsActionArray: "+ permissionsActionArray);
            //alert("permissionsInstanceArray: "+ permissionsInstanceArray);

            var objects = document.getElementById("objects").value;
            var actions = document.getElementById("actions").value;
            var instances = document.getElementById("instances").value;
            objects = "";
            actions = "";
            instances = "";

            for(i = 0; i != permissionsObjectArray.length; i++){
                if(permissionsObjectArray[i] != ""){
                    objects += permissionsObjectArray[i] + ",";
                    actions += permissionsActionArray[i] + ",";
                    instances += permissionsInstanceArray[i] + ",";
                }
            }

            document.getElementById("objects").value = objects;
            document.getElementById("actions").value = actions;
            document.getElementById("instances").value = instances;

            if(checkRequiredFields()){
                document.inputForm.target = "results";
                document.inputForm.action = "results.jsp";
                document.inputForm.submit();
            }

        }


        //called when the user presses the add button, so does error checking
        function addPerm(){
            var object = document.inputForm.Object[document.inputForm.Object.selectedIndex].value;
            var action = document.inputForm.Action[document.inputForm.Action.selectedIndex].value;
            var instance = document.inputForm.Instance.value;

            //check to make sure they have something for each field before continuing:
            if(object == ""){
                alert("Please select an object.");
                return;
            }if(action == ""){
                alert("Please select an action.");
                return;
            }if(instance == ""){
                alert("Please type in an instance.");
                return;
            }

            addPermRow(object, action, instance);

        }

        //called from init vars function when loading up an exiting role, so does NOT do error checking
        function addPermRow(object, action, instance){
            //add values to arrays:
            permissionsObjectArray[permissionsObjectArray.length] = object;
            permissionsActionArray[permissionsActionArray.length] = action;
            permissionsInstanceArray[permissionsInstanceArray.length] = instance;


            var newRow = document.createElement("div");
            newRow.setAttribute("id", "permission"+object+action+instance);
            newRow.setAttribute(classAttributeName, "permission");

            //create object selected and append to new row
            var newObject = document.createElement("div");
            newObject.setAttribute(classAttributeName, "permissionsObject");
            var objectText = document.createTextNode(object);
            newObject.appendChild(objectText);
            newRow.appendChild(newObject);

            //create action selected and append to new row
            var newAction = document.createElement("div");
            newAction.setAttribute(classAttributeName, "permissionsAction");
            var actionText = document.createTextNode(action);
            newAction.appendChild(actionText);
            newRow.appendChild(newAction);

            //create action selected and append to new row
            var newInstance = document.createElement("div");
            newInstance.setAttribute(classAttributeName, "permissionsInstance");
            var instanceText = document.createTextNode(instance);
            newInstance.appendChild(instanceText);
            newRow.appendChild(newInstance);

            var newDeleteBox = document.createElement("div");
            newDeleteBox.setAttribute(classAttributeName, "delete");
            var newDeleteButton = document.createElement("input");
            newDeleteButton.setAttribute("type","button");
            newDeleteButton.setAttribute("value","Delete");

            newDeleteButton.setAttribute("onClick","deletePermission('permission"+object+action+instance+"',"+String(permissionsInstanceArray.length - 1)+")");
            newDeleteButton.setAttribute("id","delete"+object+action+instance);
            newDeleteButton.setAttribute("name","delete"+object+action+instance);
            newDeleteBox.appendChild(newDeleteButton);
            newRow.appendChild(newDeleteBox);

            var newClearBox = document.createElement("div");
            newClearBox.setAttribute(classAttributeName, "clear");
            newRow.appendChild(newClearBox);

            document.getElementById("permissionsResultsRow").appendChild(newRow);
        }


        function deletePermission(name, number){
            var deleteRow = document.getElementById(name);
            var permissions = document.getElementById("permissionsResultsRow");
            permissions.removeChild(deleteRow);


            //remove values from arrays:
            permissionsObjectArray[number] = "";
            permissionsActionArray[number] = "";
            permissionsInstanceArray[number] = "";
        }