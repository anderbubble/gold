<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : create_reservation.xsl
    Created on : May 20, 2004
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
    <title>GOLD: Create New Reservation</title>

    <script language="Javascript1.3" type="text/javascript" src="shared/util.js">//stuff</script>
    <script language="Javascript" type="text/javascript">
        function submitForm(){
            if(checkRequiredFields()){
                document.inputForm.target = "results";
                document.inputForm.action = "results.jsp";
                document.inputForm.submit();
            }
        }
        
        function checkRequiredFields(){
            var invalidField;
            if(document.getElementById("Account").value == "") {
                invalidField = document.getElementById("Account");
                alert("Please fill in an Account Id.");
            }
            else if(document.getElementById("EndTime").value == "") {
                invalidField = document.getElementById("EndTime");
                alert("Please fill in a Expiration Time.");
            }
            else if(document.getElementById("Amount").value == "") {
                invalidField = document.getElementById("Amount");
                alert("Please fill in an Amount.");
            }
           
            
            if(invalidField){
                invalidField.focus();
                return false;
            }
            else 
                return true;
        }
    </script>

    <style type="text/css" media="all">

        @import "shared/gold.css";

    </style>
</head>

<body>

<xsl:call-template name="Header">
    <xsl:with-param name = "myaction">Create</xsl:with-param>
    <xsl:with-param name = "myobject">Reservation</xsl:with-param>
</xsl:call-template>
<xsl:call-template name="RequiredDescription" />
<xsl:call-template name="PrimaryKeyDescription" />
<xsl:call-template name ="Data" />

<xsl:call-template name="SubmitRow" >
    <xsl:with-param name = "myaction">Create</xsl:with-param>
    <xsl:with-param name = "myobject">Reservation</xsl:with-param>
</xsl:call-template>

</body>
</html>
</xsl:template>



<xsl:template name = "Data">
    <form method="post" name="inputForm">
    
    <div class="row">
    <label class="rowLabel" for="Account">
    <span class="required">*</span>Account Id:</label>
    <input maxlength="40" size="30" value="" id="Account" name="Account" type="text"/>
    </div>
    
    
    <div class="row">
    <label class="rowLabel" for="Amount">
    <span class="required">*</span>Amount:</label>
    <input maxlength="" size="30" value="0" id="Amount" name="Amount" type="text"/>
    </div>
    
    <div class="row">
    <label class="rowLabel" for="EndTime">
    <span class="required">*</span>End Time:</label>
    <input maxlength="" size="30" value="infinity" id="EndTime" name="EndTime" type="text"/>
    </div>
    
    <div class="row">
    <label class="rowLabel" for="Description">Description:</label>
    <input maxlength="80" size="30" value="" id="Description" name="Description" type="text"/>
    </div>
  
    
    </form>
</xsl:template>


</xsl:stylesheet>