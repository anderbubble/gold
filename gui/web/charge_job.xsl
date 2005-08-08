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

<xsl:call-template name="Header" >
    <xsl:with-param name = "myaction" select="'Charge'"/>
    <xsl:with-param name = "myobject" select="'Job'"/>
</xsl:call-template>

<xsl:call-template name="RequiredDescription" />
<xsl:call-template name="PrimaryKeyDescription" />

<form method="post" name="inputForm">
<!--xsl:call-template name="do-attributes" /-->

<xsl:for-each select="//Attribute">
    <xsl:if test="Name != 'Charge'">
    <xsl:apply-templates select="." />
    </xsl:if>
</xsl:for-each>


<xsl:for-each select="//Resource/Data/*">
    <xsl:if test="not(Name = //Attribute//Name)">
        <div class="row">
        <label class="rowLabel" for="{Name}"><xsl:value-of select="Name" />:</label>
        <input maxlength="" size="30" value="" id="{Name}" name="{Name}" type="text"/>
        </div>
    </xsl:if>
</xsl:for-each>


<xsl:for-each select="//Other/Data/*">
    <xsl:if test="not(Type = //Attribute//Name)">
        <div class="row">
        <label class="rowLabel" for="{Type}"><xsl:value-of select="Type" />:</label>
        <input maxlength="" size="30" value="" id="{Type}" name="{Type}" type="text"/>
        </div>
    </xsl:if>
</xsl:for-each>

<xsl:call-template name="SubmitRow" >
    <xsl:with-param name = "myaction" select="'Charge'"/>
    <xsl:with-param name = "myobject" select="'Job'"/>
</xsl:call-template>

</form>

</body>
</html>
</xsl:template>

</xsl:stylesheet>