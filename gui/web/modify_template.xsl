<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : modify_template.xsl
    Created on : September 2003
    Author     : zjohns, Geoff Elliott
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="templates.xsl" />
    <xsl:output method="xhtml" indent = "yes"/>

<xsl:template match = "/" >

<body onload="initVars();initConditons();">
<xsl:call-template name="Header" />

<!--xsl:call-template name="RequiredDescription" /-->
<xsl:call-template name="PrimaryKeyDescription" />

<form method="post" name="inputForm">

<xsl:for-each select="//Attribute">
<xsl:choose>
<xsl:when test="./Name != 'Active'">
<xsl:apply-templates select="."/>
</xsl:when>
</xsl:choose>
</xsl:for-each>

<xsl:call-template name="SubmitRow" />
<!-- these hidden fields will automatically be set in the conditionBean upon form submit -->
<input type="hidden" name="fieldNames" id="fieldNames" value="" />
<input type="hidden" name="fieldValues" id="fieldValues" value="" />
<input type="hidden" name="conditionNames" id="conditionNames" value="" />
<input type="hidden" name="conditionValues" id="conditionValues" value="" />
<input type="hidden" name="viewType" id="viewType" value="manage" />
<input type="hidden" name="thisAction" id="thisAction" value="modify_object" />
<input type="hidden" name="myaction" id="myaction" value="Modify" />

</form>

</body>
</xsl:template>


</xsl:stylesheet>