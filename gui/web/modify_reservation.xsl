<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : modify_reservation.xsl
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
Reservation Id:</label>
<input disabled="y" maxlength="" size="30" value="" id="Id" name="Id" type="text"/>
</div>

<div class="row">
<label class="rowLabel" for="Account">Account Id:</label>
<input disabled="y" maxlength="40" size="30" value="" id="Account" name="Account" type="text"/>
</div>
<div class="row">
<label class="rowLabel" for="Amount">Resource Credits:</label>
<input disabled="y" maxlength="40" size="30" value="" id="Amount" name="Amount" type="text"/>
</div>
<div class="row">
<label class="rowLabel" for="Name">Reservation Name:</label>
<input disabled="y" maxlength="40" size="30" value="" id="Name" name="Name" type="text"/>
</div>
<div class="row">
<label class="rowLabel" for="Job">Gold Job Id:</label>
<input disabled="y" maxlength="40" size="30" value="" id="Job" name="Job" type="text"/>
</div>
<div class="row">
<label class="rowLabel" for="User">User Name:</label>
<input disabled="y" maxlength="40" size="30" value="" id="User" name="User" type="text"/>
</div>

<div class="row">
<label class="rowLabel" for="Project">Project Name:</label>
<input disabled="y" maxlength="40" size="30" value="" id="Project" name="Project" type="text"/>
</div>
<div class="row">
<label class="rowLabel" for="Machine">Machine Name:</label>
<input disabled="y" maxlength="40" size="30" value="" id="Machine" name="Machine" type="text"/>
</div>

    <div class="row">
    <label class="rowLabel" for="StartTime">Start Time:</label>
    <input maxlength="" size="30" value="" id="StartTime" name="StartTime" type="text"/>
    </div>
<div class="row">
<label class="rowLabel" for="EndTime">End Time:</label>
<input maxlength="" size="30" value="infinity" id="EndTime" name="EndTime" type="text"/>
</div>

<div class="row">
<label class="rowLabel" for="Type">Reservation Type:</label>
<input disabled="y" maxlength="" size="30" value="0" id="Type" name="Type" type="text"/>
</div>

<div class="row">
<label class="rowLabel" for="Description">Description:</label>
<input maxlength="80" size="30" value="" id="Description" name="Description" type="text"/>
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