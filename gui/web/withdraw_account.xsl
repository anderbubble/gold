<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : create_project.xsl
    Created on : September 23, 2003, 6:07 PM
    Author     : d3l028
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="templates.xsl" />
    <xsl:output method="xhtml" indent = "yes"/>

<xsl:template match = "/" >

<html xmlns="http://www.w3.org/1999/xhtml" lang="en">

<head>
    <title>GOLD: Make Withdrawal</title>

    <script language="Javascript1.3" type="text/javascript" src="shared/util.js">//comment</script>
    <script language="Javascript" type="text/javascript">
        function submitForm(){
            if(document.getElementById('Amount').value == "")
                alert("An Amount must be specified.  Please specify an amount and press the Make Withdrawal button again.");
            else if(document.getElementById('Id').value == "")
                alert("An Account Id must be specified.  Please specify an Account Id and press the Make Withdrawal button again.");
            else{
                document.inputForm.target = "results";
                document.inputForm.action = "results.jsp";
                document.inputForm.submit();
            }
        }

        function toggleConstraints(){
            var select;
            var usingId = document.getElementById("AccountId").checked;
            <xsl:for-each select="Data/child::*">
                select =  document.getElementById("<xsl:value-of  select="name(./*[1])" />");
                if(usingId)
                    select.disabled = true;
                else select.disabled = false;
            </xsl:for-each>
            if(usingId)
                document.getElementById("Id").disabled = false;
            else
                document.getElementById("Id").disabled = true;

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

        .withdrawOption label{
            font-weight: bold;
        }

    </style>

</head>

<body>

<xsl:call-template name="Header">
    <xsl:with-param name="myaction">Make</xsl:with-param>
    <xsl:with-param name="myobject">Withdrawal</xsl:with-param>
</xsl:call-template>

<xsl:call-template name="RequiredDescription" />

<xsl:call-template name ="Data" />


<xsl:call-template name="SubmitRow" >
    <xsl:with-param name="myaction">Make</xsl:with-param>
    <xsl:with-param name="myobject">Withdrawal</xsl:with-param>
</xsl:call-template>

</body>
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
    <label class="rowLabel" for="Amount">
    <span class="required">*</span>Account Amount:</label>
    <input maxlength="" size="30" value="" id="Amount" name="Amount" type="text"/>
    </div>

    
    <div class="row">
    <label class="rowLabel" for="Allocation">Allocation Id:</label>
    <input maxlength="" size="30" value="" id="Allocation" name="Allocation" type="text"/>
    </div>
    
    
    <div class="row">
    <label class="rowLabel" for="Description">Description</label>
    <input maxlength="" size="30" value="" id="Description" name="Description" type="text"/>
    </div>
    
    </form>
</xsl:template>




<xsl:template name="NameComboold">
    <div class="row">
    <label for="{name(./*[1])}" class="rowLabel"><xsl:value-of select="name(./*[1])"/>s</label>
    <select name="{name(./*[1])} " id="{name(./*[1])}" disabled="true">
    <xsl:if test="count(./*)>0">
        <xsl:for-each select="./child::*">
            <xsl:sort select = "./Name" />
            <xsl:if test="./Name != '' and ./Name != ' ' and ./Special = 'False'">
                <option value="{./Name}"><xsl:value-of select="./Name"/></option>
            </xsl:if>
        </xsl:for-each>
    </xsl:if>
    </select>
    </div>
</xsl:template>


</xsl:stylesheet>