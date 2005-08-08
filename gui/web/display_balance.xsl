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
            document.inputForm.action="display_balance.jsp?display=true";
            document.inputForm.target="action";
            document.inputForm.submit();
        }
        
        function initVars(){
            <xsl:if test="//Display">
            initCombo(document.inputForm.User, "<xsl:value-of select="//Display/User"/>");   
            initCombo(document.inputForm.Project, "<xsl:value-of select="//Display/Project"/>");   
            initCombo(document.inputForm.Machine, "<xsl:value-of select="//Display/Machine"/>");   
            //<xsl:value-of select="//Display/DisplayTime"/>
            
            
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

<xsl:call-template name="Header">
    <xsl:with-param name="myaction">Display</xsl:with-param>
    <xsl:with-param name="myobject">Balance</xsl:with-param>
</xsl:call-template>
<xsl:call-template name = "Data" />
<xsl:call-template name="SubmitRow">
    <xsl:with-param name="myaction">Display</xsl:with-param>
    <xsl:with-param name="myobject">Balance</xsl:with-param>
</xsl:call-template>

<xsl:if test="//Display">
<xsl:call-template name = "results" />
</xsl:if>
</body >
</html>
</xsl:template>


<xsl:template name = "Data">
    <form method="post" name="inputForm">
    <div class="row" style="width: 45em; padding-left: 2.5em;">
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
    <xsl:variable name="amounts"><xsl:value-of select="sum(//Allocation/Amount)" /></xsl:variable>
    <xsl:variable name="reserveds"><xsl:value-of select="sum(//Reservation_ReservationAllocation/Amount)" /></xsl:variable>
    <xsl:variable name="balances"><xsl:value-of select="$amounts - $reserveds" /></xsl:variable>
    <xsl:variable name="limits"><xsl:value-of select="sum(//Allocation/CreditLimit)" /></xsl:variable>
    <xsl:variable name="availables"><xsl:value-of select="$balances + $limits" /></xsl:variable>
    

    <hr />
    <table cellspacing="0" id="accounts">
    <tr><th>Account</th><th>Name</th><th>Amount</th><th>Reserved</th><th>Balance</th><th>Credit Limit</th><th>Available</th></tr>
    <xsl:for-each select="//Display/Accounts/Data/Account">
        <xsl:variable name="reserved">
        <xsl:if test="ReservationAllocations/Reservation_ReservationAllocation"><xsl:value-of select="ReservationAllocations/Reservation_ReservationAllocation/Amount" /></xsl:if>
        <xsl:if test="not(ReservationAllocations/Reservation_ReservationAllocation)"><xsl:value-of select="number(0)" /></xsl:if>
        </xsl:variable>
        <tr>
        <td><xsl:value-of select="Id" /></td>
        <td><xsl:value-of select="Name" /></td>
        <td class="amount"><xsl:value-of select="format-number(number(Allocations/Allocation/Amount) div number(//Display/DisplayTime), '#.##')" /></td>
        <td class="amount"><xsl:value-of select="format-number(number($reserved) div number(//Display/DisplayTime), '#.##')" /></td>
        <td class="amount"><xsl:value-of select="format-number((number(Allocations/Allocation/Amount) - number($reserved)) div number(//Display/DisplayTime), '#.##')" /></td>
        <td class="amount"><xsl:value-of select="format-number(number(Allocations/Allocation/CreditLimit)  div number(//Display/DisplayTime), '#.##')" /></td>
        <td class="amount"><xsl:value-of select="format-number((number(Allocations/Allocation/Amount) - $reserved + number(Allocations/Allocation/CreditLimit)) div number(//Display/DisplayTime), '#.##')" /></td>
        </tr>
    </xsl:for-each>
    <tr class="totals">
        <td colspan="2" class="Total">Total:</td>
        <td class="amount"><xsl:value-of select="format-number($amounts div number(//Display/DisplayTime), '#.##')" /></td>
        <td class="amount"><xsl:value-of select="format-number($reserveds div number(//Display/DisplayTime), '#.##')" /></td>
        <td class="amount"><xsl:value-of select="format-number($balances div number(//Display/DisplayTime), '#.##')" /></td>
        <td class="amount"><xsl:value-of select="format-number($limits div number(//Display/DisplayTime), '#.##')" /></td>
        <td class="amount"><xsl:value-of select="format-number($availables div number(//Display/DisplayTime), '#.##')" /></td>
    </tr>
    </table>
    
    
  

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
