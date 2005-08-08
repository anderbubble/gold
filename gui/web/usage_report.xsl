<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : usage_report.xsl
    Created on : February 23, 2005, 11:31 AM
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
    <title>GOLD: Usage Report</title>

    <script language="Javascript1.3" type="text/javascript" src="shared/util.js">
    //stuff
    </script>
    <script language="Javascript" type="text/javascript">
        function submitForm(){
            document.inputForm.action="usage_report.jsp?display=true";
            document.inputForm.target="action";
            document.inputForm.submit();
        }
        
        function initVars(){
            <xsl:if test="//Display">
            initCombo(document.inputForm.Project, "<xsl:value-of select="//Display/Project"/>");   
            
            document.getElementById('StartTime').value = "<xsl:value-of select="//Display/StartTime"/>";
            document.getElementById('EndTime').value = "<xsl:value-of select="//Display/EndTime"/>";
            
             if(<xsl:value-of select="//Display/DisplayTime"/> == document.getElementById("DisplayTimeSeconds").value){
                document.getElementById("DisplayTimeSeconds").checked = true;
                document.getElementById("DisplayTimeHours").checked = false;
            }else {
                document.getElementById("DisplayTimeHours").checked = true;
                document.getElementById("DisplayTimeSeconds").checked = false;
            }
            </xsl:if>
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

<div class="header">
        <div class="leftFlare"><img src="images/header_flare_left.gif" width="16" height="36" alt="" /></div>
        <div class="rightFlare"><img src="images/header_flare_right.gif" width="16" height="36" alt="" /></div>
        <h1>Usage Report</h1>
</div>

<xsl:call-template name = "Data" />

<div id="submitRow">
   <input type="button" name="create" id="formSubmit" value="Generate Report" onClick="submitForm()" />
</div>

<xsl:if test="//Display">
<xsl:call-template name = "results" />
</xsl:if>
</body >
</html>
</xsl:template>


<xsl:template name = "Data">
    <form method="post" name="inputForm">
    <div class="row">
    <xsl:for-each select="*/child::*">
        <xsl:if test="name(.) != 'Display'">
            <div class="multiSelect" id="{name(./*[1])}MultiSelect">
            <label for="name(./*[1])" class="rowLabel"><xsl:value-of select="name(./*[1])"/>s:</label>
            <select name="{name(./*[1])}" id="{name(./*[1])}" >
            <option value="">All <xsl:value-of select="name(./*[1])"/>s</option>
            <xsl:if test="count(./*)>0">
                <xsl:for-each select="./child::*">
                    <xsl:sort select = "./Name" />
                    <xsl:if test="./Name != '' and ./Name != ' '">
                        <option value="{./Name}"><xsl:value-of select="./Name"/></option>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
            </select>
            </div>         
        </xsl:if>
    </xsl:for-each>
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
    
    <hr />
    <table cellspacing="0" id="usageReport">
    <tr><th>User</th><th>Usage</th><th>Jobs</th><th>Average</th></tr>
    <xsl:for-each select="/Data/Display/Data/Transaction">
        <tr>
        <td><xsl:value-of select="User" /></td>
        <td><xsl:value-of select="format-number(Amount[1] div number(//Display/DisplayTime), '#.##')" /></td>
        <td><xsl:value-of select="Amount[2]" /></td>
        <td><xsl:value-of select="format-number(Amount[3] div number(//Display/DisplayTime), '#.##')" /></td>
        </tr>
    </xsl:for-each>
    </table>
</xsl:template>

</xsl:stylesheet>