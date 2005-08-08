<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : modify_Role.xsl
    Created on : May 20, 2004
    Author     : d3l028
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="templates.xsl" />
    <xsl:output method="xhtml" indent = "yes"/>

<xsl:template match = "/" >
    <body onload="initVars();">
    <xsl:call-template name="Header">
        <xsl:with-param name = "myaction">Modify</xsl:with-param>
        <xsl:with-param name = "myobject">Role</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="RequiredDescription" />
    <xsl:call-template name="PrimaryKeyDescription" />
    <xsl:call-template name ="Data" />

    <xsl:call-template name="SubmitRow" >
        <xsl:with-param name = "myaction">Modify</xsl:with-param>
        <xsl:with-param name = "myobject">Role</xsl:with-param>
    </xsl:call-template>

    </body>
</xsl:template>



<xsl:template name = "Data">
    <form method="post" name="inputForm">

    <div class="row">
    <label class="rowLabel" for="JobId">
    <span class="required">*</span>Name:</label>
    <input maxlength="40" size="30" value="" id="Name" name="Name" type="text" disabled="true"/>
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