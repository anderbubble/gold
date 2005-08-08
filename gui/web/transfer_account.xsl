<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : create_project.xsl
    Created on : September 23, 2003, 6:07 PM
    Author     : d3l028
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="templates.xsl" />
    <xsl:import href="table_templates.xsl" />
    <xsl:output method="xhtml" indent = "yes"/>

<xsl:template match = "/" >

<html xmlns="http://www.w3.org/1999/xhtml" lang="en">

<head>
    <title>GOLD: Make Transfer</title>

    <script language="Javascript1.3" type="text/javascript" src="shared/util.js">//comment</script>
    <script language="Javascript" type="text/javascript">
        
    
        function submitForm(){
            if(document.getElementById('FromId').value == "")
                alert("A From Id must be specified.  Please specify a From Account Id and press the Make Transfer button again.");
            else if(document.getElementById('ToId').value == "")
                alert("A To Id must be specified.  Please specify a To Account Id and press the Make Transfer button again.");
            else if(document.getElementById('Amount').value == "")
                alert("An Amount must be specified.  Please specify an amount and press the Make Transfer button again.");
            else{
                document.inputForm.target = "results";
                document.inputForm.action = "results.jsp";
                document.inputForm.submit();
            }
        }

        function setIds(){
            var transferFromIds = document.getElementById("fromIds");
            transferFromIds.value = "";
            var transferToIds = document.getElementById("toIds");
            transferToIds.value = "";
            if(document.getElementById("toResults") <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> document.getElementById("toResults").style.display != "none"){
                //if toResults is there and its still being displayed, use the id's checked there
                <xsl:for-each select="//results/From/Account">
                    if(document.getElementById("fromAccount<xsl:value-of  select="Id" />").checked == true)
                        transferFromIds.value += "<xsl:value-of  select="Id" />,";
                </xsl:for-each>
                <xsl:for-each select="//results/To/Account">
                    if(document.getElementById("toAccount<xsl:value-of  select="Id" />").checked == true)
                        transferToIds.value += "<xsl:value-of  select="Id" />,";
                </xsl:for-each>
                
                //alert("transferFromIds: " + transferFromIds.value);
                //alert("transferToIds: " + transferToIds.value);
                
                if(transferFromIds.value != "" <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> transferToIds.value != "") 
                    return true;
                else {
                    alert("At least one Account must be selected for both transfer to and transfer from.");
                    return false;
                }
            }else{ //otherwise we'll use the selections from either the typed in ID or the combo boxes
                if(document.getElementById("fromAccountId").checked){
                    transferFromIds.value = document.getElementById("fromId").value;
                    if(document.getElementById("fromId").value == "") {
                        alert("Please enter the Account Id to transfer from.");
                        return false;
                    }
                }
                if(document.getElementById("toAccountId").checked){
                    transferToIds.value = document.getElementById("toId").value;
                    if(document.getElementById("toId").value == "") {
                        alert("Please enter the Account Id to transfer to.");
                        return false;
                     }
                }
                return true;
            }
        }
        
        
        function toggleConstraints(hideResults){
            var fromselect;
            var usingFromId = document.getElementById("fromAccountId").checked;
            <xsl:for-each select="Data/child::*">
                <xsl:if test="name(.) != 'results'">
                fromselect =  document.getElementById("from<xsl:value-of  select="name(./*[1])" />");
                if(usingFromId)
                    fromselect.disabled = true;
                else fromselect.disabled = false;
                </xsl:if>
            </xsl:for-each>
            if(usingFromId)
                document.getElementById("fromId").disabled = false;
            else
                document.getElementById("fromId").disabled = true;


            var toselect;
            var usingToId = document.getElementById("toAccountId").checked;
            <xsl:for-each select="Data/child::*">
                <xsl:if test="name(.) != 'results'">
                toselect =  document.getElementById("to<xsl:value-of  select="name(./*[1])" />");
                if(usingToId)
                    toselect.disabled = true;
                else toselect.disabled = false;
                </xsl:if>
            </xsl:for-each>
            if(usingToId)
                document.getElementById("toId").disabled = false;
            else
                document.getElementById("toId").disabled = true;
                
            if(hideResults){    
                if(document.getElementById("fromResults")) document.getElementById("fromResults").style.display = "none";
                if(document.getElementById("toResults")) document.getElementById("toResults").style.display = "none";
                document.getElementById("verify").disabled = false;
                
            }

        }
        
        function disableAll(){
            document.getElementById("fromAccountId").disabled = true;
            document.getElementById("toAccountId").disabled = true;
            document.getElementById("fromAccountConstraints").disabled = true;
            document.getElementById("toAccountConstraints").disabled = true;
        }
        
        function enableAll(){
            document.getElementById("fromAccountId").disabled = false;
            document.getElementById("toAccountId").disabled = false;
            document.getElementById("fromAccountConstraints").disabled = false;
            document.getElementById("toAccountConstraints").disabled = false;
        }
        
        function verify(){
            disableAll();
            document.inputForm.target = "action";
            document.inputForm.action = "transfer_account.jsp?verify=true";
            document.inputForm.submit();
            enableAll();
        }
        
        function initVars(){
            <xsl:if test="//results/Params">
                <xsl:for-each select="//results/Params/*">
                    document.getElementById("<xsl:value-of select="name(.)"/>").value = "<xsl:value-of select="."/>";
                </xsl:for-each>
                <xsl:if test="//results/Params/fromUser">
                    
                    document.getElementById("fromAccountConstraints").checked = true;
                </xsl:if>
                <xsl:if test="//results/Params/toUser">
                    document.getElementById("toAccountConstraints").checked = true;
                </xsl:if>
                toggleConstraints(false);
            </xsl:if>
        }
        
        var whichId;
        function setId(id){
            document.getElementById(whichId).value = id;
        }
        
        function selectAccount(toOrFrom){
            whichId = toOrFrom;
            newWindow('AccountSelect', "select_account.jsp", 1050, 500);
        }
    </script>

    <style type="text/css" media="all">

        @import "shared/gold.css";

        #transfer {
            width: 46em;
            margin: .6em auto;
        }

        .multiSelect {
            margin-top: 1em;
        }

        .multiSelect label {
            font-weight: bold;
            display: block;
        }

        .include, .exclude {
            width: 45%;
        }

        .include {
            float: left;
        }

        .exclude {
            float: right;
        }

        .include .row, .exclude .row {
            width: auto;
        }

        #includeHead, #excludeHead {
            border-bottom: 1px solid black;
            margin-top: 10px;
            margin-bottom: 2px;
            font-weight: bold;
            font-size: 100%;
            text-align: left;
        }

        html>body #includeHead, html>body #excludeHead {
            margin-top: 0px;
        }

        .withdrawOption label{
            font-weight: bold;
        }

        table#results {
            border-top: 1px solid black;
            border-left: 1px solid black;
            margin: auto;
            margin-top: 1em;
        }

        table#constrainResults {
            margin: auto;
            /*background-color: #EFEBAB;
            border: 1px solid black;Machine
            padding: 5px;*/
        }

        table#results th, table#results td {
            border-right: 1px solid black;
            border-bottom: 1px solid black;
            font-size: 70%;
        }

        table#constrainResults th, table#constrainResults td {
            font-size: 70%;
            border-right: none;
            border-bottom: none;
        }

        table#results th, table#constrainResults th {
            font-weight: bold;
            text-align: center;
            vertical-align: bottom;
            background-color: #EFEBAB;
            padding: 0px;
            white-space: nowrap;
        }

        table#constrainResults th {
            background-color: transparent;
        }

        table#results th div {
            border: 1px outset #EFEBAB;
            cursor: default;
        }

        table#results th div:hover {
            background-color: #FFF9C2;
        }

        table#results th div:active {
            background-color: #E6E396;
            border-style: inset;
        }

        table#results th div, table#results td {
            padding: 6px;
        }

        table#constrainResults th {
            padding: 2px 7px;
        }

        table#constrainResults td {
            padding: 6px;
            text-align: center;;
        }

        table#results th.deleteHead div, table#results th.deleteHead div:hover, table#results th.deleteHead div:active {
            background-color: #EFEBAB;
            border-style: solid;
        }

        table#results td, table#constrainResults td {
            vertical-align: top;
        }

        td.deleteCell, td.modifyCell {
            text-align: center;
            background-color: #FFF9C2;
        }
    </style>

</head>

<body >

<xsl:call-template name="Header">
    <xsl:with-param name="myaction">Make</xsl:with-param>
    <xsl:with-param name="myobject">Transfer</xsl:with-param>
</xsl:call-template>

<xsl:call-template name="RequiredDescription" />

    <form method="post" name="inputForm">
    
    <div class="row">
    <label class="rowLabel" for="FromId"><span class="required">*</span>From Account Id:</label>
    <input maxlength="" size="30" value="" id="FromId" name="FromId" type="text"/>
    <input onClick="selectAccount('FromId')" value="Select..." id="selectAccountButton" name="selectAccountButton" type="button"/>
    </div>
    
    <div class="row">
    <label class="rowLabel" for="ToId"><span class="required">*</span>To Account Id:</label>
    <input maxlength="" size="30" value="" id="ToId" name="ToId" type="text"/>
    <input onClick="selectAccount('ToId')" value="Select..." id="selectAccountButton" name="selectAccountButton" type="button"/>
    </div>
    
    <div class="row">
    <label class="rowLabel" for="Amount">
    <span class="required">*</span>Amount:</label>
    <input maxlength="" size="30" value="" id="Amount" name="Amount" type="text"/>
    </div>
    
    <div class="row">
    <label class="rowLabel" for="Allocation">Allocation Id:</label>
    <input maxlength="" size="30" value="" id="Allocation" name="Allocation" type="text"/>
    </div>
    
    
    
    
    <div class="row">
    <label class="rowLabel" for="Description">Description</label>
    <input maxlength="" size="30" value="" id="Description" name="Description" type="text"/>
    </div>
    </form>
    
    
<xsl:call-template name="SubmitRow" >
    <xsl:with-param name="myaction">Make</xsl:with-param>
    <xsl:with-param name="myobject">Transfer</xsl:with-param>
</xsl:call-template>


</body>
</html>
</xsl:template>

</xsl:stylesheet>