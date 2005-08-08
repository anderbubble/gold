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
    <xsl:output method="xhtml" indent = "yes"/>

<xsl:template match = "/" >

<html xmlns="http://www.w3.org/1999/xhtml" lang="en">

<head>
    <title>GOLD: </title>

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

<xsl:call-template name="Header"/>
 <form method="post" name="inputForm">
 <xsl:if test="//myaction = 'Undo'">
     <div class="row">
        <label class="rowLabel" for="RequestId">RequestId:</label>
        <input maxlength="" size="30" value="" id="RequestId" name="RequestId" type="text"/>
     </div>
 </xsl:if>
 </form>
<xsl:call-template name="SubmitRow" />

</body>
</html>
</xsl:template>







</xsl:stylesheet>