<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : create_template.xsl
    Created on : September 2003
    Author     : zjohns, Geoff Elliott
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="templates.xsl" />
    <xsl:output method="xhtml" indent = "yes"/>

<xsl:template match = "/" >

<html xmlns="http://www.w3.org/1999/xhtml" lang="en">

<head>
    <title>GOLD: <xsl:value-of select="//myaction"/> New <xsl:value-of select="//myobject"/></title>

    <script language="Javascript" type="text/javascript">
        function submitForm(){
            if(checkRequiredFields()){
                document.inputForm.target = "results";
                document.inputForm.action = "results.jsp";
                document.inputForm.submit();
            }
        }
        
        function checkRequiredFields(){
            if(document.getElementById("UserId").value == ""){
                alert("Please enter a user.");
                document.getElementById("UserId").focus();
                return false;
            }else if(document.getElementById("ProjectId").value == ""){
                alert("Please enter a project.");
                document.getElementById("ProjectId").focus();
                return false;
            }else if(document.getElementById("MachineName").value == ""){
                alert("Please enter a machine.");
                document.getElementById("MachineName").focus();
                return false;
            }else if(document.getElementById("WallDuration").value == ""){
                alert("Please enter the time.");
                document.getElementById("WallDuration").focus();
                return false;
            }
            return true;
        }
    </script>

    <style type="text/css" media="all">

        @import "shared/gold.css";

    </style>
</head>

<body>

<xsl:call-template name="Header" />
    <!--xsl:with-param name = "myaction" select="'Quote'"/>
    <xsl:with-param name = "myobject" select="'Job'"/>
</xsl:call-template-->

<xsl:call-template name="RequiredDescription" />
<xsl:call-template name="PrimaryKeyDescription" />

<form method="post" name="inputForm">

<xsl:if test="//myaction = 'Reserve'">
<div class="row">
<label class="rowLabel" for="JobId"><span class="required">*</span>JobId:</label>
<input maxlength="40" size="30" value="" id="JobId" name="JobId" type="text"/>
</div>
</xsl:if>
<div class="row">
<label class="rowLabel" for="UserId"><span class="required">*</span>User Name:</label>
<input maxlength="40" size="30" value="" id="UserId" name="UserId" type="text"/>
</div>

<div class="row">
<label class="rowLabel" for="ProjectId"><span class="required">*</span>Project Name:</label>
<input maxlength="40" size="30" value="" id="ProjectId" name="ProjectId" type="text"/>
</div>
<div class="row">
<label class="rowLabel" for="MachineName"><span class="required">*</span>Machine Name:</label>
<input maxlength="40" size="30" value="" id="MachineName" name="MachineName" type="text"/>
</div>
<div class="row">
<label class="rowLabel" for="WallDuration"><span class="required">*</span>Wallclock Time in seconds:</label>
<input maxlength="" size="30" value="" id="WallDuration" name="WallDuration" type="text"/>
</div>

<xsl:for-each select="//Resource/Data/*">
<div class="row">
<label class="rowLabel" for="{Name}"><xsl:value-of select="Name" />:</label>
<input maxlength="" size="30" value="" id="{Name}" name="{Name}" type="text"/>
</div>
</xsl:for-each>


<xsl:for-each select="//Other/Data/*">
<div class="row">
<label class="rowLabel" for="{Type}"><xsl:value-of select="Type" />:</label>
<input maxlength="" size="30" value="" id="{Type}" name="{Type}" type="text"/>
</div>
</xsl:for-each>


<xsl:if test="//myaction = 'Quote'">
<div class="row">
<strong class="rowLabel">Guarantee the charge rates?</strong>
<input value="True" id="GuaranteeYes" name="Guarantee" type="radio"/>
<label for="GuaranteeYes">Yes</label>
<input checked="true" value="False" id="GuaranteeNo" name="Guarantee" type="radio"/>
<label for="GuaranteeeNo">No</label>
</div>
</xsl:if>


<xsl:call-template name="SubmitRow" />
    <!--xsl:with-param name = "myaction" select="'Quote'"/>
    <xsl:with-param name = "myobject" select="'Job'"/>
</xsl:call-template-->

</form>

</body>
</html>
</xsl:template>


</xsl:stylesheet>