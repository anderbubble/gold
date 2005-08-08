<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : searchConditions.xsl
    Created on : August 12, 2003, 4:18 PM
    Author     : zjohns
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xhtml"/>

    
<xsl:template name = "Conditions">
    <div id="conditionHeader"><b>Search Conditions</b></div>
    <div id="conditionHeaderRow" class="conditionrow">
        <div class="header conjunction">Conjunction</div><div class="header grouping">Grouping</div>
        <div class="header conditionName">Name</div><div class="header conditionOperator">Operator</div>
        <div class="header conditionValue">Value</div><div class="header ungrouping">Ungroup</div>
    </div>
    <div id = "conditions">
        <xsl:call-template name="conditionCombos"/>
    </div>    
    <div id="hiddenConditionFields">
    <input type="hidden" id ="conditionNames" name="conditionNames" value=""/>
    <input type="hidden" id ="conditionValues" name="conditionValues" value=""/>
    <input type="hidden" id ="conditionOperators" name="conditionOperators" value=""/>
    <input type="hidden" id ="conjunctions" name="conjunctions" value=""/>
    <input type="hidden" id ="groups" name="groups" value=""/>
    </div>
</xsl:template>


<xsl:template name="conditionCombos">
<div class="conditionrow" id="condition1">
    <div id="1conjunctionDiv" class="conjunction"><select NAME="1conjunction" id="1conjunction" disabled="true">
        <option VALUE="" SELECTED="true"></option>
        <option VALUE="And">and</option>
        <option VALUE="Or">or</option>
    </select></div>
    <div id ="1groupingDiv" class="grouping"><select name ="1grouping" id ="1grouping" onchange="setGroup(this);">
        <option VALUE="0" SELECTED="true"></option>
        <option VALUE="1">(</option>
        <option VALUE="2">((</option>
        <option VALUE="3">(((</option>
    </select></div>
    <div id="1conditionNameDiv" class="conditionName"><select name="1conditionName" id="1conditionName" onchange="changeConditions(event);" >
        <option VALUE="" SELECTED="true"></option>
        <xsl:for-each select="//Attribute">
        <option value="{Name}"><xsl:value-of select="Name"/></option>
        </xsl:for-each>
    </select></div>
    <div id ="1conditionOperatorDiv" class="conditionOperator"><select name ="1conditionOperator" id ="1conditionOperator" >
        <option VALUE="" SELECTED="true"></option>
        <option VALUE="EQ">==</option>
        <option VALUE="NE">!=</option>
        <option VALUE="GT"><xsl:text disable-output-escaping="yes">&gt;</xsl:text></option>
        <option VALUE="LT"><xsl:text disable-output-escaping="yes">&lt;</xsl:text></option>
        <option VALUE="GE"><xsl:text disable-output-escaping="yes">&gt;</xsl:text>=</option>
        <option VALUE="LE"><xsl:text disable-output-escaping="yes">&lt;</xsl:text>=</option>
        <option VALUE="Match">matches</option>
    </select></div>
    <div id="1conditionValueDiv" class="conditionValue"><input type="text" name="1conditionValue" id="1conditionValue"/></div>
    <div class="ungrouping"><select name ="1ungrouping" id="1ungrouping" onchange="setGroup(this);">
        <option VALUE="0" SELECTED="true"></option>
        <option VALUE="-1">)</option>
        <option VALUE="-2">))</option>
        <option VALUE="-3">)))</option>
    </select></div>
    <input type="hidden" id ="1group" name="1group" value="0"/>
</div>

</xsl:template>


</xsl:stylesheet> 
