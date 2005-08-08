<%@ taglib prefix="x" uri="http://java.sun.com/jstl/xml" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="x_rt" uri="http://java.sun.com/jstl/xml_rt" %>
<%@ taglib prefix="c_rt" uri="http://java.sun.com/jstl/core_rt" %>
<!--jsp:useBean  id="requestBean" scope="session" class="gold.web.client.UserBean"-->
<jsp:useBean  id="requestBean" scope="session" class="gold.web.client.RequestBean"/>
<jsp:useBean  id="userBean" scope="session" class="gold.web.client.UserBean"/>
<jsp:useBean  id="accountBean" scope="session" class="gold.web.client.AccountBean"/>
<jsp:useBean  id="conditionBean" scope="page" class="gold.web.client.ConditionBean"/>

<%@page import="gold.web.client.ElementUtil" %>
<%@page import="org.jdom.Element" %>
<%if(session.getAttribute("ID") == null){%>
  <jsp:forward page="revalidate.jsp"/>
<%}

Element access = requestBean.getAccess(userBean);
String xml = requestBean.getObjectsXML(userBean);


requestBean.setMyaction("Query");
requestBean.setMyobject("Action");
String ActionXml = requestBean.doAction(request, conditionBean, userBean, false, accountBean);

ElementUtil util = new ElementUtil();
%>

<c:set var="objXML"><%=xml%></c:set>
<c:set var="objActXML"><%=ActionXml%></c:set>
<c:import url="admin_objects.xsl" var="option"/>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta http-equiv="pragma" content="no-cache">

    <title>GOLD: Navigation</title>

    <style type="text/css" media="all">
    <!--
        @import "shared/gold.css";

        body {
            background-color: #265895;
            background-image: url(images/sidebar_background.gif);
            background-repeat: repeat-y;
            background-position: top right;
            margin: 0px;
            margin-top: 5px;
            padding: 0px;(myaction == 'list')
        }

        h1 {
            margin: 0px;
            padding: 0px;
            padding-right: 10px;
        }

        .sidebarHeader {
            margin: 1.2em 8px 0px;
            background-image: url(images/sidebar_header_background.gif);
            background-repeat: repeat-x;
            height: 19px;
        }

        .sidebarHeader h2 {
            font-size: 80%;
            margin: 0px;
            margin-right: 5px;
            height: 14px;
            padding: 0px;(myaction == 'list')
        }

        .sidebarHeader .rightFlare {
            float: right;
            width: 5px;
        }

        .sidebarSection {
            clear: both;
            margin: 0px 13px 0px 8px;
        }

        label {
            color: #B4CEEE;
            font-size: 75%;
            font-weight: bold;
            display: block;
            margin: .5em 0px 2px 2px;
        }

        select {
            font-size: 75%;
            margin-left: 2px;
        }

        h3 {
            background-color: #A5C1E4;
            color: #163E6F;
            font-size: 75%;
            text-align: left;
            margin: 1px 13px 0px 8px;
            padding: 3px 6px;
            cursor: pointer;
        }

        .menuArrow {
            float: right;
            padding-top: 2px;
        }

        .menuSection {
            margin: 0px 13px 0px 8px;
            padding: 6px 7px 3px;
        request.setCondition("Special", "False");
            border: 1px inset #364B65;
            background-color: #3A5980;
            display: none;
        }

        #usersSection {
            display: block;
        }

        .menuSection a:link {
            display: block;
            padding-bottom: 5px;
            color: white;
            font-size: 70%;
        }

        .menuSection a:visited {
            display: block;
            padding-bottom: 5px;
            color: white;
            font-size: 70%;
        }

    -->
    </style>

    <script language="Javascript" type="text/javascript">

        <%-- this chunk to populate combo boxes of objects' actions--%>
        <x:parse var="objects" xml="${objXML}"/>
        <x:parse var="Actions" xml="${objActXML}"/>
        
        //make arrays of actions for objects:
        <x:forEach select="$objects//Object">
        var <x:out select="Name"/>Array = new Array();</x:forEach>
        
        
        <x:forEach select="$Actions//Action">
        <x:out select="Object"/>Array[<x:out select="Object"/>Array.length] = "<x:out select="Name"/>";
        </x:forEach>

        // these 2 functions for admin users part: an if will go around them to determine if page needs them

        function changeActionCombo(object, form){
            var actionArray;
            var found = false;
            <x:forEach select="$objects//Object">
            if(object =="<x:out select="Name"/>"){
                actionArray = <x:out select="Name"/>Array;
                found = true;
            }
            </x:forEach>

            if(form == 'admin')
                var actionCombo = document.adminChooserForm.myaction;
            if(form == 'diagram')
                var actionCombo = document.diagramChooserForm.myaction;

            for(i=actionCombo.length-1; i >= 0; i--) {
                actionCombo[i] = null;
            }
            if(!found){
                actionCombo[0] = new Option('Select an action','');
            }
            else{
                actionCombo[0] = new Option('Select an action','');
                for(i=0; i < actionArray.length; i++) {
                    actionCombo[i+1] = new Option(actionArray[i], actionArray[i]);
                }
            }
        }



        function doAdminAction(){
            if(document.adminChooserForm.myaction.value != ""){
                //we need to check here if we can submit to the action frame yet (ie: if results_frameset is loaded yet)
                if(parent.main.location.href.indexOf("results_frameset.jsp") == -1) {
                    document.adminChooserForm.action="results_frameset.jsp?section=admin";
                    document.adminChooserForm.target="main";
                    document.adminChooserForm.submit();
                }else{
                    document.adminChooserForm.action="admin_input.jsp";
                    document.adminChooserForm.target="action";
                    document.adminChooserForm.submit();
                }
            }
        }



        function doManageAction(myaction, myobject){
                document.chooserForm.myobject.value = myobject;
                document.chooserForm.myaction.value = myaction;
                //we need to check here if we can submit to the action frame yet (ie: if results_frameset is loaded yet)
                if(parent.main.location.href.indexOf("results_frameset.jsp") == -1) {
                    document.chooserForm.action="results_frameset.jsp?section=manage";
                    document.chooserForm.target="main";
                    document.chooserForm.submit();
                }else{
                    myobject = new String(myobject).toLowerCase();
                    myaction = new String(myaction).toLowerCase();

                    //all of these objects don't use the template page 
                    //(that leaves user, machines, chargerate, job, and usage)
                    if((myobject != 'project')       && (myobject != 'account')   && (myobject != 'deposit')     && (myobject != 'role')  &&
                       (myobject != 'depositshare')  && (myobject != 'quotation') && (myobject != 'reservation') && 
                       (myaction == 'create') ){
                        myobject = 'template';
                    }
                    //single pages used for 2 actions:
                    if((myaction == 'quote' || myaction == 'reserve') && myobject == 'job')
                        myaction = 'quote_reserve';
                    if((myaction == 'undo' || myaction == 'redo') && myobject == 'transaction')
                        myaction = 'undo_redo';
                        
                    //construct the name of the next jsp based on the action & object the user selected    
                    document.chooserForm.action=myaction + "_" + myobject + ".jsp";
                    
                    //unless the user selected one of these actions where the next page is a listing of that object for them to choose from
                    if(myaction == 'modify' || (myaction == 'list' && myobject != 'transaction') || myaction == 'delete' || myaction == 'undelete'){
                        document.chooserForm.action="modify_select.jsp";
                    }
                    document.chooserForm.target="action";
                    document.chooserForm.submit();
                }
        }

        //end if here

    </script>

    <script type="text/javascript" src="shared/menus.js"></script>

</head>

<body onload="showMenu('users')">
<h1><img src="images/gold_logo_sidebar.gif" width="153" height="54" alt="GOLD" /></h1>

<div class="sidebarHeader">
    <div class="rightFlare"><img src="images/sidebar_header_flare_right.gif" width="5" height="19" alt="" /></div>
    <h2>Manage</h2>
</div>
<%if( util.hasAccessToObject(access, "User") ){%>
<h3 class="menuHead" id="users" onclick="showMenu('users')"><img src="images/menu_arrow_closed.gif" class="menuArrow" id="usersArrow" width="9" height="9" alt="" />Users</h3>

<div class="menuSection" id="usersSection">
    <%if( util.hasAccessToObjectWithAction(access, "User", "Query") ){%><a href="javascript:doManageAction('List', 'User')">List Users</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "User", "Create") ){%><a href="javascript:doManageAction('Create', 'User')">Create New User</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "User", "Modify") ){%><a href="javascript:doManageAction('Modify', 'User')">Modify User</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "User", "Delete") ){%><a href="javascript:doManageAction('Delete', 'User')">Delete Users</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "User", "Undelete") ){%><a href="javascript:doManageAction('Undelete', 'User')">Undelete Users</a><%}%>
</div>
<%}%>
<%if( util.hasAccessToObject(access, "Project") ){%>
<h3 class="menuHead" id="projects" onclick="showMenu('projects')" onclick="showMenu('usersSection')"><img src="images/menu_arrow_closed.gif" class="menuArrow" id="projectsArrow" width="9" height="9" alt="" />Projects</h3>

<div class="menuSection" id="projectsSection">
    <%if( util.hasAccessToObjectWithAction(access, "Project", "Query") ){%><a href="javascript:doManageAction('List', 'Project')">List Projects</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Project", "Create") ){%><a href="javascript:doManageAction('Create', 'Project')">Create New Project</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Project", "Modify") ){%><a href="javascript:doManageAction('Modify', 'Project')">Modify Project</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Project", "Delete") ){%><a href="javascript:doManageAction('Delete', 'Project')">Delete Projects</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Project", "Undelete") ){%><a href="javascript:doManageAction('Undelete', 'Project')">Undelete Projects</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Query", "Transaction") ){%><a href="javascript:doManageAction('Usage', 'Report')">Usage Report</a><%}%>
</div>
<%}%>
<%if( util.hasAccessToObject(access, "Machine") ){%>
<h3 class="menuHead" id="machines" onclick="showMenu('machines')"><img src="images/menu_arrow_closed.gif" class="menuArrow" id="machinesArrow" width="9" height="9" alt="" />Machines</h3>

<div class="menuSection" id="machinesSection">
    <%if( util.hasAccessToObjectWithAction(access, "Machine", "Query") ){%><a href="javascript:doManageAction('List', 'Machine')">List Machines</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Machine", "Create") ){%><a href="javascript:doManageAction('Create', 'Machine')">Create New Machine</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Machine", "Modify") ){%><a href="javascript:doManageAction('Modify', 'Machine')">Modify Machine</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Machine", "Delete") ){%><a href="javascript:doManageAction('Delete', 'Machine')">Delete Machines</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Machine", "Undelete") ){%><a href="javascript:doManageAction('Undelete', 'Machine')">Undelete Machines</a><%}%>
</div>

<%}%>
<%if( util.hasAccessToObject(access, "Account") ){%>
<h3 class="menuHead" id="accounts" onclick="showMenu('accounts')"><img src="images/menu_arrow_closed.gif" class="menuArrow" id="accountsArrow" width="9" height="9" alt="" />Accounts</h3>

<div class="menuSection" id="accountsSection">
    <%if( util.hasAccessToObjectWithAction(access, "Account", "Query") ){%><a href="javascript:doManageAction('List', 'Account')">List Accounts</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Account", "Create") ){%><a href="javascript:doManageAction('Create', 'Account')">Create New Account</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Account", "Deposit") ){%><a href="javascript:doManageAction('Make', 'Deposit')">Make Deposit</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Account", "Modify") ){%><a href="javascript:doManageAction('Modify', 'Account')">Modify Account</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Account", "Balance") ){%><a href="javascript:doManageAction('Display', 'Balance')">Display Balances</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Account", "Query") ){%><a href="javascript:doManageAction('Statement', 'Account')">Obtain Account Statement</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Account", "Withdraw") ){%><a href="javascript:doManageAction('Withdraw', 'Account')">Make Withdrawal</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Account", "Transfer") ){%><a href="javascript:doManageAction('Transfer', 'Account')">Make Transfer</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Account", "Delete") ){%><a href="javascript:doManageAction('Delete', 'Account')">Delete Accounts</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Account", "Undelete") ){%><a href="javascript:doManageAction('Undelete', 'Account')">Undelete Accounts</a><%}%>
</div>


<%}%>
<%if( util.hasAccessToObject(access, "Reservation") ){%>
<h3 class="menuHead" id="reservations" onclick="showMenu('reservations')"><img src="images/menu_arrow_closed.gif" class="menuArrow" id="reservationsArrow" width="9" height="9" alt="" />Reservations</h3>

<div class="menuSection" id="reservationsSection">
    <%if( util.hasAccessToObjectWithAction(access, "Reservation", "Query") ){%><a href="javascript:doManageAction('List', 'Reservation')">List Reservations</a><%}%>
    
    <%if( util.hasAccessToObjectWithAction(access, "Reservation", "Modify") ){%><a href="javascript:doManageAction('Modify', 'Reservation')">Modify Reservation</a><%}%>
    <!--a href="javascript:doManageAction('Purge', 'Reservation')">Purge Inactive Reservations</a-->
    <%if( util.hasAccessToObjectWithAction(access, "Reservation", "Delete") ){%><a href="javascript:doManageAction('Delete', 'Reservation')">Delete Reservations</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Reservation", "Undelete") ){%><a href="javascript:doManageAction('Undelete', 'Reservation')">Undelete Reservations</a><%}%>
</div>

<%}%>
<%if( util.hasAccessToObject(access, "Quotation") ){%>
<h3 class="menuHead" id="quotations" onclick="showMenu('quotations')"><img src="images/menu_arrow_closed.gif" class="menuArrow" id="quotationsArrow" width="9" height="9" alt="" />Quotations</h3>

<div class="menuSection" id="quotationsSection">
    <%if( util.hasAccessToObjectWithAction(access, "Quotation", "Query") ){%><a href="javascript:doManageAction('List', 'Quotation')">List Quotation</a><%}%>
    <%--<%if( util.hasAccessToObjectWithAction(access, "Quotation", "Create") ){%><a href="javascript:doManageAction('Create', 'Quotation')">Create New Quotation</a><%}%>--%>
    <%if( util.hasAccessToObjectWithAction(access, "Quotation", "Modify") ){%><a href="javascript:doManageAction('Modify', 'Quotation')">Modify Quotation</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Quotation", "Delete") ){%><a href="javascript:doManageAction('Delete', 'Quotation')">Delete Quotations</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Quotation", "Undelete") ){%><a href="javascript:doManageAction('Undelete', 'Quotation')">Undelete Quotations</a><%}%>
</div>

<%}%>

<%if( util.hasAccessToObject(access, "ChargeRate") ){%>
<h3 class="menuHead" id="chargeRates" onclick="showMenu('chargeRates')"><img src="images/menu_arrow_closed.gif" class="menuArrow" id="chargeRatesArrow" width="9" height="9" alt="" />Charge Rates</h3>

<div class="menuSection" id="chargeRatesSection">
    <%if( util.hasAccessToObjectWithAction(access, "ChargeRate", "Query") ){%><a href="javascript:doManageAction('List', 'ChargeRate')">List Charge Rates</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "ChargeRate", "Create") ){%><a href="javascript:doManageAction('Create', 'ChargeRate')">Create New Charge Rate</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "ChargeRate", "Modify") ){%><a href="javascript:doManageAction('Modify', 'ChargeRate')">Modify Charge Rate</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "ChargeRate", "Delete") ){%><a href="javascript:doManageAction('Delete', 'ChargeRate')">Delete Charge Rates</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "ChargeRate", "Undelete") ){%><a href="javascript:doManageAction('Undelete', 'ChargeRate')">Undelete Charge Rates</a><%}%>
</div>

<%}%>
<%--if( util.hasAccessToObject(access, "DepositShare") ){%>
<h3 class="menuHead" id="depositShares" onclick="showMenu('depositShares')"><img src="images/menu_arrow_closed.gif" class="menuArrow" id="depositSharesArrow" width="9" height="9" alt="" />Deposit Shares</h3>

<div class="menuSection" id="depositSharesSection">
    <%if( util.hasAccessToObjectWithAction(access, "DepositShare", "Query") ){%><a href="javascript:doManageAction('List', 'DepositShare')">List Deposit Shares</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "DepositShare", "Create") ){%><a href="javascript:doManageAction('Create', 'DepositShare')">Create New Deposit Share</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "DepositShare", "Modify") ){%><a href="javascript:doManageAction('Modify', 'DepositShare')">Modify Deposit Share</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "DepositShare", "Delete") ){%><a href="javascript:doManageAction('Delete', 'DepositShare')">Delete Deposit Shares</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "DepositShare", "Undelete") ){%><a href="javascript:doManageAction('Undelete', 'DepositShare')">Undelete Deposit Shares</a><%}%>
</div>

<%}--%>
<%if( util.hasAccessToObject(access, "Job") ){%>
<h3 class="menuHead" id="jobs" onclick="showMenu('jobs')"><img src="images/menu_arrow_closed.gif" class="menuArrow" id="jobsArrow" width="9" height="9" alt="" />Jobs</h3>

<div class="menuSection" id="jobsSection">
    <%if( util.hasAccessToObjectWithAction(access, "Job", "Query") ){%><a href="javascript:doManageAction('List', 'Job')">List Jobs</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Job", "Create") ){%><a href="javascript:doManageAction('Create', 'Job')">Create new Job</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Job", "Modify") ){%><a href="javascript:doManageAction('Modify', 'Job')">Modify Job</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Job", "Charge") ){%><a href="javascript:doManageAction('Charge', 'Job')">Charge Job</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Job", "Reserve") ){%><a href="javascript:doManageAction('Reserve', 'Job')">Make Reservation</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Job", "Quote") ){%><a href="javascript:doManageAction('Quote', 'Job')">Obtain Job Quotation</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Job", "Refund") ){%><a href="javascript:doManageAction('Refund', 'Job')">Refund Job</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Job", "Delete") ){%><a href="javascript:doManageAction('Delete', 'Job')">Delete Jobs</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Job", "Undelete") ){%><a href="javascript:doManageAction('Undelete', 'Job')">Undelete Jobs</a><%}%>
</div>

<%}%>
<%if( util.hasAccessToObject(access, "Allocation") ){%>
<h3 class="menuHead" id="allocations" onclick="showMenu('allocations')"><img src="images/menu_arrow_closed.gif" class="menuArrow" id="allocationsArrow" width="9" height="9" alt="" />Allocation</h3>

<div class="menuSection" id="allocationsSection">
    <%if( util.hasAccessToObjectWithAction(access, "Allocation", "Query") ){%><a href="javascript:doManageAction('List', 'Allocation')">List Allocations</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Allocation", "Modify") ){%><a href="javascript:doManageAction('Modify', 'Allocation')">Modify Allocation</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Allocation", "Delete") ){%><a href="javascript:doManageAction('Delete', 'Allocation')">Delete Allocation</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Allocation", "Undelete") ){%><a href="javascript:doManageAction('Undelete', 'Allocation')">Undelete Allocation</a><%}%>
</div>
<%}%>
<%if( util.hasAccessToObject(access, "Transaction") ){%>
<h3 class="menuHead" id="transactions" onclick="showMenu('transactions')"><img src="images/menu_arrow_closed.gif" class="menuArrow" id="transactionsArrow" width="9" height="9" alt="" />Transactions</h3>

<div class="menuSection" id="transactionsSection">
    <%if( util.hasAccessToObjectWithAction(access, "Transaction", "Query") ){%><a href="javascript:doManageAction('List', 'Transaction')">List Transactions</a><%}%>
    <!--a href="javascript:doManageAction('Summary', 'Transaction')">Transaction Summary</a>
    <a href="javascript:doManageAction('Report', 'Transaction')">Other Reports</a-->
    <!--<%if( util.hasAccessToObjectWithAction(access, "Transaction", "Undo") ){%><a href="javascript:doManageAction('Undo', 'Transaction')">Undo Transactions</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Transaction", "Redo") ){%><a href="javascript:doManageAction('Redo', 'Transaction')">Redo Transactions</a><%}%>-->
</div>
<%}%>
<%if( util.hasAccessToObject(access, "Role") ){%>
<h3 class="menuHead" id="roles" onclick="showMenu('roles')"><img src="images/menu_arrow_closed.gif" class="menuArrow" id="rolesArrow" width="9" height="9" alt="" />Roles</h3>

<div class="menuSection" id="rolesSection">
    <%if( util.hasAccessToObjectWithAction(access, "Role", "Query") ){%><a href="javascript:doManageAction('List', 'Role')">List Roles</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Role", "Create") ){%><a href="javascript:doManageAction('Create', 'Role')">Create New Role</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Role", "Modify") ){%><a href="javascript:doManageAction('Modify', 'Role')">Modify Role</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Role", "Delete") ){%><a href="javascript:doManageAction('Delete', 'Role')">Delete Roles</a><%}%>
    <%if( util.hasAccessToObjectWithAction(access, "Role", "Undelete") ){%><a href="javascript:doManageAction('Undelete', 'Role')">Undelete Roles</a><%}%>
</div>
<%}%>

<form method="post" name="chooserForm" action="input.jsp" target="action">
    <input type="hidden" name="myaction" id="myaction"/>
    <input type="hidden" name="myobject" id="myobject"/>
</form>


<%--hidden until other sections are complete...
<div class="sidebarHeader">
    <div class="rightFlare"><img src="images/sidebar_header_flare_right.gif" width="5" height="19" alt="" /></div>
    <h2>Diagram</h2>
</div>

<div class="sidebarSection">
<form method="post" name="diagramChooserForm" action="input.jsp" target="action">
    <label for="myobject">Object:</label>
    <select name="myobject" id="myobject" onclick="changeActionCombo(this[selectedIndex].text, 'diagram')">
    <x:transform xslt="${option}" xml="${objXML}"/>
    </select>

    <label for="myaction">Action:</label>
    <select name="myaction" id="myaction" onchange="doManageAction()">
      <option value=''>Select an action</option>
    </select>
</form>
</div>
--%>

<%if(userBean.isAdmin()){%>
<div class="sidebarHeader">
    <div class="rightFlare"><img src="images/sidebar_header_flare_right.gif" width="5" height="19" alt="" /></div>
    <h2>Advanced</h2>
</div>

<div class="sidebarSection">
<form method="post" name="adminChooserForm" action="input.jsp" target="action">
    <label for="myobject">Object:</label>
    <select name="myobject" id="myobject" onclick="changeActionCombo(this[selectedIndex].text, 'admin')">
    <x:transform xslt="${option}" xml="${objXML}"/>
    </select>

    <label for="myaction">Action:</label>
    <select name="myaction" id="myaction" onchange="doAdminAction()">
      <option value=''>Select an action</option>
    </selectz>
</form>
</div>
<%}%>


</body>
</html>