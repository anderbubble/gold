<%
try{
  session.invalidate();
%>
  <html lang="en-us">
  <head/>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <meta http-equiv="pragma" content="no-cache">
  <body onload="document.inputForm.submit();">
  <form name="inputForm" method="post" target="_top" action="index.jsp"/>
    </body>
  </html>
<%}catch(Exception e){
    e.printStackTrace();%>
    <html lang="en-us">
    <head/>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv="pragma" content="no-cache">
    <body onload="alert('revalidated2');"/>
    </html>
 <%}%>



