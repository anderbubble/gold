<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : admin_options.xsl
    Created on : February 26, 2004, 11:41 AM
    Author     : d3l028
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xhtml"/>

<xsl:template match = "call_options">    
    <html>
    <head>
    <script language="Javascript1.3" type="text/javascript" src="shared/util.js">//comments</script>
    <script language="Javascript1.3" type="text/javascript" src="shared/sniffer.js">//comments</script>
    <script language="Javascript1.3" type="text/javascript" src="shared/admin_options.js">//comments</script>
    <script type="text/javascript">
    function submitForm(){
        //assign to hidden variables:
        setOptionsList();

        document.inputForm.target = "results";
        document.inputForm.action = "results.jsp";
        document.inputForm.submit();
    }
    </script>
    <title><xsl:value-of select="//myaction"/><xsl:text> </xsl:text><xsl:value-of select="//myobject"/>s</title>
    <style type="text/css" media="all">@import "shared/admin_input.css";</style> 
    
    </head>
    <body>
    <center><h2>
    <xsl:value-of select="//myaction"/><xsl:text> </xsl:text><xsl:value-of select="//myobject"/>s
    </h2></center>
    <form method="post" name="inputForm">
    <center>
    <xsl:call-template name = "Options"/>    
    <br/><br/>
    <hr/> 
    <div id="button"><input type="button" name="modify" id="modify" value="{//myaction} {//myobject}s" onClick="submitForm()"/></div>
    
    </center>
    </form>
    </body>
    </html>   
</xsl:template>
    
<xsl:template name = "Options">
    <b>Options</b>
    <div id="optionHeaderRow" class="optionrow">
      <div class="header optionName">Name</div><div class="header optionValue">Value</div>
    </div>  
    <div id = "options">
        <div class="optionrow" id="option1">
            <div id="1optionNameDiv" class="optionName"><!-- -->
            <input type="text" name="1optionName" id="1optionName" onChange="changeOptions(event);"/>
            </div>
            <div id="1optionValueDiv" class="optionValue">
            <input type="text" name="1optionValue" id="1optionValue"  />
            </div>
        </div>
    </div>  
    
    <input type="hidden" id ="optionName" name="optionName" value=""/>
    <input type="hidden" id ="optionValue" name="optionValue" value=""/>
</xsl:template>



</xsl:stylesheet> 
