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
            document.inputForm.target = "results";
            document.inputForm.action = "results.jsp";
            document.inputForm.submit();
        }
    </script>

    <style type="text/css" media="all">

        @import "shared/gold.css";

    </style>
</head>

<body>

<xsl:call-template name="Header" />

<xsl:call-template name="RequiredDescription" />
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

</form>

</body>
</html>
</xsl:template>


</xsl:stylesheet>