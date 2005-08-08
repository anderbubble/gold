<jsp:useBean  id="requestBean" scope="session" class="gold.web.client.RequestBean">
<%requestBean.setHomeDir(getServletContext().getRealPath("/"));%>
</jsp:useBean>
<jsp:useBean  id="userBean" scope="session" class="gold.web.client.UserBean"/>
<%@ page import="sun.misc.BASE64Decoder" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN"
   "http://www.w3.org/TR/html4/frameset.dtd">

<%
    boolean authenticated = false;
    String auth=request.getHeader("Authorization");
    if(auth==null){
      response.setStatus(response.SC_UNAUTHORIZED);
      response.setHeader("WWW-Authenticate","BASIC realm=\"Gold\"");
    }
    else{
      String info=auth.substring(6).trim();
      BASE64Decoder decoder=new BASE64Decoder();
      String usernamepass=new String(decoder.decodeBuffer(info));
      int index= usernamepass.indexOf(":");
      userBean.setUsername(usernamepass.substring(0,index));
      userBean.setPassword(usernamepass.substring(index+1));

      //need to do authentication here with user&pass
      authenticated = userBean.authenticate();
      if(!authenticated){
        response.setStatus(response.SC_UNAUTHORIZED);
        response.setHeader("WWW-Authenticate","BASIC realm=\"Gold\"");
      }
    }

if(authenticated){
  session.setMaxInactiveInterval(7200);//7200 = number of seconds in 12 hours
  session.setAttribute("ID",session.getId());
%>

<html lang="en-us">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv="pragma" content="no-cache">
    <title>GOLD Accounting Management System</title>

</head>
<frameset cols="190,*" <% if (request.getHeader("User-Agent").indexOf("MSIE") == -1) {%>border="1"<%}%>>
    <frame src="chooser.jsp" name="chooser" scrolling="auto" frameborder="0" title="Navigation frame">
    <frame src="intro.jsp" name="main" scrolling="yes" frameborder="0" title="Content frame; may contain another frameset">

    <noframes>
    You must have a frames-capable browser to the EMSL User System.  Please download the latest version of <a href="http://www.mozilla.org">Mozilla</a>, <a href="http://www.netscape.com">Netscape</a>, or <a href="http://www.microsoft.com/windows/ie/default.htm">Internet Explorer</a>.
    </noframes>

</frameset>

</html>


<%}else{%>

<html lang="en-us">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">

    <title>GOLD: Authorization Required</title>

    <link rel="stylesheet" href="shared/gold.css">

</head>

<body>

<div id="content">

    <div class="header"><h1>Authorization Required</h1></div>

    <p>Authorization is required to use the Gold Application.  We could not authenticate you.  Please check for any misspellings.</p>

    <p>Click the <a href="javascript:history.back()">back</a> button to continue browsing.</p>

</div>

</body>

</html>
<%}%>