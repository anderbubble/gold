<%@ page language="java" %>
<%@ taglib prefix="x" uri="http://java.sun.com/jstl/xml" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="x_rt" uri="http://java.sun.com/jstl/xml_rt" %>
<%@ taglib prefix="c_rt" uri="http://java.sun.com/jstl/core_rt" %>

<%--@ page session="true" errorPage="not_supported.jsp" --%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<jsp:useBean id="requestBean" scope="session" class="gold.web.client.RequestBean" />
<jsp:setProperty name="requestBean" property="*" />
<jsp:useBean  id="userBean" scope="session" class="gold.web.client.UserBean"/>
<jsp:useBean  id="conditionBean" scope="page" class="gold.web.client.ConditionBean"/>
<jsp:useBean  id="accountBean" scope="session" class="gold.web.client.AccountBean"/>
<%if(session.getAttribute("ID") == null){%>
  <jsp:forward page="revalidate.jsp"/>
<%}
userBean.setUserAction("");

String xml = "<Data></Data>";
%>

<c:set var="xmltext"><%=xml%></c:set>
<c:set var="xslfilename">refund_job.xsl</c:set>
<c:import url="${xslfilename}" var="input"/>

<x:transform xslt="${input}" xml="${xmltext}"/>
