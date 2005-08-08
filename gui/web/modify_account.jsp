<%@ page language="java" %>
<%@ taglib prefix="x" uri="http://java.sun.com/jstl/xml" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="x_rt" uri="http://java.sun.com/jstl/xml_rt" %>
<%@ taglib prefix="c_rt" uri="http://java.sun.com/jstl/core_rt" %>

<%@ page session="true" errorPage="not_supported.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<jsp:useBean id="requestBean" scope="session" class="gold.web.client.RequestBean" />
<jsp:setProperty name="requestBean" property="*" />
<jsp:useBean id="userBean" scope="session" class="gold.web.client.UserBean"/>
<jsp:useBean id="conditionBean" scope="page" class="gold.web.client.ConditionBean"/>
<jsp:setProperty name="conditionBean" property="*" />
<%if(session.getAttribute("ID") == null){%>
  <jsp:forward page="revalidate.jsp"/>
<%}

String xml = requestBean.loadAccountInputs(userBean, request, conditionBean.getConditionValues(), null );

String jsxml = requestBean.loadThisAccountInfo(conditionBean, userBean, request, null);

%>

<html xmlns="http://www.w3.org/1999/xhtml" lang="en">

<head>
    <title>GOLD: Modify Account</title>

    <style type="text/css" media="all">

              @import "shared/gold.css";

        fieldset label {
            font-weight: bold;
            /*display: block;*/
        }

        fieldset select {
            width: 30%;
            float: left;
        }

        .activationTable {
            float: right;
            width: 66%;
        }

        .activationTable .headRow {
            border-bottom: 1px solid black;
            height: 2em;
        }

        .activationTable .headRow div {
            font-weight: bold;
            font-size: 105%;
        }

        .activationTable .activationRow {
            clear: both;
            border-bottom: 1px solid #A5C1E4;
            height: 2em;
            display: none;
        }

        .primaryKeyActivation, .active, .inactive {
            float: left;
            text-align: center;
            padding: .4em 0px;
        }

        .primaryKeyActivation {
            width: 45%;
        }

        .active, .inactive {
            width: 25%;
        }

        #selectInstructions {
            margin-top: 2em;
        }
    </style>


<!--jsxml
<%=jsxml%>
-->
<!--xml
<%=xml%>
-->

<%--get the strings of xml into a jstl/core variables--%>
<c:set var="jsxmltext"><%=jsxml%></c:set>
<c:set var="xmltext"><%=xml%></c:set>

<%--import the xsl files that we use to transform into javascript and html--%>
<c:import url="modify_complex_object_javascript.xsl" var="input_modify_account_javascript"/>
<c:import url="modify_account.xsl" var="input_modify_account_html"/>


<%-- transform the xml for the javascript using the init_var xslt file--%>

<script language="Javascript1.3" type="text/javascript" src="shared/util.js"></script>
<script language="Javascript">
<x:transform xslt="${input_modify_account_javascript}" xml="${jsxmltext}"/>


        
        function checkRequiredFields(){
            if(document.getElementById("AccountProject").value == ""){
                alert("Please select at least one project.");
                return false;
            }else if(document.getElementById("AccountUser").value == ""){
                alert("Please select at least one user.");
                return false;
            }else if(document.getElementById("AccountMachine").value == ""){
                alert("Please select at least one machine.");
                return false;
            }
            return true;
        }
        

        
        function submitForm(){
            if(checkRequiredFields()){
            document.inputForm.target = "results";
            document.inputForm.action = "results.jsp";
            document.inputForm.submit();
            }
        }

</script>
</head>


<body onload="initVars()">
<%-- transform the xml for the html using the modify_project xslt file--%>
<x:transform xslt="${input_modify_account_html}" xml="${xmltext}"/>
</body>
</html>

