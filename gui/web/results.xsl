<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : results.xsl
    Created on : July 23, 2003, 9:29 PM
    Author     : zjohns, Geoff Elliott
    Description:
        Purpose of transformation follows.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:import href="templates.xsl" />
    <xsl:output method="xhtml"/>


    <xsl:template match="/">

    <html xmlns="http://www.w3.org/1999/xhtml" lang="en">
    <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta http-equiv="pragma" content="no-cache"/>

    <title>Request Results</title>

    <style type="text/css" media="all">

        @import "shared/gold.css";

        body {
            background-color: #EFEBAB;
            background-image: url(images/status_background.gif);
            background-repeat: repeat-x;
            background-attachment: fixed;
        }

        h1 {
            font-size: 110%;
        }

        table#results {
            background-color: #E6E396;
            border-top: 1px solid black;
            border-left: 1px solid black;
            margin: auto;
        }

        table#results th, table#results td {
            border-right: 1px solid black;
            border-bottom: 1px solid black;
            font-size: 70%;
            padding: 4px;
        }

        table#results th {
            font-weight: bold;
            text-align: center;
            vertical-align: bottom;
        }

        table#results td {
            vertical-align: top;
        }

        .updated {
            background-color: #B4CFED;
        }

    </style>
    

    <script language="Javascript" type="text/javascript">
    <!--function loadMessageFrame(){
       if(<%=requestBean.getMyaction().equalsIgnoreCase("Modify") || requestBean.getMyaction().equalsIgnoreCase("Create") || requestBean.getMyaction().equalsIgnoreCase("Delete") || requestBean.getMyaction().equalsIgnoreCase("Undelete")%>)
         parent.frames.chooserFrame.location.href='chooser.jsp';
    }-->  
    function reset(){
        //if(parent.frames.action.doReset)
        //    document.actionObject.submit();         
        //parent.frames.action.location.href = "modify_select.jsp?myaction=Modify?myobject=<xsl:value-of select="//myobject"/>";
    }
    </script>
    
    </head>
    <body onload="reset()">
    <h1><xsl:value-of select="//mymessage"/></h1>
    <xsl:if test="//mymessages">
    <p>
        <xsl:call-template name="lf2br">
            <xsl:with-param name="StringToTransform" select="//mymessages"/>
        </xsl:call-template>
    </p>
    
    </xsl:if>
        <table cellspacing="0" border="0" rules="all" id="results">
            <xsl:for-each select="*[1]"><!--firstData-->
                <xsl:for-each select="*[1]"><!--just the first Object under data-->
                    <tr>
                        <xsl:for-each select="*"><!--every attribute under the Object-->
                            <th><xsl:value-of select="name(.)"/></th>
                        </xsl:for-each>
                    </tr>
                </xsl:for-each>

            <xsl:for-each select="*"><!--every Machine-->
                <xsl:if test="count(./*)>=1"><!--if there are any attributes-->
                    <tr>
                    <xsl:for-each select="*"><!--every attribute under machine-->
                        <xsl:choose>
                            <xsl:when test=".='' or .=' '"><!-- if the value for this attribute is an empty string, use a sbsp for teh cell content-->
                                <td>
                                <xsl:text disable-output-escaping="no">&#160;</xsl:text>
                                </td><!-- &#160; is xml for nbsp-->
                            </xsl:when>
                            <xsl:otherwise>
                                <td>
                                <xsl:if test="count(./*)>=1">
                                    <xsl:for-each select="*">
                                        <xsl:value-of select="."/><br />
                                    </xsl:for-each>
                                </xsl:if>
                                <xsl:if test="count(./*)=0">
                                    <xsl:value-of select="."/>
                                </xsl:if>
                                </td>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                    </tr>
                </xsl:if>
                </xsl:for-each>
            </xsl:for-each>
        </table>
        
        <form method="post" name="actionObject" target="action" action="modify_select.jsp">
            <input type="hidden" name="myobject" value="{//myobject}" />
            <input type="hidden" name="myaction" value="Modify" />
        </form>
    </body>
    </html>
    </xsl:template>

</xsl:stylesheet>

