<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN"
   "http://www.w3.org/TR/html4/frameset.dtd">
<jsp:useBean id="requestBean" scope="session" class="gold.web.client.RequestBean" />
<jsp:setProperty name="requestBean" property="*" /> 
<%if(session.getAttribute("ID") == null){%>
  <jsp:forward page="revalidate.jsp"/>
<%}
String nextPage = "empty.html";
String section = request.getParameter("section");
if("admin".equalsIgnoreCase(section))
    nextPage = "admin_input.jsp";
else if("manage".equalsIgnoreCase(section)){
    String action = requestBean.getMyaction().toLowerCase();  
    String object = requestBean.getMyobject().toLowerCase();
    //duplicate javascript from chooser:
    if(!"project".equalsIgnoreCase(object) && !"account".equalsIgnoreCase(object)  && !"depositshare".equalsIgnoreCase(object) && !"reservation".equalsIgnoreCase(object) &&
       !"deposit".equalsIgnoreCase(object) && !"quotation".equalsIgnoreCase(object) && !"role".equalsIgnoreCase(object) && "create".equalsIgnoreCase(action))
        object = "template";    
    if(("quote".equalsIgnoreCase(action) || "reserve".equalsIgnoreCase(action)) && "job".equalsIgnoreCase(object))
        action = "quote_reserve";    
    if(("undo".equalsIgnoreCase(action) || "redo".equalsIgnoreCase(action)) && "transaction".equalsIgnoreCase(object))
        action = "undo_redo";
    
    if("modify".equalsIgnoreCase(action) || ("list".equalsIgnoreCase(action) && !"transaction".equalsIgnoreCase(object)) || ("delete".equalsIgnoreCase(action))|| ("undelete".equalsIgnoreCase(action)) )
        nextPage = "modify_select.jsp";
    else
        nextPage = action + "_" + object + ".jsp";
}
%>

<html lang="en-us">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv="pragma" content="no-cache">
    <title>GOLD: Status Frameset</title>

</head>

<frameset rows="3*,*" <% if (request.getHeader("User-Agent").indexOf("MSIE") == -1) {%>border="1"<%}%>>
    <frame src="<%=nextPage%>" name="action" scrolling="yes" frameborder="0" title="Action frame.  Form inputs to create/modify objects are here.">
    <frame src="results.jsp?dontDoAction=true" name="results" scrolling="yes" frameborder="0" title="Status frame.  After an action is executed the result is displayed here.">

    <noframes>
    You must have a frames-capable browser to the EMSL User System.  Please download the latest version of <a href="http://www.mozilla.org">Mozilla</a>, <a href="http://www.netscape.com">Netscape</a>, or <a href="http://www.microsoft.com/windows/ie/default.htm">Internet Explorer</a>.
    </noframes>

</frameset>

</html>