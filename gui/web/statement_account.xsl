<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : display_balance.xsl
    Created on : February 23, 2004, 11:31 AM
    Author     : d3l028
    Description:
        Purpose of transformation follows.
-->


<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="templates.xsl" />
    <xsl:output method="html"  indent = "yes"/>

<xsl:template match = "/" >

<html xmlns="http://www.w3.org/1999/xhtml" lang="en">

<head>
    <title>GOLD: Display Balance</title>

    <script language="Javascript1.3" type="text/javascript" src="shared/util.js">
    //stuff
    </script>
    <script language="Javascript" type="text/javascript">
        function submitForm(){
            document.inputForm.action="statement_account.jsp?display=true";
            document.inputForm.target="action";
            document.inputForm.submit();
        }
        
        function initVars(){
            <xsl:if test="//Display">
            document.getElementById('Id').value = "<xsl:value-of select="//Display/Id"/>";
            document.getElementById('StartTime').value = "<xsl:value-of select="//Display/StartTime"/>";
            document.getElementById('EndTime').value = "<xsl:value-of select="//Display/EndTime"/>";
            if('<xsl:value-of select="//Display/Itemize"/>' == 'True'){
                document.getElementById('ItemizeYes').checked = true;
                document.getElementById('ItemizeNo').checked = false;
            }else{   
                document.getElementById('ItemizeYes').checked = false;
                document.getElementById('ItemizeNo').checked = true;
            }
            if(<xsl:value-of select="//Display/DisplayTime"/> == document.getElementById("DisplayTimeSeconds").value){
                document.getElementById("DisplayTimeSeconds").checked = true;
                document.getElementById("DisplayTimeHours").checked = false;
            }else {
                document.getElementById("DisplayTimeHours").checked = true;
                document.getElementById("DisplayTimeSeconds").checked = false;
            }
            
            </xsl:if>
        }
        
        function setId(id){
            document.getElementById('Id').value = id;
        }
        
        function selectAccount(){
            newWindow('AccountSelect', "select_account.jsp", 1050, 500);
        }
        

    </script>

    <style type="text/css" media="all">

        @import "shared/gold.css";

        .multiSelect {
            margin-top: 1em;
        }

        .multiSelect label {
            font-weight: bold;
            display: block;
        }

        .include {
            width: 100%;
        }

        .include {
            float: left;
        }


        .include select{
            width: 100%;
        }

        #includeHead, #excludeHead {
            border-bottom: 1px solid black;
            margin-top: 10px;
            margin-bottom: 2px;
            font-weight: bold;
            font-size: 110%;
        }

        html>body #includeHead, html>body #excludeHead {
            margin-top: 0px;
        }
        
        th {
          font-weight: bold;
	  text-align: center;
          vertical-align: bottom;
          background-color: #EFEBAB;
          white-space: nowrap;
        }
        
        table, th, td {
          border: 1px solid black;
          border-collapse: collapse;
        }
        
        th, td {
          padding: 6px;
          font-size: 70%;
        }
        
        .amount {
          text-align: right;
        }
        
        .totals td {
       	  border-top: 3px double black;
       	  font-weight: bold;
	  background-color: #C1DDFD;
       	}
       	
       	#available {
       	  font-size: 80%;
       	  margin-top: 2em;
       	  line-height: 150%;
       	}
       	
       	table, #available {
       	  margin-left: 82px;
       	}
       	
       	#accounts {
       	  margin-top: 2em;
       	}

    </style>
</head>

<body onload="initVars()">

<xsl:call-template name="Header">
    <xsl:with-param name="myaction">Account</xsl:with-param>
    <xsl:with-param name="myobject">Statement</xsl:with-param>
</xsl:call-template>

<xsl:call-template name="RequiredDescription" />
<xsl:call-template name = "Data" />
<xsl:call-template name="SubmitRow">
    <xsl:with-param name="myaction">Account</xsl:with-param>
    <xsl:with-param name="myobject">Statement</xsl:with-param>
</xsl:call-template>

<xsl:if test="//Display">
<xsl:call-template name = "results" />
</xsl:if>
</body >
</html>
</xsl:template>


<xsl:template name = "Data">
    <form method="post" name="inputForm">
    <div class="row">
    <label class="rowLabel" for="Id"><span class="required">*</span>Account Id:</label>
    <input maxlength="" size="30" value="" id="Id" name="Id" type="text"/>
    <input onClick="selectAccount()" value="Select..." id="selectAccountButton" name="selectAccountButton" type="button"/>
    </div>
    
    <div class="row">
    <label class="rowLabel" for="StartTime">Start Date:</label>
    <input maxlength="" size="30" value="" id="StartTime" name="StartTime" type="text"/>
    </div>
    <div class="row">
    <label class="rowLabel" for="EndTime">End Date:</label>
    <input maxlength="" size="30" value="" id="EndTime" name="EndTime" type="text"/>
    </div>
    <div class="row">
    <strong class="rowLabel">Itemize?</strong>
    <input checked="true" value="True" id="ItemizeYes" name="Itemize" type="radio"/>
    <label for="ItemizeYes">Yes</label>
    <input value="False" id="ItemizeNo" name="Itemize" type="radio"/>
    <label for="ItemizeNo">No</label>
    </div>
    <div class="row">
    <strong class="rowLabel">Display Time in:</strong>
    <input value="3600" id="DisplayTimeHours" name="DisplayTime" type="radio"/>
    <label for="DisplayTimeHours">Hours</label>
    <input checked="True" value="1" id="DisplayTimeSeconds" name="DisplayTime" type="radio"/>
    <label for="DisplayTimeSeconds">Seconds</label>
    </div>
    
    </form>
</xsl:template>





<xsl:template name="results">
    <!-- variables to store tallys used in page to display subtotals, amounts, and available amounts -->
    <xsl:variable name="beginningBalance">
      <xsl:if test="string-length(//BeginningBalance//Amount) != 0"><xsl:value-of select="//BeginningBalance//Amount" /></xsl:if>
      <xsl:if test="string-length(//BeginningBalance//Amount) = 0">0</xsl:if>
    </xsl:variable>
    <xsl:variable name="totalCredits">
      <xsl:if test="string-length(//TotalCredits//Delta) != 0"><xsl:value-of select="//TotalCredits//Delta" /></xsl:if>
      <xsl:if test="string-length(//TotalCredits//Delta) = 0">0</xsl:if>
    </xsl:variable>
    <xsl:variable name="totalDebits">
      <xsl:if test="string-length(//TotalDebits//Delta) != 0"><xsl:value-of select="//TotalDebits//Delta" /></xsl:if>
      <xsl:if test="string-length(//TotalDebits//Delta) = 0">0</xsl:if>
    </xsl:variable>
    <xsl:variable name="endingBalance">
      <xsl:if test="string-length(//EndingBalance//Amount) != 0"><xsl:value-of select="//EndingBalance//Amount" /></xsl:if>
      <xsl:if test="string-length(//EndingBalance//Amount) = 0">0</xsl:if>
    </xsl:variable>
    
    <div id="available">
    <strong>Beginning Balance:</strong><xsl:text>&#160;</xsl:text><xsl:value-of select="format-number($beginningBalance div number(//Display/DisplayTime), '#.##')" /><br />
    <strong>Total Credits:</strong><xsl:text>&#160;</xsl:text><xsl:value-of select="format-number($totalCredits div number(//Display/DisplayTime), '#.##')" /><br />
    <strong>Total Debits:</strong><xsl:text>&#160;</xsl:text><xsl:value-of select="format-number($totalDebits div number(//Display/DisplayTime), '#.##')" /><br />
    <strong>Ending Balance:</strong><xsl:text>&#160;</xsl:text><xsl:value-of select="format-number($endingBalance div number(//Display/DisplayTime), '#.##')" />
    </div>
    
    <xsl:if test="//Display/Itemize = 'True'">

        <hr />
        <div id="available">
        <strong>Credits:</strong>
        </div>
        <table cellspacing="0" id="accounts">
        <tr><th>Transaction</th><th>Job Id</th><th>Time</th><th>Description</th><th>Amount</th></tr>
        <xsl:for-each select="//Display/Credits/Data/Transaction">
            <tr>
            <td><xsl:value-of select="Action" /></td>
            <td><xsl:value-of select="Child" /></td>
            <td><xsl:value-of select="CreationTime" /></td>
            <td><xsl:value-of select="Description" /></td>
            <td class="amount"><xsl:value-of select="format-number(number(Delta) div number(//Display/DisplayTime), '#.##')" /></td>
            </tr>
        </xsl:for-each>
        <tr class="totals">
            <td colspan="4" class="Total">Total:</td>
            <td class="amount"><xsl:value-of select="format-number($totalCredits div number(//Display/DisplayTime), '#.##')" /></td>
        </tr>
        </table>
        
        <div id="available">
        <strong>Debits:</strong>
        </div>
        <table cellspacing="0" id="accounts">
        <tr><th>Transaction</th><th>Job Id</th><th>Time</th><th>Description</th><th>Amount</th></tr>
        <xsl:for-each select="//Display/Debits/Data/Transaction">
            <tr>
            <td><xsl:value-of select="Action" /></td>
            <td><xsl:value-of select="Child" /></td>
            <td><xsl:value-of select="CreationTime" /></td>
            <td><xsl:value-of select="Description" /></td>
            <td class="amount"><xsl:value-of select="format-number(number(Delta) div number(//Display/DisplayTime), '#.##')" /></td>
            </tr>
        </xsl:for-each>
        <tr class="totals">
            <td colspan="4" class="Total">Total:</td>
            <td class="amount"><xsl:value-of select="format-number($totalDebits div number(//Display/DisplayTime), '#.##')" /></td>
        </tr>
        </table>
    
    </xsl:if>
  

</xsl:template>




<!-- same as one in templates but without the hr -->
<xsl:template name="SubmitRow">
    <xsl:param name = "myaction" select="//myaction"/>
    <xsl:param name = "myobject" select="//myobject"/>
    <div id="submitRow">
        <input type="button" name="create" id="formSubmit" value="{$myaction} {$myobject}(s)" onClick="submitForm()" />
    </div>
</xsl:template>


</xsl:stylesheet>
