<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : modify_select.xsl
    Created on : September 30, 2003, 5:51 PM
    Author     : d3l028
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="templates.xsl" />
    <xsl:output method="xhtml" indent = "yes"/>

    <xsl:template match="/">

    <html xmlns="http://www.w3.org/1999/xhtml" lang="en">
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta http-equiv="pragma" content="no-cache"/>

    <title>Request Results</title>

    <script language="Javascript1.3" type="text/javascript" src="shared/modify_select.js">//comments</script>    
    <script language="Javascript" type="text/javascript">
        //need to have this here, or above import won't work for some wierd-o reason.
    </script>
    <script language="Javascript1.3" type="text/javascript" src="shared/util.js"></script>
    <script language="Javascript" type="text/javascript">
        //need to have this here, or above import won't work for some wierd-o reason.
    </script>
<script language="Javascript" type="text/javascript">

        var checkBoxIds = new Array();
        var conditionNames = new Array();
        var dataTypes = new Array();
        var primaryKeyValues;
        var primaryKeyNames;
        <xsl:for-each select="*[1]"><!-- for first data only-->
            primaryKeyNames = "<xsl:value-of select="*[1]/PrimaryKeyNames" />"
            primaryKeyValues = new Array(<xsl:value-of select="count(*)" />);
            <xsl:for-each select="*"><!-- for each first data's children-->
                <xsl:if test="count(./*)>=1 and ./PrimaryKeyValues"> <!--if there are any attributes-->
                    <xsl:variable name = "counter"><xsl:number /></xsl:variable>
                    checkBoxIds[<xsl:value-of select="$counter" />] = "deletePrimaryKey<xsl:value-of select="$counter" />"
                    primaryKeyValues[<xsl:value-of select="$counter" />] = "<xsl:value-of select="./PrimaryKeyValues" />"
                    
                </xsl:if>
            </xsl:for-each><!-- ends for each on the first dataOperator's children-->
        </xsl:for-each><!-- ends for each on the first data-->

        <xsl:for-each select="*[1]"><!--firstData-->
            <xsl:for-each select="*[1]"><!--just the first Object under data-->
                <xsl:for-each select="*"><!--every attribute under the Object-->
                  <xsl:if test="not(name(./@*[1])='Hidden') and count(./child::*) = 0">
                    conditionNames[conditionNames.length] = '<xsl:value-of select="name(.)"/>';
                  </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:for-each>
        
        
        <xsl:for-each select="//Attributes/Data/Attribute"><!--firstData-->
            dataTypes[dataTypes.length] = '<xsl:value-of select="DataType"/>';
        </xsl:for-each>

        function sort(fieldName, fieldOperator){
            document.searchForm.fieldNames.value = fieldName;
            document.searchForm.fieldOperators.value = fieldOperator;
            document.searchForm.submit();
        }
        function initVars(){
            var combo = document.searchForm.conditionNames;
            var initValue = "<xsl:value-of select="//ConditionName"/>";
            initCombo(combo, initValue);
            
            setOperators(i-1);
            combo = document.searchForm.conditionOperators;
            initValue = "<xsl:value-of select="//ConditionOperator"/>";
            initCombo(combo, initValue);
        }
        function selectAccount(id){
            window.opener.setId(id);
            window.close();
        }
        
        

    </script>

    <style type="text/css" media="all">

        @import "shared/gold.css";

        body {
            background-color: white;
        }

        h1 {
            font-size: 110%;
        }

        table#results {
            border-top: 1px solid black;
            border-left: 1px solid black;
            margin: auto;
            margin-top: 1em;
        }

        table#constrainResults {
            margin: auto;
            /*background-color: #EFEBAB;
            border: 1px solid black;Machine
            padding: 5px;*/
        }

        table#results th, table#results td {
            border-right: 1px solid black;
            border-bottom: 1px solid black;
            font-size: 70%;
        }

        table#constrainResults th, table#constrainResults td {
            font-size: 70%;
            border-right: none;
            border-bottom: none;
        }

        table#results th, table#constrainResults th {
            font-weight: bold;
            text-align: center;
            vertical-align: bottom;
            background-color: #EFEBAB;
            padding: 0px;
            white-space: nowrap;
        }

        table#constrainResults th {
            background-color: transparent;
        }

        table#results th div {
            border: 1px outset #EFEBAB;
            cursor: default;
        }

        table#results th div:hover {
            background-color: #FFF9C2;
        }

        table#results th div:active {
            background-color: #E6E396;
            border-style: inset;
        }

        table#results th div, table#results td {
            padding: 6px;
        }

        table#constrainResults th {
            padding: 2px 7px;
        }

        table#constrainResults td {
            padding: 6px;
            text-align: center;
        }

        table#results th.deleteHead div, table#results th.deleteHead div:hover, table#results th.deleteHead div:active {
            background-color: #EFEBAB;
            border-style: solid;
        }

        table#results td, table#constrainResults td {
            vertical-align: top;
        }

        td.deleteCell, td.modifyCell {
            text-align: center;
            background-color: #FFF9C2;
        }

        #searchForm {
            margin: auto;
            font-size: 75%;
            text-align: center;
        }

        #loadForm {
            text-align: center;
        }

        .sortArrow {
            padding-left: 5px;
        }

    </style>
</head>
    <body onload="initVars();">
      
    <xsl:call-template name="Filter" />
    <hr />
    <xsl:call-template name="Inactive" />

    <form method="post" name="loadForm" id="loadForm" target="action">
        <table cellspacing="0" border="0" id="results">
            <xsl:call-template name="tableHeader" />
            <xsl:call-template name="tableContent" />
        </table>
        <input type="hidden" id ="conditionNames" name="conditionNames" value=""/>
        <input type="hidden" id ="conditionValues" name="conditionValues" value=""/>
        <input type="hidden" id ="conditionOperators" name="conditionOperators" value=""/>
        <input type="hidden" id ="conjunctions" name="conjunctions" value=""/>
        <input type="hidden" id ="groups" name="groups" value=""/>
        <input type="hidden" name="myobject" >
        <xsl:attribute name="value"><xsl:value-of select="//myobject" /></xsl:attribute>
        </input>
        <input type="hidden" name="myaction" >
        <xsl:attribute name="value"><xsl:value-of select="//myaction" /></xsl:attribute>
        </input>

    </form>
</body>
</html>
</xsl:template>



<xsl:template name="headerAction">
    <xsl:choose>
        <xsl:when test="./Name = //FieldName and //FieldOperator = 'Sort'">
          <xsl:attribute name="onclick">sort('<xsl:value-of select="./Name"/>', 'Tros');</xsl:attribute>
          <img src="images/list_arrow_descending.gif" class="sortArrow" width="9" height="9" alt="(Table sorted in based on this column in descending order)" />
        </xsl:when>
        <xsl:when test="./Name = //FieldName and //FieldOperator = 'Tros'">
          <xsl:attribute name="onclick">sort('<xsl:value-of select="./Name"/>', 'Sort');</xsl:attribute>
          <img src="images/list_arrow_ascending.gif" class="sortArrow" width="9" height="9" alt="(Table sorted in based on this column in ascending order)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="onclick">sort('<xsl:value-of select="./Name"/>', 'Sort');</xsl:attribute>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>





<xsl:template name="Filter">
    <form method="post" name="searchForm" id="searchForm">
    <select name="conditionNames" id="conditionNames" onchange="setOperators(this.selectedIndex-1)">
        <option value=""></option>
        <xsl:for-each select="//Attributes/Data/Attribute">
            <xsl:if test="not(name(./@*[1])='Hidden')">
            <option value="{Name}">
            <xsl:if test="Name = //ConditionName">
                <xsl:attribute name="selected">true</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="Name"/>
            </option>
            </xsl:if>
        </xsl:for-each>
    </select>

    <select name="conditionOperators" id="conditionOperators">
        <option value=""></option>
    </select>

    <input type="text" name="conditionValues" id="conditionValues" >
        <xsl:attribute name="value"><xsl:value-of select="//ConditionValue"/></xsl:attribute>
    </input>
    <input type="hidden" id ="query" name="query" value="query"/>
    <input type="hidden" id ="fieldNames" name="fieldNames" value=""/>
    <input type="hidden" id ="fieldOperators" name="fieldOperators" value=""/>
    <div style="text-align: center; margin-top: .5em;">
        <input type="button" name="formSubmit" id="formSubmit" value="Search {//myobject}s" onClick="document.searchForm.submit();" />
    </div>
    </form>
</xsl:template>




<xsl:template name="Inactive">
<xsl:if test="(//myobject = 'Quotation' or  //myobject = 'Account' or  //myobject = 'Reservation') and //myaction = 'Delete'">  
    <p id="selectInstructions">To purge <xsl:value-of select="//myobject" />s, press the button below to select all inactive <xsl:value-of select="//myobject" />s and then press the Delete <xsl:value-of select="//myobject" />s button at the bottom of the page</p>
    <div style="text-align: center; margin-top: .5em;">
        <input type="button" name="selectInactive" id="selectInactive" value="Select All Inactive {//myobject}s" onClick="selectInactives()" />
    </div>
</xsl:if>
</xsl:template>




<xsl:template name="tableHeader">
    <xsl:variable name="rowspan">
        <xsl:choose>
          <xsl:when test="count(//Attributes/Data/Attribute) = count(//Attributes/Data/*)">1</xsl:when>
          <xsl:otherwise>2</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <tr class="headerRow">
        <th class="deleteHead" rowspan="{$rowspan}"><div><xsl:text>&#160;</xsl:text></div></th>
                
        <xsl:for-each select="//Attributes/Data/*">
            <xsl:if test="not(name(./@*[1])='Hidden')">
            <th>
            <xsl:if test="not(./Attribute)">
              <xsl:attribute name="rowspan"><xsl:value-of select="$rowspan"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="./Attribute">
              <xsl:attribute name="rowspan">1</xsl:attribute>
              <xsl:attribute name="colspan"><xsl:value-of select="count(./Attribute) - 1"/></xsl:attribute>
            </xsl:if>
            <div>
                <xsl:if test="./Name">
                    <xsl:call-template name="headerAction"/>
                    <xsl:value-of select="./Name"/> 
                </xsl:if>
                <xsl:if test="not(./Name)">
                    <!-- scott wants to say 'Allocations' instead of 'TimePeriods' and 'Subaccounts' insead of 'Accounts' when listing Accounts -->
                    <xsl:choose>
                    <xsl:when test="name(.) = 'AccountAllocation'">Allocations</xsl:when>
                    <xsl:when test="name(.) = 'AccountAccount'">Subaccounts</xsl:when>
                    <xsl:otherwise><xsl:value-of select="substring-after(name(.), //myobject)"/>s</xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </div>
            <xsl:comment>1</xsl:comment>
            </th>
            </xsl:if>
        </xsl:for-each>                
    </tr>
    <xsl:if test="count(//Attributes/Data/Attribute) != count(//Attributes/Data/*)">
        <tr class="headerRow">
            <xsl:for-each select="//Attributes/Data/*">
              <xsl:for-each select="./Attribute">
                <xsl:if test="./Name != //myobject and not(name(./@*[1])='Hidden')">
                    <th>
                    <div><xsl:value-of select="./Name"/></div>
                    <xsl:comment>2</xsl:comment>
                    </th>
                </xsl:if>
              </xsl:for-each>    
            </xsl:for-each>    
        </tr>
    </xsl:if>
</xsl:template>



<xsl:template name="tableContent">
  <xsl:for-each select="Data/*"><!--every Machine-->
    <xsl:if test="name(.) = //myobject">
      <xsl:variable name = "counter"><xsl:number /></xsl:variable>
      <tr id="{$counter}Row">
          <td rowspan="{./MaxChildCount}" class="modifyCell">
            <a href="javascript:selectAccount('{./Id}')">Select</a>
          </td>
        <xsl:call-template name="first-child-content" />
      </tr>  
      <xsl:call-template name="child-content">
        <xsl:with-param name="child-count" select="2"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:for-each>
</xsl:template>



<xsl:template name="child-content">
    <xsl:param name="child-count" />
    <xsl:if test="$child-count &lt;= ./MaxChildCount">
        <tr>
        <xsl:for-each select="*"><!--every child under project that has children (IE Users have ProjectUsers)-->
            <!-- case where there are multiple children-each one gets its own td -->
            <xsl:if test="name(./@*[1])='Link'">
                <!-- if there is one there and this is not the last one-->
                <xsl:choose>
                    <xsl:when test="./*[$child-count] and $child-count != count(./*)">
                        <xsl:for-each select="./*[$child-count]/*">
                            <td>
                            <xsl:if test=".='' or .=' '">  
                                <xsl:text>&#160;</xsl:text>
                            </xsl:if>
                            <xsl:value-of select="."/>
                            </td>
                        </xsl:for-each>
                    </xsl:when>
                    <!-- if is the last one and there are more than one children (first one was already done in first-child-content)-->
                    <xsl:when test="$child-count = count(./*)"><!-- if child-count is the last one -->
                    <!-- old stuff: $child-count = ../MaxChildCount and count(./*) &gt; 1 -->
                        <xsl:for-each select="./*[last()]/*">
                            <xsl:comment>here count:<xsl:value-of select="count(../../*)"/>,  MaxChildCount:<xsl:value-of select="../../../MaxChildCount"/></xsl:comment>
                            <td>
                            <xsl:attribute name="rowspan"><xsl:value-of select="../../../MaxChildCount - count(../../*) +1" /></xsl:attribute>
                            
                            <xsl:if test=".='' or .=' '">  
                                <xsl:text>&#160;</xsl:text>
                            </xsl:if>
                            <xsl:value-of select="."/>
                            </td>
                        </xsl:for-each>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
        </tr>
        <xsl:call-template name="child-content">
            <xsl:with-param name="child-count" select="$child-count + 1"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>



<xsl:template name="first-child-content">
    <xsl:for-each select="*"><!--every child under project that has children (IE Users have ProjectUsers)-->
        <!-- for just the first subchild of eache project's children  (IE first ProjectUser under Users, first ProjectMachine under Machines...)-->
        <xsl:choose>
          <!-- this will match up to Users, etc-->
          <xsl:when test="name(./@*[1])='Link'">
            <xsl:for-each select="./*[1]/*">
                <xsl:comment>there count:<xsl:value-of select="count(../../*)"/>,  MaxChildCount:<xsl:value-of select="../../../MaxChildCount"/></xsl:comment>
                <td>
                <xsl:attribute name="rowspan">
                    <xsl:if test="count(../../*) = 1"><xsl:value-of select="../../../MaxChildCount" /></xsl:if>
                    <xsl:if test="count(../../*) &gt; 1">1</xsl:if>
                </xsl:attribute>
                <xsl:if test=".='' or .=' '">  
                    <xsl:text>&#160;</xsl:text>
                </xsl:if>
                <xsl:value-of select="."/>
                </td>
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="not(name(./@*[1])='Hidden')">
            <td>
            <xsl:attribute name="rowspan"><xsl:value-of select="../MaxChildCount" /></xsl:attribute>
            <xsl:if test=".='' or .=' '">  
                <xsl:text>&#160;</xsl:text>
            </xsl:if>
            <xsl:value-of select="."/>
            </td>
          </xsl:when>
        </xsl:choose>
    </xsl:for-each>
</xsl:template>



</xsl:stylesheet>

