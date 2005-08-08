<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : modify_complex_object_javascript.xsl
    Created on : October 13, 2003, 12:13 PM
    Author     : d3l028
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text"/>

    <xsl:template match="/">   
        function initVars(){
            <xsl:for-each select="Data/Data"><!-- each Data tag under the root Data tag should be attributes to initialze with-->
                <xsl:for-each select="./child::*">
                    <!--for each one of these, for each of their child tags, there should be an html input that needs to be initalized:-->
                    <xsl:if test="name(.) = //Data/myobject">
                        <xsl:for-each select="./child::*">
                            setValue("<xsl:value-of select="name(.)"/>", "<xsl:value-of select="."/>");
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:if test="//Data/myobject = 'Project' and not(name(.) = //Data/myobject) and string-length(./Name) > 0 and string-length(./Active) > 0">
                        setMembersValue("<xsl:value-of select = "//Data/myobject"/>", "<xsl:value-of select = "substring-after(name(.), //Data/myobject )" />", "<xsl:value-of select="./Name"/>", "<xsl:value-of select="./Active"/>"<xsl:if test="./Admin">, "<xsl:value-of select="./Admin"/>"</xsl:if>);
                    </xsl:if>
                    <xsl:if test="//Data/myobject = 'DepositShare' and not(name(.) = //Data/myobject) and string-length(./Name) > 0 and string-length(./Access) > 0">
                        <xsl:if test="name(.) = 'DepositShareProject'">
                            initCombo(document.getElementById("DepositShareProject"), "<xsl:value-of select = "Name"/>");
                        </xsl:if>
                        <xsl:if test="not(name(.) = 'DepositShareProject')">
                            setMembersValue("<xsl:value-of select = "//Data/myobject"/>", "<xsl:value-of select = "substring-after(name(.), //Data/myobject )" />", "<xsl:value-of select="./Name"/>", "<xsl:value-of select="./Access"/>");
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="//Data/myobject = 'Account' and not(name(.) = //Data/myobject) and string-length(./Name) > 0 and string-length(./Access) > 0">
                        setMembersValue("<xsl:value-of select = "//Data/myobject"/>", "<xsl:value-of select = "substring-after(name(.), //Data/myobject )" />", "<xsl:value-of select="./Name"/>", "<xsl:value-of select="./Access"/>");
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
            <xsl:if test="//Data/myobject = 'Account'">
            toggleSelect('User');
            toggleSelect('Project');
            toggleSelect('Machine');         
            </xsl:if>
            <xsl:if test="//Data/myobject = 'DepositShare'">
            toggleSelect('User');
            toggleSelect('Machine');         
            </xsl:if>
        
        }
        
               
    </xsl:template>

</xsl:stylesheet> 
