<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : modify_template.xsl
    Created on : September 2003
    Author     : zjohns, Geoff Elliott
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="templates.xsl" />
    <xsl:output method="xhtml" indent = "yes"/>

<xsl:template match = "/" >
<body onload="initVars();initConditons();">
<xsl:call-template name="Header" />

<xsl:call-template name="PrimaryKeyDescription" />

<form method="post" name="inputForm">
<div class="row">
<label class="rowLabel" for="Id">

<img alt="Primary Key" class="primaryKey" height="9" width="14" src="images/primary_key.gif"/>Allocation Id:</label>
<input disabled="y" size="30" value="" id="Id" name="Id" type="text"/>
</div>
<div class="row">
<label class="rowLabel" for="Account">Account Name:</label>
<select id="Account" name="Account" disabled="y">
<Option value=""/>
<Option value="1">1</Option>
<Option value="2">2</Option>
</select>
</div>
<div class="row">
<label class="rowLabel" for="StartTime">Start Time:</label>

<input size="30" value="-infinity" id="StartTime" name="StartTime" type="text"/>
</div>
<div class="row">
<label class="rowLabel" for="EndTime">End Time:</label>
<input size="30" value="infinity" id="EndTime" name="EndTime" type="text"/>
</div>
<div class="row">
<label class="rowLabel" for="Amount">Allocation Amount:</label>
<input size="30" value="" id="Amount" name="Amount" type="text" disabled="y"/>
</div>

<div class="row">
<label class="rowLabel" for="CreditLimit">Credit Limit:</label>
<input size="30" value="" id="CreditLimit" name="CreditLimit" type="text" />
</div>

<div class="row">
<label class="rowLabel" for="Deposited">Deposited:</label>
<input size="30" value="" id="Deposited" name="Deposited" type="text" />
</div>


<div class="row">
<label class="rowLabel" for="Type">Allocation Type:</label>
<select id="Type" name="Type" disabled="y">
<Option value=""/>
<Option value="Back">Back</Option>
<Option value="Forward">Forward</Option>
<Option selected="true" value="Normal">Normal</Option>
</select>
</div>
<div class="row">
<label class="rowLabel" for="Description">Description:</label>
<input size="30" value="" id="Description" name="Description" type="text"/>
</div>
<hr/>
<div id="submitRow">
<input onClick="submitForm()" value="Modify Allocation(s)" id="formSubmit" name="create" type="button"/>
</div>

<input value="" id="fieldNames" name="fieldNames" type="hidden"/>
<input value="" id="fieldValues" name="fieldValues" type="hidden"/>
<input value="" id="conditionNames" name="conditionNames" type="hidden"/>
<input value="" id="conditionValues" name="conditionValues" type="hidden"/>
<input value="manage" id="viewType" name="viewType" type="hidden"/>
<input value="modify_object" id="thisAction" name="thisAction" type="hidden"/>
<input value="Modify" id="myaction" name="myaction" type="hidden"/>
</form>
</body>
</xsl:template>


</xsl:stylesheet>