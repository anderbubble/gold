<%@ page language="java" %>
<%@ taglib prefix="x" uri="http://java.sun.com/jstl/xml" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="x_rt" uri="http://java.sun.com/jstl/xml_rt" %>
<%@ taglib prefix="c_rt" uri="http://java.sun.com/jstl/core_rt" %>

<!--%@ page session="true" errorPage="not_supported.jsp" %-->

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<jsp:useBean id="requestBean" scope="session" class="gold.web.client.RequestBean" />
<jsp:setProperty name="requestBean" property="*" />
<jsp:useBean id="userBean" scope="session" class="gold.web.client.UserBean"/>
<jsp:useBean id="conditionBean" scope="page" class="gold.web.client.ConditionBean"/>
<jsp:setProperty name="conditionBean" property="*" />
<jsp:useBean  id="accountBean" scope="session" class="gold.web.client.AccountBean"/>
<%if(session.getAttribute("ID") == null){%>
  <jsp:forward page="revalidate.jsp"/>
<%}
userBean.setShowHidden(null);
String xml = requestBean.getInputXML(userBean);

//if we modifying job, change JobId to a required Field
if("job".equalsIgnoreCase(requestBean.getMyobject())){
    /*
    int startIndex = xml.indexOf("<Name>JobId");
    int endIndex = xml.indexOf("</Attribute>", startIndex);
    String substring = xml.substring(startIndex, endIndex);
    System.out.println("\n\nsubstring before:\n"+substring);
    substring.replaceAll("f\\</Fixed\\>", "t</Fixed>");
    System.out.println("\n\nsubstring after:\n"+substring);
    String temp = xml.substring(0, startIndex);
    temp += substring;
    temp += xml.substring(endIndex, xml.length() );
    xml = temp;
    */
    //another route:
    int startIndex = xml.indexOf("<Name>JobId");
    int endIndex = xml.indexOf("</Attribute>", startIndex);
    String substring1 = xml.substring(startIndex, endIndex);
    //System.out.println("\n\nsubstring1:\n"+substring1);
    int startIndex2 = substring1.indexOf("<Fixed>");
    String substring2 = substring1.substring(startIndex2, substring1.length());
    
    //System.out.println("\n\nsubstring2:\n"+substring2);
    substring2 = substring2.replaceFirst("False", "True");
    
    //System.out.println("\n\nsubstring2 after:\n"+substring2);
    String temp = xml.substring(0, startIndex);
    temp += substring1.substring(0, startIndex2);
    temp += substring2;
    temp += xml.substring(endIndex, xml.length() );
    xml = temp;
    //System.out.println("\n\nXML!!!:\n"+xml);
}    
requestBean.setMyaction("Query");
String jsxml = requestBean.doAction(request, conditionBean, userBean, true, accountBean);
requestBean.setMyaction("Modify");

String xsltFile = "modify_template.xsl";
if(requestBean.getMyobject().equalsIgnoreCase("Quotation"))
    xsltFile = "modify_quotation.xsl";
else if(requestBean.getMyobject().equalsIgnoreCase("Reservation"))
    xsltFile = "modify_reservation.xsl";
else if(requestBean.getMyobject().equalsIgnoreCase("Allocation"))
    xsltFile = "modify_allocation.xsl";
%>


<%--get the strings of xml into a jstl/core variables--%>
<c:set var="jsxml"><%=jsxml%></c:set>
<c:set var="xml"><%=xml%></c:set>
<c:set var="xslfilename"><%=xsltFile%></c:set>

<%--import the xsl files that we use to transform into javascript and html--%>
<c:import url="modify_template_javascript.xsl" var="modify_javascript"/>
<c:import url="${xslfilename}" var="modify_html"/>



<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<!--
jsxml: <%=jsxml%>
xml: <%=xml%>
-->


<head>
    <title>GOLD: Modify <xsl:value-of select="//myobject"/></title>
    <script language="Javascript1.3" type="text/javascript" src="shared/util.js"></script>

    <script language="Javascript" type="text/javascript">
    function initConditons(){
    <x:parse var="attributes" xml="${xml}"/>
    <x:parse var="values" xml="${jsxml}"/>
    <x:forEach select="$attributes//Attribute">
        <x:if select="PrimaryKey = 'True'">
            addConditionName("<x:out select="Name"/>");
        </x:if>
    </x:forEach>
    }
    
    <x:transform xslt="${modify_javascript}" xml="${jsxml}"/>
    </script>

    <style type="text/css" media="all">
        @import "shared/gold.css";
    </style>
</head>

<x:transform xslt="${modify_html}" xml="${xml}"/>
</html>

