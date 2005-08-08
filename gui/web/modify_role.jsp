<%@ page language="java" %>
<%@ taglib prefix="x" uri="http://java.sun.com/jstl/xml" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="x_rt" uri="http://java.sun.com/jstl/xml_rt" %>
<%@ taglib prefix="c_rt" uri="http://java.sun.com/jstl/core_rt" %>

<%@ page session="true" errorPage="not_supported.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<jsp:useBean id="requestBean" scope="session" class="gold.web.client.RequestBean" />
<jsp:useBean id="accountBean" scope="session" class="gold.web.client.AccountBean" />
<jsp:setProperty name="requestBean" property="*" />
<jsp:useBean id="userBean" scope="session" class="gold.web.client.UserBean"/>
<jsp:useBean id="conditionBean" scope="page" class="gold.web.client.ConditionBean"/>
<jsp:setProperty name="conditionBean" property="*" />
<%if(session.getAttribute("ID") == null){%>
  <jsp:forward page="revalidate.jsp"/>
<%}


String jsxml = requestBean.loadThisRoleInfo(conditionBean, userBean, request);

//stuff to get input boxes
userBean.setShowHidden(null);
String xml = "<Data>"; //+ requestBean.getInputXML(userBean);

conditionBean.setFieldNames("Description,Name,Special");
conditionBean.setFieldOperators(",Sort");
conditionBean.setConditionNames("Special");
conditionBean.setConditionValues("False");
requestBean.setMyaction("Query");
requestBean.setMyobject("User");
xml += requestBean.doAction(request, conditionBean, userBean, false, accountBean);

requestBean.setMyaction("Query");
requestBean.setMyobject("Object");
xml += requestBean.doAction(request, conditionBean, userBean, false, accountBean);


conditionBean.setFieldNames("Object,Name");
conditionBean.setFieldOperators("");
conditionBean.setConditionNames("Special");
conditionBean.setConditionValues("False");
requestBean.setMyaction("Query");
requestBean.setMyobject("Action");
xml += requestBean.doAction(request, conditionBean, userBean, false, accountBean) +"</Data>";


requestBean.setMyaction("modifyRole");
requestBean.setMyobject("Role");
%>

<html xmlns="http://www.w3.org/1999/xhtml" lang="en">

<head>
    <title>GOLD: Modify Role</title>

    <style type="text/css" media="all">

        @import "shared/gold.css";
        .multiSelect {
            width: 32%;
            float: left;
            margin-bottom: 2em;
        }

        .multiSelect select {
            /*width: 100%;*/
        }

        .multiSelect label {
            font-weight: bold;
            display: block;
        }

        #permissionsFieldset {
          margin: auto 90px;
        }

        #permissionsFieldset legend {
          font-size: 90%;
        }

        #permissionsFieldset .row {
          clear: both;
        }

        #permissionsHeaderRow {
            width: 40em;
            margin: auto;
            border-top: 1px solid white; /* Forces row to clear for some reason */
            border-bottom: 1px solid black;
        }

        #permissionsHeaderRow div {
          font-weight: bold;
          font-size: 80%;
          width: 27%;
        }

        .permissionsObject, .permissionsAction, .permissionsInstance {
            margin: auto;
            float: left;
            width: 27%;
            text-align: center;
            padding: 6px 0px;
        }

        .permission {
          width: 40em;
          margin: auto;
          border-bottom: 1px solid #CCC;
        }

        .permission div {
          font-size: 70%;
        }

        .delete {
          padding-top: 3px;
          text-align: center;
        }

        .delete input {
          font-size: 90%;
        }

    </style>


<c:set var="xmltext"><%=xml%></c:set>
<c:set var="xmljstext"><%=jsxml%></c:set>

<%--import the xsl files that we use to transform into javascript and html--%>
<c:import url="modify_role.xsl" var="input_modify_role_html"/>
<c:import url="changeComboJavaScript.xsl" var="change_combo_js"/>
<c:import url="initVarsRoles.xsl" var="init_vars_roles_js"/>


<%-- transform the xml for the javascript using the init_var xslt file--%>

<script language="Javascript1.3" type="text/javascript" src="shared/util.js"></script>
<script language="Javascript1.3" type="text/javascript" src="shared/roleUtil.js"></script>
<script language="Javascript">
      var ua = window.navigator.userAgent.toLowerCase();
      if ((i = ua.indexOf('msie')) != -1) navigator.org = "microsoft";
      var classAttributeName = (navigator.org == "microsoft") ? "className" : "class";

        
<x:transform xslt="${change_combo_js}" xml="${xmltext}"/>

<x:transform xslt="${init_vars_roles_js}" xml="${xmljstext}"/>

        function checkRequiredFields(){
            return true;
        }
        
        
        //make arrays for permissions
        var permissionsObjectArray = new Array();
        var permissionsActionArray = new Array();
        var permissionsInstanceArray = new Array();
        
</script>
</head>


<%-- transform the xml for the html using the modify_project xslt file--%>
<x:transform xslt="${input_modify_role_html}" xml="${xmltext}"/>

</html>

