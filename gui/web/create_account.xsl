<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : create_account.xsl
    Created on : September 23, 2003, 6:07 PM
    Author     : d3l028
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="templates.xsl" />
    <xsl:output method="xhtml"  indent = "yes"/>

<xsl:template match = "/" >

<html xmlns="http://www.w3.org/1999/xhtml" lang="en">

<head>
    <title>GOLD: Create New Account</title>
    <script language="Javascript1.3" type="text/javascript" src="shared/util.js">//comments</script>
    <script language="Javascript" type="text/javascript">
         var subaccountsArray = new Array();
        
         function addAccount(){            
            var newAccount = document.inputForm.subAccountId.value;
            
            //check to make sure they have something for each field before continuing:
            if(newAccount == ""){
                alert("Please enter or select a subaccount.");
                return;
            }
                        
            var newRow = document.createElement("div");
            newRow.setAttribute("id", "subaccount"+new String(newAccount));
            
            //create accountId entered and append to new row
            var newAccountId = document.createElement("div");
            newAccountId.setAttribute("class", "accountId");
            var newAccountIdText = document.createTextNode(newAccount);
            newAccountId.appendChild(newAccountIdText);
            newRow.appendChild(newAccountId);
            
            //create overflow checkbox and append to new row
            var newOverflowCheckboxDiv = document.createElement("div");
            newOverflowCheckboxDiv.setAttribute("class", "overflow");
            var newOverFlowCheckbox = document.createElement("input");
            newOverFlowCheckbox.setAttribute("type", "checkbox");
            newOverFlowCheckbox.setAttribute("id", "overflow" + new String(newAccount) );
            newOverFlowCheckbox.setAttribute("name", "overflow" + new String(newAccount) );
            newOverflowCheckboxDiv.appendChild(newOverFlowCheckbox);
            newRow.appendChild(newOverflowCheckboxDiv);
            
            //create depositshare input and append to new row
            var newDSinputDiv = document.createElement("div");
            newDSinputDiv.setAttribute("class", "depositshare");
            var newDSInput = document.createElement("input");
            newDSInput.setAttribute("type", "text");
            newDSInput.setAttribute("size", "2");
            newDSInput.setAttribute("maxlength", "3");
            newDSInput.setAttribute("id", "depositShare" + new String(newAccount) );
            newDSInput.setAttribute("name", "depositShare" + new String(newAccount) );
            newDSinputDiv.appendChild(newDSInput);
            var percentText = document.createTextNode("%");
            newDSinputDiv.appendChild(percentText);
            newRow.appendChild(newDSinputDiv);
            
            
            //create subaccountId  hidden input and append to new row
            
            var newsubaccountId = document.createElement("input");
            newsubaccountId.setAttribute("type", "hidden");
            newsubaccountId.setAttribute("id", "subaccountId" + new String(newAccount) );
            newsubaccountId.setAttribute("name", "subaccountId" + new String(newAccount) );
            newsubaccountId.setAttribute("value", newAccount );
            newRow.appendChild(newsubaccountId);
            
            var newDeleteButton = document.createElement("input");
            newDeleteButton.setAttribute("type","button");
            newDeleteButton.setAttribute("value","Delete");
            newDeleteButton.setAttribute("onClick","deleteSubAccount('subaccount"+new String(newAccount)+"');");
            newDeleteButton.setAttribute("id","delete"+new String(newAccount));
            newDeleteButton.setAttribute("name","delete"+new String(newAccount));
            newRow.appendChild(newDeleteButton);
                        
            document.getElementById("accounts").appendChild(newRow);
            
        }
        
        function deleteSubAccount(name){
            
            var deleteRow = document.getElementById(name);
            var accounts = document.getElementById("accounts");
            accounts.removeChild(deleteRow);
            
        }

    
        function submitForm(){
            if(checkRequiredFields()){
                document.inputForm.target = "results";
                document.inputForm.action = "results.jsp";
                document.inputForm.submit();
            }
        }
        
        function setDefaults(){
            changeActivationTable('User'); 
            setMembers('User', 'Account');
            
            changeActivationTable('Machine'); 
            setMembers('Machine', 'Account');
        }
        
        function checkRequiredFields(){
            if(document.getElementById("AccountProject").value == ""){
                alert("Please select at least one project.");
                return false;
            }else if(document.getElementById("AccountUser").value == ""){
                alert("Please select at least one user.");
                return false;
            }else if(document.getElementById("AccountMachine").value == ""){
                alert("Please select at least one machine.");
                return false;
            }
            return true;
        }
    </script>

    <style type="text/css" media="all">

        @import "shared/gold.css";

        fieldset label {
            font-weight: bold;
            /*display: block;*/
        }

        fieldset select {
            width: 30%;
            float: left;
        }

        .activationTable {
            float: right;
            width: 66%;
        }

        .activationTable .headRow {
            border-bottom: 1px solid black;
            height: 2em;
        }

        .activationTable .headRow div {
            font-weight: bold;
            font-size: 105%;
        }

        .activationTable .activationRow {
            clear: both;
            border-bottom: 1px solid #A5C1E4;
            height: 2em;
            display: none;
        }

        .primaryKeyActivation, .active, .inactive {
            float: left;
            text-align: center;
            padding: .4em 0px;
        }

        .primaryKeyActivation {
            width: 45%;
        }

        .active, .inactive {
            width: 25%;
        }

        #selectInstructions {
            margin-top: 2em;
        }

    </style>
</head>

<body onload="setDefaults()">

<xsl:call-template name="Header" />
<xsl:call-template name="RequiredDescription" />
<xsl:call-template name="PrimaryKeyDescription" />
<xsl:call-template name = "Data" />


</body>
</html>
</xsl:template>



<xsl:template name = "Data">
    <form method="post" name="inputForm">
    <!--xsl:apply-templates select="//Attribute"/-->

    <!--div class="row">
    <label class="rowLabel" for="Type">Is this a Debit or Credit Account?:</label>

    <select id="type" name="type">
    <Option value=""/>
    <Option value="Credit">Credit</Option>
    <Option selected="true" value="Debit">Debit</Option>
    </select>
    </div>
    <div class="row">
    <label class="rowLabel" for="amount">
    <span class="required">*</span>Initial Amount:</label>
    <input maxlength="" size="30" value="" id="amount" name="amount" type="text"/>
    </div-->
    <div class="row">
    <label class="rowLabel" for="name">Name:</label>
    <input maxlength="" size="30" value="" id="Name" name="Name" type="text"/>
    </div>
    

    <!--div class="row">
    <label class="rowLabel" for="activationTime">When does this Account become Active?:</label>
    <input maxlength="" size="30" value="-infinity" id="activationTime" name="activationTime" type="text"/>
    </div>

    <div class="row">
    <label class="rowLabel" for="EndTime">When does this Account expire?:</label>
    <input maxlength="" size="30" value="infinity" id="endTime" name="endTime" type="text"/>
    </div-->
    
    <div class="row">
    <label class="rowLabel" for="Description">Description:</label>
    <input maxlength="80" size="30" value="" id="Description" name="Description" type="text"/>
    </div>

    <hr />
    <p id="selectInstructions">You can select multiple items from the Users, Projects, and Machines select fields by holding down 'Ctrl' on PCs and 'Cmd' on Macs.</p>

    <xsl:for-each select="*/child::*">
        <xsl:if test=".=../*[1]=false()"><!--if its not the first child, -->
        <div class="row">
            <fieldset id="{name(./*[1])}Fieldset">
                <legend><xsl:value-of select="name(./*[1])"/>s</legend>
                <div id="{name(./*[1])}Activation" class="activationTable">
                    <xsl:call-template name = "NameRadio">
                    <xsl:with-param name="object">Account</xsl:with-param>
                    </xsl:call-template>
                </div>
                <xsl:if test="name(./*[1]) != 'Account'">
                <xsl:call-template name = "SpecialValueCheckboxes">
                    <xsl:with-param name="use_defaults" select="true()"/>
                </xsl:call-template>
                </xsl:if>

                <xsl:call-template name = "NameSelect">
                    <xsl:with-param name="onchange">changeActivationTable('<xsl:value-of select="name(./*[1])"/>'); setMembers('<xsl:value-of select="name(./*[1])"/>', 'Account');</xsl:with-param>
                    <xsl:with-param name="disabled">
                    <xsl:choose>
                    <xsl:when test="name(./*[1]) =  'Project'">false</xsl:when>
                    <xsl:when test="name(./*[1]) =  'Account'">false</xsl:when>
                    <xsl:otherwise >true</xsl:otherwise>
                    </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
                <input type="hidden" name="account{name(./*[1])}" id="Account{name(./*[1])}"/>
                <input type="hidden" name="account{name(./*[1])}Active" id="Account{name(./*[1])}Active"/>
                <!--xsl:if test="name(./*[1]) = 'Project'">
                    <input type="hidden" name="account{name(./*[1])}AllowDesc" id="Account{name(./*[1])}AllowDesc"/>
                </xsl:if-->
            </fieldset>
        </div>
        </xsl:if>
    </xsl:for-each>
    
    <!-- do special subaccounts section: -->
    <!-- commented out for now
    
    <div class="row">
    <fieldset id="AccountFieldset">
      <legend>Subaccounts</legend>
      
      <div class="row">
        <label class="rowLabel" for="subAccountId">Account:</label>
        <input maxlength="20" size="20" value="" id="subAccountId" name="subAccountId" type="text"/>
        <input type="button" value="Add" id="add" onclick="addAccount()" />
        <input type="button" value="Select..." id="selectAccount" onclick="searchForAccounts()" />
      </div>
      
      <div class="activationTable" id="AccountActivation">
        <div class="headRow">
          <div class="primaryKeyActivation">Account</div>
          <div class="active">Overflow</div>
          <div class="allowdesc">DepositShare</div>
        </div>
        <div id="accounts">
            //javascript addaccount method will add divs here
        </div>
      </div>
      <input id="AccountAccount" name="accountAccount" type="hidden"/>
      <input id="AccountAccountDepoistShare" name="accountAccountDepositShare" type="hidden"/>
      <input id="AccountAccountOverFlow" name="accountAccountOverflow" type="hidden"/>
    </fieldset>
    </div>
    -->
    
    <xsl:call-template name="SubmitRow" />

    </form>
</xsl:template>





</xsl:stylesheet>
