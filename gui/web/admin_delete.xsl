<!--
    Document   : delete.xsl
    Created on : July 21, 2003, 3:43 PM
    Author     : zjohns
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href  = "admin_searchConditions.xsl" />
    <xsl:include href  = "admin_options.xsl" />
    <xsl:output method="xhtml"/>
    
    
<xsl:template match = "/" >   
    <html>
    <head>
    <title><xsl:value-of select="//myaction"/><xsl:text> </xsl:text><xsl:value-of select="//myobject"/>s</title>
    <script language="Javascript1.3" type="text/javascript" src="shared/admin_searchConditions.js">//comments</script>
    <script language="Javascript1.3" type="text/javascript" src="shared/util.js">//comments</script>
    <script language="Javascript1.3" type="text/javascript" src="shared/sniffer.js">//comments</script>
    <script language="Javascript1.3" type="text/javascript" src="shared/admin_options.js">//comments</script>
    <script type="text/javascript">
   
    
        var attributes = new Array();
        var dataTypes = new Array();
        //first element of each array is the blank (default) selection
        attributes[attributes.length] = ""
        dataTypes[dataTypes.length] = ""
        <xsl:for-each select="//Attribute">
            attributes[attributes.length] = "<xsl:value-of select="./Name"/>"
            dataTypes[dataTypes.length]= "<xsl:value-of select="./DataType"/>"
        </xsl:for-each>
        
        
        function submitForm(){
            //assign to hidden variables:
            setConditionsLists();
            setOptionsList();

            document.inputForm.target = "results";
            document.inputForm.action = "results.jsp";
            document.inputForm.submit();
        }      
          
    </script>
    <style type="text/css" media="all">@import "shared/admin_input.css";</style> 
    </head>
    <BODY>
    <center><h2>
    <xsl:value-of select="//myaction"/><xsl:text> </xsl:text><xsl:value-of select="//myobject"/>s
    </h2></center>
    <xsl:call-template name = "Data" /> 
    </BODY>
    </html>    
</xsl:template>


<xsl:template name = "Data">
    <FORM METHOD="POST" NAME="inputForm">
    <center>
    <xsl:call-template name = "Conditions"/>
    
    <br/><br/>
    <xsl:call-template name = "Options"/>
    <br/>
    <hr/>
    <input type="button" name="create" id="create" value="{//myaction} {//myobject}s" onClick="submitForm()"/>
    </center>
    </FORM>
</xsl:template>



</xsl:stylesheet> 
