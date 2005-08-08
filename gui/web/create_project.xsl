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
    <title>GOLD: Create New Project</title>

    <script language="Javascript1.3" type="text/javascript" src="shared/util.js">//stuff</script>
    <script language="Javascript" type="text/javascript">
        function submitForm(){
            if(document.getElementById("Name").value == ""){
                alert("Please enter a Project Name.");
            }else{
                document.inputForm.target = "results";
                document.inputForm.action = "results.jsp";
                document.inputForm.submit();
            }
        }
    </script>

    <style type="text/css" media="all">

        @import "shared/gold.css";

        .multiSelect {
            width: 32%;
            float: left;
            margin-bottom: 2em;
        }

        .multiSelect select {
            width: 90%;
        }

        .multiSelect label {
            font-weight: bold;
            display: block;
        } 

        fieldset label {
            font-weight: bold;
            display: block;
        }

        fieldset select {
            width: 30%;
            float: left;
        }

        .activationTable {
            float: right;
            width: 66%;
        }

        .activationTable .headRow {
            border-bottom: 1px solid black;
            height: 2em;
        }

        .activationTable .headRow div {
            font-weight: bold;
            font-size: 105%;
        }

        .activationTable .activationRow {
            clear: both;
            border-bottom: 1px solid #A5C1E4;
            height: 2em;
            display: none;
        }

        .primaryKeyActivation, .active, .inactive {
            float: left;
            text-align: center;
            padding: .4em 0px;
        }

        .primaryKeyActivation {
            width: 45%;
        }

        .active, .inactive {
            width: 25%;
        }

        #selectInstructions {
            margin-top: 2em;
        }

    </style>
</head>

<body>

<xsl:call-template name="Header" />
<xsl:call-template name="RequiredDescription" />
<xsl:call-template name="PrimaryKeyDescription" />
<xsl:call-template name ="Data" />

<xsl:call-template name="SubmitRow" />

</body>
</html>
</xsl:template>


<xsl:template name = "Data">
    <form method="post" name="inputForm">
    <xsl:apply-templates select="//Attribute" />
    <hr />
    <p id="selectInstructions">You can select multiple items from the Users, Projects, and Machines select fields by holding down 'Ctrl' on PCs and 'Cmd' on Macs.</p>
    <!--div class="row" style="width: 45em; padding-left: 2.5em;"-->
        <xsl:for-each select="*/child::*">
        <xsl:if test=".=../*[1]=false()"><!--if its not the first child, -->
        <div class="row">
            <fieldset id="{name(./*[1])}Fieldset">
                <legend><xsl:value-of select="name(./*[1])"/>s</legend>
                <div id="{name(./*[1])}Activation" class="activationTable">
                    <xsl:call-template name = "NameRadio">
                    <xsl:with-param name="object">Project</xsl:with-param>
                    </xsl:call-template>
                </div>

                <xsl:call-template name = "NameSelect">
                    <xsl:with-param name="onchange">changeActivationTable('<xsl:value-of select="name(./*[1])"/>'); setMembers('<xsl:value-of select="name(./*[1])"/>', 'Project');</xsl:with-param>
                </xsl:call-template>
                <input type="hidden" name="Project{name(./*[1])}" id="Project{name(./*[1])}"/>
                <input type="hidden" name="Project{name(./*[1])}Active" id="Project{name(./*[1])}Active"/>
                <xsl:if test="name(./*[1]) = 'Users'">
                    <input type="hidden" name="Project{name(./*[1])}Admin" id="Project{name(./*[1])}Admin"/>
                </xsl:if>
            </fieldset>
        </div>
        </xsl:if>
    </xsl:for-each>
    <!--/div-->
    </form>
</xsl:template>





</xsl:stylesheet>