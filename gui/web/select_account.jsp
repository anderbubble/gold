<%@ page language="java" %>
<%@ taglib prefix="x" uri="http://java.sun.com/jstl/xml" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="x_rt" uri="http://java.sun.com/jstl/xml_rt" %>
<%@ taglib prefix="c_rt" uri="http://java.sun.com/jstl/core_rt" %>

<!--%@ page session="true" errorPage="not_supported.jsp" %-->

<DOCTYPE HTML PUBLIC "-//w3c//dtd html 4.0 transitional//en">
<jsp:useBean id="requestBean" scope="session" class="gold.web.client.RequestBean" />
<jsp:setProperty name="requestBean" property="*" /> 
<jsp:useBean  id="userBean" scope="session" class="gold.web.client.UserBean"/>
<jsp:setProperty name="userBean" property="*" /> 
<jsp:useBean  id="conditionBean" scope="page" class="gold.web.client.ConditionBean"/>
<%if(session.getAttribute("ID") == null){%>
  <jsp:forward page="revalidate.jsp"/>
<%}
//do a query for all objects
String xml;
//save the object we're about to do an action on
String myobjectsave = requestBean.getMyobject();
requestBean.setMyobject("Account");
if((request.getParameter("query") != null) || (request.getParameter("fieldNames") != null)){
    %><jsp:setProperty name="conditionBean" property="*" /><%
    xml = requestBean.getAccountList(userBean, conditionBean);
}else
    xml = requestBean.getAccountList(userBean, null);

//System.out.println("xml in select_account:\n" + xml);

requestBean.setMyobject(myobjectsave);

%>
<c:set var="xmltext"><%=xml%></c:set>
<c:import url="select_account.xsl" var="results"/>
<x:transform xslt="${results}" xml="${xmltext}"/>
<!--
<%=xml%>
-->

