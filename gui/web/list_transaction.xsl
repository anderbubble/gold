<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : create_reservation.xsl
    Created on : May 20, 2004
    Author     : d3l028
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="templates.xsl" />
    <xsl:output method="xhtml" indent = "yes"/>

<xsl:template match = "/" >

<html xmlns="http://www.w3.org/1999/xhtml" lang="en">

<head>
    <title>GOLD: List Transactions</title>

    <script language="Javascript1.3" type="text/javascript" src="shared/util.js">//stuff</script>
    <script language="Javascript" type="text/javascript">
        
        function submitForm(){    
            setUpConditions();
            document.inputForm.target = "results";
            document.inputForm.action = "results.jsp";
            document.inputForm.submit();
        }
        
        
        function setUpConditions(){
            var conditionNames="";
            var conditionValues="";
            var conditionOperators="";
            var optionName ="";
            var optionValue="";
            if(document.getElementById("Object")[document.getElementById("Object").selectedIndex].value != "") {
                conditionNames +="Object,";
                conditionValues += document.getElementById("Object")[document.getElementById("Object").selectedIndex].value+",";
                conditionOperators += "eq,";
            }
            if(document.getElementById("Action")[document.getElementById("Action").selectedIndex].value != "") {
                conditionNames +="Action,";
                conditionValues += document.getElementById("Action")[document.getElementById("Action").selectedIndex].value+",";
                conditionOperators += "eq,";
            }
            if(document.getElementById("StartTime").value != "") {
                conditionNames +="CreationTime,";
                conditionValues += document.getElementById("StartTime").value+",";
                conditionOperators += "ge,";
            }
            if(document.getElementById("EndTime").value != "") {
                conditionNames +="CreationTime,";
                conditionValues += document.getElementById("EndTime").value+",";
                conditionOperators += "le,";
            }
            if(document.getElementById("Account").value != "") {
                conditionNames +="Account,";
                conditionValues += document.getElementById("Account").value+",";
                conditionOperators += "eq,";
            }
            if(document.getElementById("JobId").value != "") {
                conditionNames +="JobId,";
                conditionValues += document.getElementById("JobId").value+",";
                conditionOperators += "eq,";
            }
            if(document.getElementById("User").value != "") {
                conditionNames +="User,";
                conditionValues += document.getElementById("User").value+",";
                conditionOperators += "eq,";
            }
            if(document.getElementById("Project").value != "") {
                conditionNames +="Project,";
                conditionValues += document.getElementById("Project").value+",";
                conditionOperators += "eq,";
            }
            if(document.getElementById("Machine").value != "") {
                conditionNames +="Machine,";
                conditionValues += document.getElementById("Machine").value+",";
                conditionOperators += "eq,";
            }
            
            optionName = "Limit";
            optionValue = document.getElementById("Limit")[document.getElementById("Limit").selectedIndex].value;
            
            //alert("conditionNames="+conditionNames);
            //alert("conditionValues="+conditionValues);
            //alert("conditionOperators="+conditionOperators);
            //alert("optionName="+optionName);
            //alert("optionValue="+optionValue);
            
            
            document.getElementById("conditionNames").value=conditionNames;
            document.getElementById("conditionValues").value=conditionValues;
            document.getElementById("conditionOperators").value=conditionOperators;
            document.getElementById("optionName").value=optionName;
            document.getElementById("optionValue").value=optionValue;
            
            
            
            //alert("fieldNames:"+document.getElementById("fieldNames").value);
            //alert("fieldOperators:"+document.getElementById("fieldOperators").value);
        }
        
        
        
        function setFields(){
            //set the fields to display:
            <xsl:for-each select="//Attribute">
            document.getElementById("fieldNames").value += "<xsl:value-of select="Name" />,"
            document.getElementById("fieldOperators").value += ","
            </xsl:for-each>
                        
            document.getElementById("fieldNames").value += "CreationTime,"
            document.getElementById("fieldOperators").value += "Tros,"
        }
        
                
        function setId(id){
            document.getElementById('Account').value = id;
        }
        
        function selectAccount(){
            newWindow('AccountSelect', "select_account.jsp", 750, 500);
        }
    </script>

    <style type="text/css" media="all">

        @import "shared/gold.css";

    </style>
</head>

<body onload="setFields()">

<xsl:call-template name="Header">
    <xsl:with-param name = "myaction">List</xsl:with-param>
    <xsl:with-param name = "myobject">Transaction</xsl:with-param>
</xsl:call-template>

<xsl:call-template name ="Data" />

<xsl:call-template name="SubmitRow" >
    <xsl:with-param name = "myaction">List</xsl:with-param>
    <xsl:with-param name = "myobject">Transaction</xsl:with-param>
</xsl:call-template>

</body>
</html>
</xsl:template>



<xsl:template name = "Data">


    <form method="post" name="inputForm">
        
    <xsl:for-each select="*/child::*">
        <xsl:if test="name(./*[1]) != 'Attribute'">
        <div class="row">
        <xsl:call-template name = "NameCombo"/>           
        </div>
        </xsl:if>
    </xsl:for-each>
    
    
    
    <div class="row">
    <label for="StartTime" class="rowLabel">Start (YYYY-MM-DD):</label>
    <input type="text" name="StartTime" id="StartTime" value="-infinity" size="30" maxlength=""/>
    </div>
    
    <div class="row">
    <label for="EndTime" class="rowLabel">End (YYYY-MM-DD):</label>
    <input type="text" name="EndTime" id="EndTime" value="infinity" size="30" maxlength=""/>
    </div>
    
    <div class="row">
    <label class="rowLabel" for="Account">Account Id:</label>
    <input maxlength="" size="30" value="" id="Account" name="Account" type="text"/>
    <input onClick="selectAccount()" value="Select..." id="selectAccountButton" name="selectAccountButton" type="button"/>
    </div>
    
    <div class="row">
    <label for="JobId" class="rowLabel">Job Id:</label>
    <input type="text" name="JobId" id="JobId" value="" size="30" maxlength=""/>
    </div>
    
    <div class="row">
    <label for="User" class="rowLabel">User:</label>
    <input type="text" name="User" id="User" value="" size="30" maxlength=""/>
    </div>
    
    <div class="row">
    <label for="Project" class="rowLabel">Project:</label>
    <input type="text" name="Project" id="Project" value="" size="30" maxlength=""/>
    </div>
    
    <div class="row">
    <label for="Machine" class="rowLabel">Machine:</label>
    <input type="text" name="Machine" id="Machine" value="" size="30" maxlength=""/>
    </div>
    
    <div class="row">
        <div class="multiSelect" id="LimitMultiSelect">
            <label for="Limit" class="rowLabel">Results:</label>
            <select name="Limit" id="Limit">
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="100">100</option>
            </select>
        </div>
    </div>
        
    <input type="hidden" name="conditionNames" id="conditionNames" value="" />
    <input type="hidden" name="conditionValues" id="conditionValues" value="" />
    <input type="hidden" name="conditionOperators" id="conditionOperators" value="" />
    <input type="hidden" name="fieldNames" id="fieldNames" value="" />
    <input type="hidden" name="fieldOperators" id="fieldOperators" value="" />
    <input type="hidden" name="optionName" id="optionName" value="" />
    <input type="hidden" name="optionValue" id="optionValue" value="" />
    
    </form>
</xsl:template>


<xsl:template name="NameCombo">
    <div class="multiSelect" id="{name(./*[1])}MultiSelect">
    <label for="name(./*[1])" class="rowLabel">
    <xsl:value-of select="name(./*[1])"/>s:
    </label>
    <select name="{name(./*[1])}" id="{name(./*[1])}" >
    <option value="">ANY</option>
    <xsl:if test="count(./*)>0">
        <xsl:for-each select="./child::*">
            <xsl:sort select = "./Name" />
            <xsl:if test="./Name != '' and ./Name != ' '">
                <option value="{./Name}"><xsl:value-of select="./Name"/></option>
            </xsl:if>
        </xsl:for-each>
    </xsl:if>
    </select>
    </div>
</xsl:template>


</xsl:stylesheet>
