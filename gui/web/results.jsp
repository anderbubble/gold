<%@ page contentType="text/html"%>
<%@ taglib prefix="x" uri="http://java.sun.com/jstl/xml" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="x_rt" uri="http://java.sun.com/jstl/xml_rt" %>
<%@ taglib prefix="c_rt" uri="http://java.sun.com/jstl/core_rt" %>
<jsp:useBean  id="requestBean" scope="session" class="gold.web.client.RequestBean"/>
<jsp:setProperty name="requestBean" property="*"/>
<jsp:useBean  id="conditionBean" scope="page" class="gold.web.client.ConditionBean"/>
<jsp:setProperty name="conditionBean" property="*"/>
<jsp:useBean  id="userBean" scope="session" class="gold.web.client.UserBean"/>
<jsp:setProperty name="userBean" property="*"/>
<jsp:useBean  id="accountBean" scope="page" class="gold.web.client.AccountBean"/>
<jsp:setProperty name="accountBean" property="*"/>
<%if(session.getAttribute("ID") == null){%>
  <jsp:forward page="revalidate.jsp"/>
<%}


System.out.println("AccountBean: " + accountBean.toString());
String xml = "<Data></Data>";
if(request.getParameter("dontDoAction") == null){
    xml = requestBean.doAction(request, conditionBean, userBean, false, accountBean);
}

%>
<c:set var="xmltext"><%=xml%></c:set>
<c:import url="results.xsl" var="results"/>

<!--DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"-->

<x:transform xslt="${results}" xml="${xmltext}"/>
