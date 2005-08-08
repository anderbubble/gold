<%@ page language="java" %>
<%@ taglib prefix="x" uri="http://java.sun.com/jstl/xml" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="x_rt" uri="http://java.sun.com/jstl/xml_rt" %>
<%@ taglib prefix="c_rt" uri="http://java.sun.com/jstl/core_rt" %>

<%--%@ page session="true" errorPage="not_supported.jsp" --%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"  "http://www.w3.org/TR/html4/loose.dtd">
<jsp:useBean id="requestBean" scope="session" class="gold.web.client.RequestBean" />
<jsp:setProperty name="requestBean" property="*" /> 
<jsp:useBean  id="userBean" scope="session" class="gold.web.client.UserBean"/>
<%if(session.getAttribute("ID") == null){%>
  <jsp:forward page="revalidate.jsp"/>
<%}
userBean.setShowHidden("True");
String action = requestBean.getMyaction();
String xml, xsl;
    userBean.setShowHidden(null);
if(!action.equalsIgnoreCase("Delete") && !action.equalsIgnoreCase("Undelete") && !action.equalsIgnoreCase("Create") && !action.equalsIgnoreCase("Modify") && !action.equalsIgnoreCase("Query")){
    xml = "<call_options><myaction>"+requestBean.getMyaction()+"</myaction><myobject>"+requestBean.getMyobject()+"</myobject></call_options>";
    xsl = "admin_options.xsl";
}else{
    xsl = "admin_";
    xsl += requestBean.getMyaction().concat(".xsl").toLowerCase();
    if("Delete".equalsIgnoreCase(action) || "Undelete".equalsIgnoreCase(action))
        xsl = "admin_delete.xsl";
    xml = requestBean.getInputXML(userBean);
}
%>

<c:set var="xmltext"><%=xml%></c:set>
<c:set var="xslfilename"><%=xsl%></c:set>
<c:import url="${xslfilename}" var="input"/>

<x:transform xslt="${input}" xml="${xmltext}"/>

<!--
<%=xml%>, <%=xsl%>
-->