<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : create_Role.xsl
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
    <title>GOLD: Create New Role</title>

    <script language="Javascript1.3" type="text/javascript" src="shared/util.js">//stuff</script>
    <script language="Javascript1.3" type="text/javascript" src="shared/roleUtil.js">//stuff</script>
    <script language="Javascript" type="text/javascript">

        //make arrays for permissions
        var permissionsObjectArray = new Array();
        var permissionsActionArray = new Array();
        var permissionsInstanceArray = new Array();

        //make arrays of actions for objects:
        <xsl:for-each select="*/Data/Object">
        var <xsl:value-of select="Name" />Array = new Array();</xsl:for-each>

        <xsl:for-each select="//Action">
        <xsl:value-of select="Object" />Array[<xsl:value-of select="Object" />Array.length] = "<xsl:value-of select="Name" />";
        </xsl:for-each>

         function changeActionCombo(object){
            var actionArray;
            var found = false;
            <xsl:for-each select="*/Data/Object">
            if(object =="<xsl:value-of select="Name" />"){
                actionArray = <xsl:value-of select="Name" />Array;
                found = true;
            }
            </xsl:for-each>

            var actionCombo = document.inputForm.Action;

            for(i=actionCombo.length-1; i != 0; i--) {
                actionCombo[i] = null;
            }

            for(i=0; i != actionArray.length; i++) {
                actionCombo[i+1] = new Option(actionArray[i], actionArray[i]);
            }
            
        }

        function checkRequiredFields(){
            if(document.getElementById("Name").value != "") return true;
            //else they didn't fill out Name
            alert("Please enter the Role Name.");
            return false;
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
            /*width: 100%;*/
        }

        .multiSelect label {
            font-weight: bold;
            display: block;
        }

        #permissionsFieldset {
          margin: auto 90px;
        }

        #permissionsFieldset legend {
          font-size: 90%;
        }

        #permissionsFieldset .row {
          clear: both;
        }

        #permissionsHeaderRow {
            width: 40em;
            margin: auto;
            border-top: 1px solid white; /* Forces row to clear for some reason */
            border-bottom: 1px solid black;
        }

        #permissionsHeaderRow div {
          font-weight: bold;
          font-size: 80%;
          width: 27%;
        }

        .permissionsObject, .permissionsAction, .permissionsInstance {
            margin: auto;
            float: left;
            width: 27%;
            text-align: center;
            padding: 6px 0px;
        }

        .permission {
          width: 40em;
          margin: auto;
          border-bottom: 1px solid #CCC;
        }

        .permission div {
          font-size: 70%;
        }

        .delete {
          padding-top: 3px;
          text-align: center;
        }

        .delete input {
          font-size: 90%;
        }

    </style>
</head>

<body>

<xsl:call-template name="Header">
    <xsl:with-param name = "myaction">Create</xsl:with-param>
    <xsl:with-param name = "myobject">Role</xsl:with-param>
</xsl:call-template>
<xsl:call-template name="RequiredDescription" />
<xsl:call-template name="PrimaryKeyDescription" />
<xsl:call-template name ="Data" />

<xsl:call-template name="SubmitRow" >
    <xsl:with-param name = "myaction">Create</xsl:with-param>
    <xsl:with-param name = "myobject">Role</xsl:with-param>
</xsl:call-template>

</body>
</html>
</xsl:template>



<xsl:template name = "Data">
    <form method="post" name="inputForm">

    <div class="row">
    <label class="rowLabel" for="JobId">
    <span class="required">*</span>Name:</label>
    <input maxlength="40" size="30" value="" id="Name" name="Name" type="text"/>
    </div>

    <div class="row">
    <label class="rowLabel" for="Description">Description:</label>
    <input maxlength="80" size="30" value="" id="Description" name="Description" type="text"/>
    </div>

    <hr/>

    <xsl:for-each select="*/child::*">
    <xsl:if test="name(./*[1]) = 'User'">
    <div class="row">
        <xsl:call-template name = "NameSelect"/>
    </div>
    </xsl:if>
    </xsl:for-each>

    <fieldset id="permissionsFieldset">
      <legend>Permissions</legend>

      <div class="row">
        <div class="multiSelect" id="ObjectMultiSelect" >
        <label for="Object">Objects:</label>
        <select id="Object" name="Object" onclick="changeActionCombo(this[selectedIndex].text)">
        <option value="ANY">Any Object</option>
        <xsl:for-each select="//Object">
            <xsl:if test="string-length(Name) != 0">
            <option value="{Name}"><xsl:value-of select="Name" /></option>
            </xsl:if>
        </xsl:for-each>
        </select>
        </div>

        <div class="multiSelect" id="ActionMultiSelect" >
        <label for="Action">Actions:</label>
        <select id="Action" name="Action">
        <option value="ANY">Any Action</option>
        </select>
        </div>
        
        <div class="multiSelect" id="InstanceMultiSelect">
        <label class="rowLabel" for="Instance">Instance:</label>
        <input maxlength="80" size="25" value="" id="Instance" name="Instance" type="text"/>
        </div>
     </div>


     <div class="row">
      <input onClick="addPerm()" value="Add Permission" id="addPermission" name="addPermission" type="button"/>
     </div>

     <div id="permissions">
      <div id="permissionsHeaderRow">
          <div class="permissionsObject">Object</div>
          <div class="permissionsAction">Action</div>
          <div class="permissionsInstance">Instance</div>
          <div class="clear"><xsl:comment>Comment</xsl:comment></div>
      </div>

      <div id="permissionsResultsRow"></div>

     </div><!-- closing permissions div-->
    </fieldset>

    <!-- hidden fields used to do all the queries necessary-->
    <input type="hidden" name="objects" id="objects" />
    <input type="hidden" name="actions" id="actions" />
    <input type="hidden" name="instances" id="instances" />

    </form>
</xsl:template>




</xsl:stylesheet>