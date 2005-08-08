<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : modify_template_javascript.xsl
    Created on : December 22, 2003, 11:15 AM
    Author     : d3l028
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text" indent = "yes"/>

<xsl:template match="Data">

    
        function submitForm(){
            //setFieldsLists();
            setConditionsLists();
            //alert("conditionNames: "+ document.getElementById("conditionNames").value);    
            //alert("conditionValues: " + document.getElementById("conditionValues").value);   
            //alert("fieldNames: " + document.getElementById("fieldNames").value);    
            //if(confirm("fieldValues: " + document.getElementById("fieldValues").value)){
                document.inputForm.target = "results";
                document.inputForm.action = "results.jsp";
                document.inputForm.submit();            
            //}
            
        }

        
        var fieldNameIds = new Array();
        
        function initVars(){
          <xsl:for-each select="./*[1]/child::*">
             setValue("<xsl:value-of select="name(.)"/>", "<xsl:value-of select="."/>");
             fieldNameIds[fieldNameIds.length] = "<xsl:value-of select="name(.)"/>";
          </xsl:for-each>
          
        }
        
        
        function setFieldsLists(){
            var fieldNames="";
            var fieldValues="";
                        
            //fields and fieldValues:
            for(var i = 1; i != fieldNameIds.length; i++){
                if(document.getElementById(fieldNameIds[i])){
                    fieldNames  = fieldNames  + "," + fieldNameIds[i];
                    fieldValues = fieldValues + "," + document.getElementById(fieldNameIds[i]).value;
                }
            }
            document.getElementById("fieldNames").value = fieldNames;
            document.getElementById("fieldValues").value = fieldValues;
        }
        
        function addConditionName(name){
            document.getElementById("conditionNames").value += name + ",";
        }
        
        function setConditionsLists(){
            var conditionValues = "";
            var names = new String(document.getElementById("conditionNames").value);
            //alert(names);
            names = names.split(",");
            for(var i = 0; i != names.length; i++){
                //alert(names[i]);
                if(names[i] != "")
                    conditionValues += document.getElementById(names[i]).value + ",";
            }
            document.getElementById("conditionValues").value = conditionValues;
        }
        


</xsl:template>
</xsl:stylesheet> 
