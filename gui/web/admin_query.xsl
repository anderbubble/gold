<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : input.xsl
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
    <title>Query</title>
    <script language="Javascript1.3" type="text/javascript" src="shared/admin_searchConditions.js">
    //comments
    </script>
    <script language="Javascript1.3" type="text/javascript" src="shared/admin_fields.js">
    //comments
    </script>
    <script language="Javascript1.3" type="text/javascript" src="shared/util.js">
    //comments
    </script>
    <script language="Javascript1.3" type="text/javascript" src="shared/sniffer.js">
    //comments
    </script>
    <script language="Javascript1.3" type="text/javascript" src="shared/admin_options.js">
    //comments
    </script>
    <script type="text/javascript">
        //array of operators for what to display
        var operators = new Array();
        operators[0] = new Array("", "");
        operators[1] = new Array("sort-asc", "Sort");
	operators[2] = new Array("sort-desc","Tros");
	operators[3] = new Array("unique","distinct");
	operators[4] = new Array("groupby","GroupBy");
        operators[5] = new Array("max","Max");
        operators[6] = new Array("min","Min");
        operators[7] = new Array("sum","Sum");
        operators[8] = new Array("avg","Average");
    
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
    <BODY>
    <center><h2><xsl:value-of select="//myaction"/><xsl:text> </xsl:text><xsl:value-of select="//myobject"/>s</h2></center>
    <center>
    <xsl:call-template name = "Data" /> 
    </center>
    </BODY>
    </html>    
</xsl:template>


<xsl:template name = "Data">
    <FORM METHOD="POST" NAME="inputForm">
    <center>
    <xsl:call-template name = "Fields"/>
    <br/><br/>
    <xsl:call-template name = "Conditions"/>
    <br/><br/>
    <xsl:call-template name = "Options"/>
    <br/><br/>
    Show Hidden?
    <input type="checkbox" name="hidden" id="hiddenYes" value="True"/>
    <hr/>
    <input type="button" name="create" id="create" value="{//myaction} {//myobject}s" onClick="submitForm()"/>
    </center>
    <div id="hiddenFieldFields">
    <input type="hidden" id ="fieldNames" name="fieldNames" value=""/>
    <input type="hidden" id ="fieldOperators" name="fieldOperators" value=""/>
    </div>
    </FORM>
</xsl:template>


<xsl:template name = "Fields">
    <b>Fields to Display</b>
    <div class="fieldqueryrow">
        <div class="header fieldName">Name</div><div class="header fieldOperator">Operator</div>
    </div>
    <div id = "fields">
        <xsl:call-template name="fieldCombos"/>
    </div>
</xsl:template>


<!--onChange="setOperators(this[selectedIndex].text);"-->
<xsl:template name = "fieldCombos">
    <div class="fieldqueryrow" id="field1">
        <div id="1fieldNameDiv" class="fieldName"><select name="1fieldName" id="1fieldName" onChange="setOperators(event);">
            <option value=""></option>
            <xsl:for-each select="//Attribute">
            <option value="{Name}"><xsl:value-of select="Name"/></option>
            </xsl:for-each>
        </select></div>
        <div id="1fieldOperatorDiv" class="fieldOperator"><select name="1fieldOperator" id="1fieldOperator" >
            <option VALUE="" SELECTED="true"></option>
            <option VALUE="Sort">sort-asc</option>
            <option VALUE="Tros">sort-desc</option>
            <option VALUE="Distinct">unique</option>
            <option VALUE="GroupBy">groupby</option>
        </select></div>
    </div>
</xsl:template>


</xsl:stylesheet> 
