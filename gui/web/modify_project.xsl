<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : modify_project.xsl
    Created on : September 26, 2003, 1:19 PM
    Author     : Geoff Elliott
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="templates.xsl" />
    <xsl:output method="xhtml"/>

    
<xsl:template match = "/" >

<xsl:call-template name="Header" />
<xsl:call-template name="PrimaryKeyDescription" />
<xsl:call-template name="Data" />

</xsl:template>




<xsl:template name = "Data">
    <form method="post" name="inputForm">
    
    <xsl:apply-templates select="//Attribute"/>
    
    <p id="selectInstructions">You can select multiple items from the Users, Projects, and Machines select fields by holding down 'Ctrl' on PCs and 'Cmd' on Macs.</p>
    <xsl:for-each select="*/child::*">
        <xsl:if test=".=../*[1]=false()"><!--if its not the first child, -->
        <div class="row">
            <fieldset id="{name(./*[1])}Fieldset">
                <legend>Modify <xsl:value-of select="name(./*[1])"/>s</legend>
                <xsl:call-template name = "NameSelect">
                    <xsl:with-param name="onchange">changeActivationTable('<xsl:value-of select="name(./*[1])"/>'); setMembers('<xsl:value-of select="name(./*[1])"/>', 'Project');</xsl:with-param>
                </xsl:call-template>
                <div id="{name(./*[1])}Activation" class="activationTable">
                    <xsl:call-template name = "NameRadio" />
                </div>
                <input type="hidden" name="Project{name(./*[1])}" id="Project{name(./*[1])}"/>
                <input type="hidden" name="Project{name(./*[1])}Active" id="Project{name(./*[1])}Active"/>
                <xsl:if test="name(./*[1]) = 'User'">
                    <input type="hidden" name="Project{name(./*[1])}Admin" id="Project{name(./*[1])}Admin"/>
                </xsl:if>
            </fieldset>
        </div>
        </xsl:if>
    </xsl:for-each>

    <xsl:call-template name="SubmitRow" />

    </form>
</xsl:template>











</xsl:stylesheet>