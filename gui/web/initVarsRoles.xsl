<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : initVarsRoles.xsl
    Created on : August 26, 2004, 12:09 PM
    Author     : d3l028
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html"/>

    <!-- TODO customize transformation rules 
         syntax recommendation http://www.w3.org/TR/xslt 
    -->
    <xsl:template match="/">
        function initVars(){
            <!-- should only be one:-->
            document.getElementById("Name").value = "<xsl:value-of select="//Data/Role/Name" />";
            document.getElementById("Description").value = "<xsl:value-of select="//Data/Role/Description" />";
            
            <xsl:apply-templates select="Data//RoleUser" />
                        
            <xsl:apply-templates select="Data//RoleAction" />
        }
    </xsl:template>

    <xsl:template name="Role">
        document.getElementById("Name").value = "<xsl:value-of select="//Data/Role/Name" />";
        document.getElementById("Description").value = "<xsl:value-of select="//Data/Role/Description" />";
    </xsl:template>
    
    <xsl:template match="RoleUser">
        var users = document.getElementById("User");
        
        for(i = 0; i != users.options.length; i++) {
            if(users.options[i].value == "<xsl:value-of select="Name" />"){
                users.options[i].selected = true;
            }
        }
    </xsl:template>
    
    <xsl:template match="RoleAction">
        addPermRow("<xsl:value-of select="Object" />", "<xsl:value-of select="Name" />", "<xsl:value-of select="Instance" />");
    </xsl:template>
    
</xsl:stylesheet>
