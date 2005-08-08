<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : changeComboJavaScript.xsl
    Created on : August 26, 2004, 12:09 PM
    Author     : d3l028
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html"/>

    <!-- TODO customize transformation rules 
         syntax recommendation http://www.w3.org/TR/xslt 
    -->
    <xsl:template match="/">


        //make arrays of actions for objects:
        <xsl:for-each select="*/Data/Object">
        var <xsl:value-of select="Name" />Array = new Array();</xsl:for-each>


        <xsl:for-each select="//Action">
        <xsl:value-of select="Object" />Array[<xsl:value-of select="Object" />Array.length] = "<xsl:value-of select="Name" />";
        </xsl:for-each>
    
         function changeActionCombo(object){
            var actionArray;
            var found = false;
            <xsl:for-each select="*/Data/Object">
            if(object =="<xsl:value-of select="Name" />"){
                actionArray = <xsl:value-of select="Name" />Array;
                found = true;
            }
            </xsl:for-each>

            var actionCombo = document.inputForm.Action;

            for(i=actionCombo.length-1; i != 0; i--) {
                actionCombo[i] = null;
            }
            if(!actionArray) return;
            for(i=0; i != actionArray.length; i++) {
                actionCombo[i+1] = new Option(actionArray[i], actionArray[i]);
            }
            
        }
    </xsl:template>

</xsl:stylesheet>
