<%@ page language="java" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
<%if(session.getAttribute("ID") == null){%>
  <jsp:forward page="revalidate.jsp"/>
<%}%>
<html lang="en-us">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv="pragma" content="no-cache">

    <title>GOLD: Introduction</title>

    <style type="text/css" media="all">
    <!--
        @import "shared/gold.css";


    -->
    </style>

</head>

<body>

<h1><img src="images/gold_logo_main.gif" width="246" height="81" alt="GOLD"></h1>

</body>
</html>