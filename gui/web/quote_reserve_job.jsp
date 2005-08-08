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
<%if(session.getAttribute("ID") == null){%>
  <jsp:forward page="revalidate.jsp"/>
<%}
userBean.setShowHidden(null);
String xml = requestBean.getJobQuoteInputs(userBean);

//requestBean.setMyobject("Job");
//requestBean.setMyaction("Quote");
%>
<c:set var="xmltext"><%=xml%></c:set>
<c:set var="xslfilename">quote_reserve_job.xsl</c:set>
<c:import url="${xslfilename}" var="input"/>

<x:transform xslt="${input}" xml="${xmltext}"/>
<!--<%=xml%>-->