<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
    "http://www.w3.org/TR/html4/loose.dtd">
    <%@page isErrorPage="true" session="false"%>
<%if(session.getAttribute("ID") == null){%>
  <jsp:forward page="revalidate.jsp"/>
<%}
<html lang="en-us">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">

    <meta http-equiv="pragma" content="no-cache">


    <title>Action not yet supported</title>

    <link rel="stylesheet" href="shared/gold.css">


    <script type="text/javascript" language="Javascript1.3">
    /*
    Exception:
    <%=exception.getMessage()%>

    Stack Trace:
    <%
    java.io.PrintWriter pw = new java.io.PrintWriter(out);
    exception.printStackTrace(pw);
    %>

    serveltContext:
    <%= request.getContextPath()%>
    */
    </script>

</head>

<body>

<div class="notice">
    <div class="sectionHead"><h1>Action not yet supported</h1></div>

    <p>Your selection is not yet supported.</p>

    <hr>
</div>

</body>

</html>
