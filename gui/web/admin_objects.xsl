<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : stylesheet.xsl
    Created on : July 16, 2003, 11:35 AM
    Author     : zjohns
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xhtml"/>

<xsl:template match="Data">
     <option>Select an Object</option>
     <xsl:apply-templates/>
</xsl:template>

<xsl:template match="Object">
     <option><xsl:value-of select="Name"/></option>
</xsl:template>

</xsl:stylesheet>
