<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : modify.xsl
    Created on : July 21, 2003, 3:43 PM
    Author     : zjohns
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:include href  = "admin_searchConditions.xsl" />
    <xsl:include href  = "admin_options.xsl" />
    <xsl:output method="xhtml"/>
    
    
<xsl:template match = "/" >   
    <html>
    <head>
    <title><xsl:value-of select="//myaction"/><xsl:text> </xsl:text><xsl:value-of select="//myobject"/>s</title>
    <script language="Javascript1.3" type="text/javascript" src="shared/admin_searchConditions.js">//comments</script>
    <script language="Javascript1.3" type="text/javascript" src="shared/admin_fields.js">//comments</script>
    <script language="Javascript1.3" type="text/javascript" src="shared/util.js">//acomments</script>
    <script language="Javascript1.3" type="text/javascript" src="shared/sniffer.js">//comments</script>
    <script language="Javascript1.3" type="text/javascript" src="shared/admin_options.js">//comments</script>
    <script type="text/javascript">
        //array of operators for what to display
        var operators = new Array();
        operators[0] = new Array("", "");
        operators[1] = new Array("=", "Assign");
	operators[2] = new Array("+=","Inc");
	operators[3] = new Array("-=","Dec");
    
        var attributes = new Array();
        var dataTypes = new Array();
        var keys = new Array();
        
        
        //first element of each array is the blank (default) selection
        attributes[attributes.length] = "";
        dataTypes[dataTypes.length] = "";
        keys[keys.length] = new Array(0);
        <xsl:for-each select="//Attribute">
            <xsl:if test="Fixed='False'">
                <xsl:variable name = "arrayLength">0</xsl:variable>
                attributes[attributes.length] = "<xsl:value-of select="./Name"/>"
                dataTypes[dataTypes.length]= "<xsl:value-of select="./DataType"/>"
                keys[keys.length] = new Array(0);
                <xsl:if test = "./Select">
                    <xsl:variable name = "arrayLength" select="count(./Select/Option)" />
                    //alert(<xsl:value-of select = "$arrayLength" />);
                    keys[dataTypes.length-1] = [
                    <xsl:for-each select="./Select/Option">"<xsl:value-of select = "."/>",
                    </xsl:for-each>]
                    //alert("test:" + keys[dataTypes.length][3]);
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
        
        
        function submitForm(){
            //assign to hidden variables:
            setFieldsLists();
            setConditionsLists();
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
    <xsl:call-template name = "Fields"/>
    <br/><br/>
    <xsl:call-template name = "Conditions"/>
    <br/><br/>
    <xsl:call-template name = "Options"/>
    
    <div id="hiddenFieldFields">
    <input type="hidden" id ="fieldNames" name="fieldNames" value=""/>
    <input type="hidden" id ="fieldOperators" name="fieldOperators" value=""/>
    <input type="hidden" id ="fieldValues" name="fieldValues" value=""/>
    </div>
    <br/><br/>
    <hr/> 
    <div id="button"><input type="button" name="modify" id="modify" value="{//myaction} {//myobject}s" onClick="submitForm()"/></div>
    
    </center>
    </form>
</xsl:template>


<xsl:template name = "Fields">
<b>Fields to Modify</b>
<div id="fieldHeaderRow" class="fieldmodifyrow">
  <div class="header fieldName">Name</div><div class="header fieldOperator">Operator</div><div class="header fieldValue">Value</div>
</div>  
<div id = "fields">
<xsl:call-template name="fieldCombos"/>
</div>  
</xsl:template>


<xsl:template name = "fieldCombos">
    <div class="fieldmodifyrow" id="field1">
        <div id="1fieldNameDiv" class="fieldName">
        <select name="1fieldName" id="1fieldName" onChange="setOperators(event);">
            <option value=""></option>
            <xsl:for-each select="//Attribute">
                <xsl:if test="Fixed='False'">
                    <option value="{Name}"><xsl:value-of select="Name"/></option>
                </xsl:if>
            </xsl:for-each>
        </select>
        </div>
        <div id="1fieldOperatorDiv" class="fieldOperator">
        <select name="1fieldOperator" id="1fieldOperator" >
            <option value="" selected="true"></option>
            <option value="Assign">=</option>
        </select>
        </div>
        <div id="1fieldValueDiv" class="fieldValue">
        <input type="text" name="1fieldValue" id="1fieldValue" disabled="yes"/>
        </div>
    </div>
</xsl:template>




</xsl:stylesheet> 
