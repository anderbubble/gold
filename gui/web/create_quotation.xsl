<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : create_quotation.xsl
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
    <title>GOLD: Create New Quotation</title>

    <script language="Javascript1.3" type="text/javascript" src="shared/util.js">//stuff</script>
    <script language="Javascript" type="text/javascript">
        function submitForm(){
            if(checkRequiredFields()){
                document.inputForm.target = "results";
                document.inputForm.action = "results.jsp";
                document.inputForm.submit();
            }
        }
        
        function checkRequiredFields(){
            var invalidField;
            //if(document.getElementById("JobId").value == "") {
            //    invalidField = document.getElementById("JobId");
            //    alert("Please fill in a Job Id.");
            //}
            //else 
            if(document.getElementById("EndTime").value == "") {
                invalidField = document.getElementById("EndTime");
                alert("Please fill in a Expiration Time.");
            }
            //else if(document.getElementById("Amount").value == "") {
            //    invalidField = document.getElementById("Amount");
            //    alert("Please fill in an Amount.");
            //}
            else if(document.getElementById("User")[document.getElementById("User").selectedIndex].value == "") {
                invalidField = document.getElementById("User");
                alert("Please select a User.");
            }
            else if(document.getElementById("Project")[document.getElementById("Project").selectedIndex].value == "") {
                invalidField = document.getElementById("Project");
                alert("Please select a Project.");
            }
            else if(document.getElementById("Machine")[document.getElementById("Machine").selectedIndex].value == "") {
                invalidField = document.getElementById("Machine");
                alert("Please select a Machine.");
            }
            
            if(invalidField){
                invalidField.focus();
                return false;
            }
            else 
                return true;
        }
    </script>

    <style type="text/css" media="all">

        @import "shared/gold.css";

    </style>
</head>

<body>

<xsl:call-template name="Header">
    <xsl:with-param name = "myaction">Create</xsl:with-param>
    <xsl:with-param name = "myobject">Quotation</xsl:with-param>
</xsl:call-template>
<xsl:call-template name="RequiredDescription" />
<xsl:call-template name="PrimaryKeyDescription" />
<xsl:call-template name ="Data" />

<xsl:call-template name="SubmitRow" >
    <xsl:with-param name = "myaction">Create</xsl:with-param>
    <xsl:with-param name = "myobject">Quotation</xsl:with-param>
</xsl:call-template>

</body>
</html>
</xsl:template>



<xsl:template name = "Data">
    <form method="post" name="inputForm">
    
    <div class="row">
    <label class="rowLabel" for="Amount">Amount:</label>
    <input maxlength="" size="30" value="" id="Amount" name="Amount" type="text"/>
    </div>
        
    <div class="row">
    <label class="rowLabel" for="EndTime">
    <span class="required">*</span>End Time:</label>
    <input maxlength="" size="30" value="" id="EndTime" name="EndTime" type="text"/>
    </div>

    <div class="row">
    <label class="rowLabel" for="WallDuration">WallTime Estimate:</label>
    <input maxlength="" size="30" value="" id="WallDuration" name="WallDuration" type="text"/>
    </div>

    
    <div class="row">
    <label class="rowLabel" for="Used">Number of Times Used:</label>
    <input maxlength="" size="30" value="0" id="Used" name="Used" type="text"/>
    </div>
    
    <div class="row">
    <label class="rowLabel" for="Description">Description:</label>
    <input maxlength="80" size="30" value="" id="Description" name="Description" type="text"/>
    </div>
    
    <!--div class="row" style="width: 45em; padding-left: 2.5em;"-->
    <xsl:for-each select="*/child::*">
        <div class="row">
            <xsl:call-template name = "NameCombo"/>          
        </div> 
    </xsl:for-each>
    <!--/div-->
    </form>
</xsl:template>


<xsl:template name="NameCombo">
    <div class="multiSelect" id="{name(./*[1])}MultiSelect">
    <label for="{name(./*[1])}">
    <xsl:attribute name="class">rowLabel</xsl:attribute>
    <span class="required">*</span><xsl:value-of select="name(./*[1])"/>s:
    </label>
    <select name="{name(./*[1])}" id="{name(./*[1])}" >
        <option value="">Select <xsl:value-of select="name(./*[1])"/> ...</option>
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