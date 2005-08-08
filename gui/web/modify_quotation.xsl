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
<img alt="Primary Key" class="primaryKey" height="9" width="14" src="images/primary_key.gif"/>
Quotation Id:</label>
<input disabled="y" maxlength="" size="30" value="" id="Id" name="Id" type="text"></input>
</div>

<div class="row">
<label class="rowLabel" for="Amount">Amount:</label>
<input disabled="y" maxlength="40" size="30" value="" id="Amount" name="Amount" type="text"></input>
</div>

<div class="row">
<label class="rowLabel" for="StartTime">
Start Time:</label>
<input maxlength="" size="30" value="" id="StartTime" name="StartTime" type="text"></input>
</div>
<div class="row">
<label class="rowLabel" for="EndTime">
End Time:</label>
<input maxlength="" size="30" value="" id="EndTime" name="EndTime" type="text"></input>
</div>

<div class="row">
<label class="rowLabel" for="WallDuration">WallTime Estimate:</label>
<input disabled="y" maxlength="" size="30" value="" id="WallDuration" name="WallDuration" type="text"></input>
</div>

<div class="row">
<label class="rowLabel" for="Job">Gold Job Id:</label>
<input disabled="y" maxlength="40" size="30" value="" id="Job" name="Job" type="text"></input>
</div>

<div class="row">
<label class="rowLabel" for="User">User Name:</label>
<input disabled="y" maxlength="40" size="30" value="" id="User" name="User" type="text"></input>
</div>
<div class="row">
<label class="rowLabel" for="Project">Project Name:</label>
<input disabled="y" maxlength="40" size="30" value="" id="Project" name="Project" type="text"></input>
</div>


<div class="row">
<label class="rowLabel" for="Machine">Machine Name:</label>
<input disabled="y" maxlength="40" size="30" value="" id="Machine" name="Machine" type="text"></input>
</div>


<div class="row">
<label class="rowLabel" for="Used">Number of Times used:</label>
<input disabled="y" maxlength="" size="30" value="0" id="Used" name="Used" type="text"></input>
</div>

<div class="row">
<label class="rowLabel" for="Type">Reservation Type:</label>
<input disabled="y" maxlength="40" size="30" value="" id="Type" name="Type" type="text"></input>
</div>

<div class="row">
<label class="rowLabel" for="Description">Description:</label>
<input maxlength="80" size="30" value="" id="Description" name="Description" type="text"></input>
</div>

<xsl:call-template name="SubmitRow" />
<!-- these hidden fields will automatically be set in the conditionBean upon form submit -->
<input type="hidden" name="fieldNames" id="fieldNames" value="" />
<input type="hidden" name="fieldValues" id="fieldValues" value="" />
<input type="hidden" name="conditionNames" id="conditionNames" value="" />
<input type="hidden" name="conditionValues" id="conditionValues" value="" />
<input type="hidden" name="viewType" id="viewType" value="manage" />
<input type="hidden" name="thisAction" id="thisAction" value="modify_object" />
<input type="hidden" name="myaction" id="myaction" value="Modify" />

</form>

</body>
</xsl:template>


</xsl:stylesheet>