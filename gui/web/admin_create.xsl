<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : admin_create.xsl
    Created on : July 21, 2003, 3:43 PM
    Author     : zjohns
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="templates.xsl" />
    <xsl:include href  = "admin_options.xsl" />
    <xsl:output method="xhtml"/>

<xsl:template match = "/" >

<html>
<head>
    <title><xsl:value-of select="//myaction"/><xsl:text> </xsl:text><xsl:value-of select="//myobject"/>s</title>
    <script language="Javascript1.3" type="text/javascript" src="shared/sniffer.js">//comments</script>
    <script language="Javascript1.3" type="text/javascript" src="shared/admin_options.js">//comments</script>
    <script language="Javascript1.3" type="text/javascript" src="shared/util.js">//comments</script>
    <script language="Javascript">
        function submitForm(){
            setOptionsList();
            document.inputForm.target = "results";
            document.inputForm.action = "results.jsp";
            document.inputForm.submit();
        }
    </script>
<style type="text/css" media="all">@import "shared/admin_input.css";</style>
</head>
<body>
<center><h2>
<xsl:value-of select="//myaction"/><xsl:text> </xsl:text><xsl:value-of select="//myobject"/>s
</h2></center>
<xsl:call-template name = "Data" />
</body>
</html>
</xsl:template>

<xsl:template name = "Data">
    <form method="post" name="inputForm">
    <center>
    <table cellpadding="3" cellspacing="1">
    <tr><td><center><b>Name</b></center></td><td><center><b>Value</b></center></td><td><center><b>Description</b></center></td></tr>
    <xsl:apply-templates select="//Attribute"/>
    </table>    
    <br/><br/>
    <xsl:call-template name = "Options"/>
    <br/><br/>
    <input type="button" name="create" value="{//myaction} {//myobject}" onClick="submitForm()"/>
    </center>
    </form>
</xsl:template>

<xsl:template match ="Attribute">
     <tr>
        <xsl:apply-templates select="Name"/>
        <xsl:apply-templates select="DataType"/>
        <xsl:apply-templates select="Description"/>
     </tr>
</xsl:template>

<xsl:template match="Name" >
    <td>
        <xsl:value-of select="."/><xsl:text>&#160;</xsl:text><xsl:call-template name="PrimaryKey"/><xsl:call-template name="RequiredField"/>
    </td>
</xsl:template>



<xsl:template match="DataType" >
    <td>
    <xsl:choose >
        <xsl:when test = "../Select" >
            <xsl:apply-templates select="../Select"/>
        </xsl:when>
        <xsl:when test = ".='Boolean'" >
            <xsl:apply-templates select="." mode="radio"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates select="." mode="input"/>
        </xsl:otherwise>
    </xsl:choose>
    </td>
</xsl:template>



<xsl:template match="DataType" mode = "input" >
  <xsl:if test="../Name='Password'">
  <input type="password" name="{../Name}" value='{../DefaultValue}'  />
  </xsl:if>
  <xsl:if test="../Name!='Password'">
  <input type="text" name="{../Name}" value='{../DefaultValue}'  />
  </xsl:if>
</xsl:template>



<xsl:template match="DataType" mode = "radio" >
<xsl:if test="../DefaultValue='True'" >
    <input type="radio" name="{../Name}" value="True" checked="true" />True
    <input type="radio" name="{../Name}" value="False"/>False
</xsl:if>
<xsl:if test="../DefaultValue='False'" >
    <input type="radio" name="{../Name}" value="True"/>True
    <input type="radio" name="{../Name}" value="False" checked="true"/>False
</xsl:if>
</xsl:template>



<xsl:template match="Select" >
<select name="{../Name}">
    <xsl:for-each select="./Option">
        <xsl:copy-of select = "." />
    </xsl:for-each>
</select>
</xsl:template>



<xsl:template match="Description" >
    <td>
        <xsl:value-of select="."/>
    </td>
</xsl:template>

</xsl:stylesheet>
