<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : create_account.xsl
    Created on : September 23, 2003, 6:07 PM
    Author     : d3l028
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="templates.xsl" />
    <xsl:output method="xhtml"  indent = "yes"/>

<xsl:template match = "/" >

<html xmlns="http://www.w3.org/1999/xhtml" lang="en">

<head>
    <title>GOLD: Make Deposit</title>

    <script language="Javascript1.3" type="text/javascript" src="shared/util.js">//comment</script>
    <script language="Javascript" type="text/javascript">
        function submitForm(){
            
            var action = "results.jsp";
            document.inputForm.target = "results";
            document.inputForm.action = action;
            //alert(action);
            if(document.getElementById('Amount').value == "")
                alert("An Amount must be specified.  Please specify an amount and press the Make Deposit button again.");
            else if(document.getElementById('Id').value == "")
                alert("An Account Id must be specified.  Please specify an Account Id and press the Make Deposit button again.");
            else
                document.inputForm.submit();
        }
        
        function setId(id){
            document.getElementById('Id').value = id;
        }
        
        function selectAccount(){
            newWindow('AccountSelect', "select_account.jsp", 750, 500);
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

    </style>
</head>

<body>

<xsl:call-template name="Header">
    <xsl:with-param name="myaction">Make</xsl:with-param>
    <xsl:with-param name="myobject">Deposit</xsl:with-param>
</xsl:call-template>

<xsl:call-template name="RequiredDescription" />

<xsl:call-template name = "Data" />

<xsl:call-template name="SubmitRow" >
    <xsl:with-param name="myaction">Make</xsl:with-param>
    <xsl:with-param name="myobject">Deposit</xsl:with-param>
</xsl:call-template>

</body >
</html>
</xsl:template>



<xsl:template name = "Data">
    <form method="post" name="inputForm">
    
    
    <!--div class="row">
    <label class="rowLabel" for="Type">Debit or Credit:</label>
    <select id="Type" name="Type" onChange="checkType(this[this.selectedIndex].value);">
    <option selected="true" value="Debit">Debit</option>
    <option value="Credit">Credit</option>
    </select>
    </div>
    
    <div class="row">
    <label class="rowLabel" for="CreditLimit">Credit Limit:</label>
    <input maxlength="" size="30" value="0" id="CreditLimit" name="CreditLimit" type="text"/>
    </div>
    
    <div class="row">
    <label class="rowLabel" for="ActivationTime">Activation Date:</label>
    <input maxlength="" size="30" value="-infinity" id="ActivationTime" name="ActivationTime" type="text"/>
    </div>

    <div class="row">
    <label class="rowLabel" for="EndTime">Expiration Date:</label>
    <input maxlength="" size="30" value="infinity" id="EndTime" name="EndTime" type="text"/>
    </div-->
    
    <div class="row">
    <label class="rowLabel" for="Id"><span class="required">*</span>Account Id:</label>
    <input maxlength="" size="30" value="" id="Id" name="Id" type="text"/>
    <input onClick="selectAccount()" value="Select..." id="selectAccountButton" name="selectAccountButton" type="button"/>
    </div>
    
    <div class="row">
    <label class="rowLabel" for="Amount">
    <span class="required">*</span>Account Amount:</label>
    <input maxlength="" size="30" value="" id="Amount" name="Amount" type="text"/>
    </div>
    
    
    <div class="row">
    <label class="rowLabel" for="Allocation">Allocation Id:</label>
    <input maxlength="" size="30" value="" id="Allocation" name="Allocation" type="text"/>
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
    <label class="rowLabel" for="Description">Description:</label>
    <input maxlength="" size="30" value="" id="Description" name="Description" type="text"/>
    </div>
    
    <!--hr />
    <p id="selectInstructions">You can select multiple items from the Users, Projects, and Machines select fields by holding down 'Ctrl' on PCs and 'Cmd' on Macs.</p>
    <xsl:for-each select="*/child::*">
        <xsl:if test=".=../*[1]=false()"><if its not the first child,>
        <div class="row">
            <fieldset id="{name(./*[1])}Fieldset">
                <legend><xsl:value-of select="name(./*[1])"/>s</legend>
                <div class="include" id="{name(./*[1])}Include">
                <div id="includeHead">Include</div>
                <xsl:call-template name = "SpecialValueRadios" />
                <xsl:call-template name = "NameSelect" />
                </div>
            </fieldset>
        </div>
        </xsl:if>
    </xsl:for-each>

    -->
    </form>
</xsl:template>


<xsl:template name="SpecialValueRadios">
    <input type="radio" name="{name(./*[1])}Radio" id="{name(./*[1])}ANY" value="ANY" onclick="document.getElementById('{name(./*[1])}').disabled = true"/> <label for="{name(./*[1])}ANY">Any <xsl:value-of select="name(./*[1])"/></label><br/>
    <xsl:if test="name(./*[1]) != 'Project'">
    <input type="radio" name="{name(./*[1])}Radio" id="{name(./*[1])}MEMBERS" value="MEMBERS" onclick="document.getElementById('{name(./*[1])}').disabled = true"/> <label for="{name(./*[1])}MEMBERS">Any <xsl:value-of select="name(./*[1])"/> which is a  member of the Project</label><br/>
    </xsl:if>
    <input type="radio" name="{name(./*[1])}Radio" id="{name(./*[1])}SPECIFIC" value="{name(./*[1])}SPECIFIC" onclick="document.getElementById('{name(./*[1])}').disabled = false"/> <label for="{name(./*[1])}SPECIFIC">Specific <xsl:value-of select="name(./*[1])"/>s</label><br/>
</xsl:template>






</xsl:stylesheet>