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
    <title>GOLD: Refund Job</title>

    <script language="Javascript" type="text/javascript">
        function submitForm(){
            if(checkRequiredFields()){
                //disable unused fields so that they won't get submitted:
                document.getElementById("Idradio").disabled = true;
                document.getElementById("JobIdradio").disabled = true;
                document.inputForm.target = "results";
                document.inputForm.action = "results.jsp";
                document.inputForm.submit();
                //put back radio's
                document.getElementById("Idradio").disabled = false;
                document.getElementById("JobIdradio").disabled = false;
            }
        }
        
        function toggleConstraints(){
            var usingId = document.getElementById("Idradio").checked;
            
            if(usingId){
                document.getElementById("Id").disabled = false;
                document.getElementById("JobId").disabled = true;
                
            }else{
                document.getElementById("Id").disabled = true;
                document.getElementById("JobId").disabled = false;
            }
        }
        
        function checkRequiredFields(){
            if(document.getElementById("Id").value == "" <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> document.getElementById("Idradio").checked){
                alert("Please enter an Id");
                document.getElementById("Id").focus();
                return false;
            }else if(document.getElementById("JobId").value == "" <xsl:text disable-output-escaping="yes">&amp;&amp;</xsl:text> document.getElementById("JobIdradio").checked){
                alert("Please enter a Job Id");
                document.getElementById("JobId").focus();
                return false;
            }
            return true;
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
    <xsl:with-param name="myaction">Refund</xsl:with-param>
    <xsl:with-param name="myobject">Job</xsl:with-param>
</xsl:call-template>

<xsl:call-template name="RequiredDescription" />

<xsl:call-template name ="Data" />


<xsl:call-template name="SubmitRow" >
    <xsl:with-param name="myaction">Refund</xsl:with-param>
    <xsl:with-param name="myobject">Job</xsl:with-param>
</xsl:call-template>

</body>
</html>
</xsl:template>


<xsl:template name = "Data">
    <form method="post" name="inputForm">
    <div class="row">
        <label class="rowLabel" for="Amount">Amount:</label>
        <input maxlength="" size="30" value="" id="Amount" name="Amount" type="text"/>
    </div>
    <div class="row">
        <label class="rowLabel" for="Description">Description:</label>
        <input maxlength="" size="30" value="" id="Description" name="Description" type="text"/>
    </div>

    <p id="selectInstructions">An Id or JobId must be entered</p>

    <div class="row">
        <label  class="rowLabel" for="Id"><span class="required">*</span>Id:</label>
        <input  type="radio" name="Ids" value="id" id="Idradio" checked="true" onclick="toggleConstraints()" onkeypress="toggleConstraints()" />
        <input type="text" size="20" name="Id" id="Id" />
    </div>


    <div class="row">
        <label  class="rowLabel" for="JobId"><span class="required">*</span>Job Id:</label>
        <input type="radio" name="Ids" value="jobId" id="JobIdradio"  onclick="toggleConstraints()" onkeypress="toggleConstraints()" />
        <input type="text" size="20" name="JobId" id="JobId" disabled="true"/>
    </div>

    
    </form>
</xsl:template>




</xsl:stylesheet>