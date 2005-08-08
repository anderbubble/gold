<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : table_templates.xsl
    Created on : May 6, 2004, 2:38 PM
    Author     : d3l028
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html"/>

 <xsl:template name="tableHeader">
    <xsl:variable name="rowspan">
        <xsl:choose>
          <xsl:when test="count(//results/From/Attributes/Data/Attribute) = count(//results/From/Attributes/Data/*)">1</xsl:when>
          <xsl:otherwise>2</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <tr class="headerRow">
        <th class="deleteHead" rowspan="{$rowspan}"><div><xsl:text>&#160;</xsl:text></div></th>
        
        
        <xsl:for-each select="//results/From/Attributes/Data/*">
            <th>
            <xsl:if test="not(./Attribute)">
              <xsl:attribute name="rowspan"><xsl:value-of select="$rowspan"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="./Attribute">
              <xsl:attribute name="rowspan">1</xsl:attribute>
              <xsl:attribute name="colspan"><xsl:value-of select="count(./Attribute) - 1"/></xsl:attribute>
            </xsl:if>
            <div>
                <xsl:if test="./Name">
                    <xsl:value-of select="./Name"/> 
                </xsl:if>
                <xsl:if test="not(./Name)">
                    <xsl:value-of select="substring-after(name(.), //results/From/myobject)"/>s
                </xsl:if>
            </div>
            </th>
        </xsl:for-each>                
    </tr>
    <xsl:if test="count(//results/From/Attributes/Data/Attribute) != count(//results/From/Attributes/Data/*)">
        <tr class="headerRow">
            <xsl:for-each select="//results/From/Attributes/Data/*">
              <xsl:for-each select="./Attribute">
                <xsl:if test="./Name != 'Parent'">
                    <th>
                    <div><xsl:value-of select="./Name"/></div>
                    </th>
                </xsl:if>
              </xsl:for-each>    
            </xsl:for-each>    
        </tr>
    </xsl:if>
</xsl:template>


<xsl:template name="toTableContent">
  <xsl:for-each select="//results/To/Account"><!--every Machine-->
    <xsl:call-template name="tableContent">
        <xsl:with-param name="toORfrom">to</xsl:with-param>
    </xsl:call-template>
  </xsl:for-each>
</xsl:template>

<xsl:template name="fromTableContent">  
  <xsl:for-each select="//results/From/Account"><!--every Machine-->
    <xsl:call-template name="tableContent">
        <xsl:with-param name="toORfrom">from</xsl:with-param>
    </xsl:call-template>
  </xsl:for-each>
</xsl:template>

<xsl:template name="tableContent">
      <xsl:param name="toORfrom"/>
      <xsl:variable name = "counter"><xsl:number /></xsl:variable>
      <tr id="{$counter}Row">
        <td rowspan="{./MaxChildCount}" class="deleteCell">
            <input type="checkbox" id="{$toORfrom}Account{./Id}" checked="true" />
        </td>
        
        <!-- finish first row with the first child of linking objects
            (will always have at least one-i added a blank spacer child when none exist) --> 
        <xsl:call-template name="first-child-content" />
      </tr>  
      <!-- make the rest of the rows with the remaining children of linking objects--> 
      <xsl:call-template name="child-content">
        <xsl:with-param name="child-count" select="2"/>
      </xsl:call-template>
</xsl:template>




<xsl:template name="child-content">
    <xsl:param name="child-count" />
    <xsl:if test="$child-count &lt;= ./MaxChildCount">
        <tr>
        <xsl:for-each select="*"><!--every child under project that has children (IE Users have ProjectUsers)-->
            <!-- case where there are multiple children-each one gets its own td -->
            <xsl:if test="name(./@*[1])='Link'">
                <!-- if there is one there and this is not the last one-->
                <xsl:choose>
                    <xsl:when test="./*[$child-count] and $child-count != count(./*)">
                        <xsl:for-each select="./*[$child-count]/*">
                            <td>
                            <xsl:if test=".='' or .=' '">  
                                <xsl:text>&#160;</xsl:text>
                            </xsl:if>
                            <xsl:value-of select="."/>
                            </td>
                        </xsl:for-each>
                    </xsl:when>
                    <!-- if is the last one and there are more than one children (first one was already done in first-child-content)-->
                    <xsl:when test="$child-count = count(./*)"><!-- if child-count is the last one -->
                    <!-- old stuff: $child-count = ../MaxChildCount and count(./*) &gt; 1 -->
                        <xsl:for-each select="./*[last()]/*">
                            <xsl:comment>here count:<xsl:value-of select="count(../../*)"/>,  MaxChildCount:<xsl:value-of select="../../../MaxChildCount"/></xsl:comment>
                            <td>
                            <xsl:attribute name="rowspan"><xsl:value-of select="../../../MaxChildCount - count(../../*) +1" /></xsl:attribute>
                            
                            <xsl:if test=".='' or .=' '">  
                                <xsl:text>&#160;</xsl:text>
                            </xsl:if>
                            <xsl:value-of select="."/>
                            </td>
                        </xsl:for-each>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
        </tr>
        <xsl:call-template name="child-content">
            <xsl:with-param name="child-count" select="$child-count + 1"/>
        </xsl:call-template>
    </xsl:if>
</xsl:template>


<xsl:template name="first-child-content">
    <xsl:for-each select="*"><!--every child under project that has children (IE Users have ProjectUsers)-->
        <!-- for just the first subchild of eache project's children  (IE first ProjectUser under Users, first ProjectMachine under Machines...)-->
        <xsl:choose>
          <!-- this will match up to Users, etc-->
          <xsl:when test="name(./@*[1])='Link'">
            <xsl:for-each select="./*[1]/*">
                <xsl:comment>there count:<xsl:value-of select="count(../../*)"/>,  MaxChildCount:<xsl:value-of select="../../../MaxChildCount"/></xsl:comment>
                <td>
                <xsl:attribute name="rowspan">
                    <xsl:if test="count(../../*) = 1"><xsl:value-of select="../../../MaxChildCount" /></xsl:if>
                    <xsl:if test="count(../../*) &gt; 1">1</xsl:if>
                </xsl:attribute>
                <xsl:if test=".='' or .=' '">  
                    <xsl:text>&#160;</xsl:text>
                </xsl:if>
                <xsl:value-of select="."/>
                </td>
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="not(name(./@*[1])='Hidden')">
            <td>
            <xsl:attribute name="rowspan"><xsl:value-of select="../MaxChildCount" /></xsl:attribute>
            <xsl:if test=".='' or .=' '">  
                <xsl:text>&#160;</xsl:text>
            </xsl:if>
            <xsl:value-of select="."/>
            </td>
          </xsl:when>
        </xsl:choose>
    </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
