/*
 * RequestBean.java
 *
 * Created on July 17, 2003, 6:47 PM
 */

package gold.web.client;

import javax.servlet.http.*;
import gold.*;
import org.jdom.*;
import java.util.*;
//import org.apache.log4j.Logger;
//import org.apache.log4j.BasicConfigurator;




/**
 *
 * @author  zjohns
 */
public class RequestBean{
    private Request request;
    private String mymessage;
    private String mymessages;
    private String homeDir;//Response response = reply.shiftResponse();
    private String conditionName;
    private String conditionValue;
    private String myaction;
    private String myobject;
    private ElementUtil util;
    //private static Logger logger = Logger.getLogger(RequestBean.class);
    
    
    /** Creates new RequestBean */
    public RequestBean() {
        request = new Request();
        mymessage = "";
        mymessages = "";
        homeDir = "";
        conditionName = "";
        conditionValue = "";
        myaction = "";
        myobject = "";
        util = new ElementUtil();
        //BasicConfigurator.configure();
        
    }
    
    /*
     * sets the path to the home directory so that we can read the config file
     */
    public void setHomeDir(String homeDir){
        this.homeDir = homeDir;
        System.out.println("homeDir="+homeDir);
        Config.readConfig(homeDir + "/etc/gold.conf");
        //Gold.initialize();
    }
    
    
    /*
     * adds the condition to the request object
     */
    public void addCondition(){
        if(conditionName != null && conditionValue != null && conditionName.length() > 0 && conditionValue.length() > 0)
            request.setCondition(conditionName, conditionValue);
    }
    

    
    /*
     * sets the conditionName
     */
    public void setConditionName(String name) {
        conditionName = name;
    } 
    
    /*
     * sets the conditionValue
     */
    public void setConditionValue(String name) {
        conditionValue = name;
    }
    
    
    /** Getter for property myaction.
     * @return Value of property myaction.
     *
     */
    public java.lang.String getMyaction() {
        return myaction;
    }    
    
    /** Setter for property myaction.
     * @param myaction New value of property myaction.
     *
     */
    public void setMyaction(java.lang.String myaction) {
        System.out.println("setMyaction: " + myaction);
        this.myaction = myaction;
    }    
    
    /** Getter for property myobject.
     * @return Value of property myobject.
     *
     */
    public java.lang.String getMyobject() {
        return myobject;
    }
    
    /** Setter for property myobject.
     * @param myobject New value of property myobject.
     *
     */
    public void setMyobject(java.lang.String myobject) {
        System.out.println("setMyobject: " + myobject);
        this.myobject = myobject;
    }

    /*
     * gets the request object
     */
    public Request getRequest(){
        return request;
    }
    
    /*
     * returns mymessage
     */
    public String getMymessage(){
        return mymessage;
    }


    //////////////////////////////////////////////////////////////////////////////
    ////                                                                      ////  
    ////                                                                      ////
    ////             These methods perfrom the meat of program,               ////
    ///               setting up request and getting response                 ////
    ////                                                                      ////
    ////                                                                      ////
    //////////////////////////////////////////////////////////////////////////////
    
    
    /*
     * this method sets the request's object and action with myobject & myaction
     * and it adds the contition
     */
    private void setDefaultRequest(){
        request.setObject(myobject);
        request.setAction(myaction);
        addCondition();
    }
    
    
    
    
    
    
    
    
    
    
    
    
    /*
     * This method performs the request based on what ever was set in the request object
     * before this call, creates a fresh request object to be ready for the next request
     * and returns the response object.
     */
    private Response performRequest(UserBean userBean){
        try{
            request.setActor(userBean.getUsername());
            //if it was not already set by user selection earlier, set showHidden according to userbean.
            if((request.getOptionValue("ShowHidden") == null || request.getOptionValue("ShowHidden").length() == 0) && (userBean.getShowHidden() != null))
                request.setOption("ShowHidden", userBean.getShowHidden());
                        
            System.out.println("REQUEST IS: "+request.toString());
            
            //Message mesg = new Message(Gold.TOKEN_PASSWORD, userBean.getUsername(), userBean.getPassword());
            Chunk mesgChunk = new Chunk(Gold.TOKEN_PASSWORD, userBean.getUsername(), userBean.getPassword());
            
            mesgChunk.setRequest(request);
            Chunk replyChunk = mesgChunk.getChunk();
            //mesg.pushRequest(request);
            //Reply reply = mesg.getReply();
            //Response response = reply.shiftResponse();
            Response response = replyChunk.getResponse();
            mymessage = response.getMessage();
            System.out.println("RESPONSE: "+response.toString());
            System.out.println("MESSAGE: "+mymessage);
            System.out.println("STATUS: "+response.getStatus());
            request = new Request();
            return response;
        }catch (Exception e){
            return null;
        }
    }
    
    
    
    
    
    
    
    /*
     * this method returns all objects as a string of xml, sorted by Name
     */
    public String getObjectsXML(UserBean userBean){
        System.out.println("In getObjectsXML");
        request = new Request();
        request.setAction("Query");
        request.setObject("Object");
        request.setSelection("Name", "Sort");
        conditionName = null;
        conditionValue = null;
        return util.convertResponseToXML(performRequest(userBean).getDataElement());
    }
    
    
    
    
    
    
    /*
     * This method gets the actions of the object stored in conditionValue
     */
    public String getActionsXML(UserBean userBean){
        System.out.println("In getActionsXML");
        request.setAction("Query");
        request.setObject("Action");
        request.setSelection("Name", "Sort");
        conditionName = "Object";
        addCondition();
        
        return util.convertResponseToXML(performRequest(userBean).getDataElement());
    }
    
     
    
    
    /*
     * This method gets xml for the attributes for an object that we need to make an input form on.
     * For example when creating a new user or machine.
     */
    public String getInputXML(UserBean userBean){
        Element data = getInputData(userBean);
        this.addObjectActionMessage(data);
        
        
        return util.convertResponseToXML(data);
    }

     
    
    
    
    /*
     * This method gets xml for the attributes for an object that we need to make an input form on.
     * For example when creating a new user or machine.
     */
    public Element getInputData(UserBean userBean){   
        System.out.println("In getInputData, action:" + myaction +" userBean.getUserAction(): " + userBean.getUserAction());
        conditionName = "Object";
        conditionValue = myobject;
        if("Create".equalsIgnoreCase(myaction) || "Modify".equalsIgnoreCase(myaction)){
            setDefaultAttributeSelections(userBean.getUserAction());
            //if("Modify".equalsIgnoreCase(myaction))
                //request.setCondition("Fixed", "f");
            return getAttributesData(userBean);
        }
        
        prepareRequestforQuery();
        return performRequest(userBean).getDataElement();
    }
    
       
    
    /*
     * This gets the attributes of the selected object and determines
     * if more request need to be made in order to populate foreign keys
     * for the user to select from or special values.
     */
    private String getAttributesXML(UserBean userBean){
        System.out.println("In getAttributesXML");
        Element data = getAttributesData(userBean);
        //add to XML myaction & myobject:
        this.addObjectActionMessage(data);
        
        return util.convertResponseToXML(data);
    }
    
    
    
    
    /*
     * This gets the attributes of the selected object and determines
     * if more request need to be made in order to populate foreign keys
     * for the user to select from or special values.
     */
    private Element getAttributesData(UserBean userBean){ 
        Response response = performRequest(userBean); 
        
        
        //check foreignKey for each attribute returned to see if
        //we need to make a select list:
        Element attribute;
        Element data = response.getDataElement();
        String foreignKey, optionText;
        if(data == null) return null;
        Iterator itr = (data.getChildren()).iterator();
        while(itr.hasNext()) {
            attribute = (Element)itr.next();
            foreignKey = attribute.getChildText("Values");
            if((foreignKey != null) && (foreignKey.length() > 0) && (foreignKey.startsWith("(") )){
                //need to get the list of values
                //request.setCondition("Attribute", attribute.getChildText("Name"));
                //doValueQuery(attribute, userBean);
                //addCondition();//sets the object condition
                
                
                /*
                 *need to create select box based on what's inside paren's:
                 *"(scott,zjohns,ge,mo)" -> make select box for each
                 */
                
                createValuesSelectBox(attribute, foreignKey);
            }
            else if(foreignKey != null && foreignKey.length() > 0 && (foreignKey.startsWith("@"))) {
                //doForeignKeyQuery(attribute, userBean);
                optionText = getPrimaryKey(userBean, attribute.getChildText("Values").substring(1));
                if(optionText != null && optionText.length() > 0) {
                    createSelectBox(attribute, userBean, optionText, attribute.getChildText("Values").substring(1));
                }
            }
            attribute.removeChild("Values") ;
        }
        return data;
    }
    
    
    
    
    
    
    
    /*
     * this method makes a select box to be used by the xslt when creating the web page. 
     * It first does a query on the object that needs the selectBox for it. It then adds a
     * select child element to the attribute element passed in. And finally, it
     * iterates thru the elements returned from the query to add an option for each one.
     */
    private void createSelectBox(Element attribute, UserBean userBean, String optionText, String object){
        request.setObject(object);//objectToMakeSelectWith
        request.setAction("Query");
        request.setSelection(optionText, "Sort");//whatToMakeListWith
        Element data = performRequest(userBean).getDataElement();
       
        if(data == null) return;
        
        Element select = util.addElement(attribute, "Select");
        Iterator itr = (data.getChildren()).iterator();
        
        
        Element option = new Element("Option");
        option.setAttribute("value", "");
        option.setText("");
        select.getChildren().add(option);
        Element value;
        String name;
        while(itr.hasNext()) {
            value = (Element)itr.next();
            name = value.getChildText(optionText);//optionText
            option = new Element("Option");
            option.setAttribute("value", name);
            if(name.equalsIgnoreCase(attribute.getChildText("DefaultValue")))
                option.setAttribute("selected", "true");
            option.setText(name);
            select.getChildren().add(option);
        }
    }
    
     private void createValuesSelectBox(Element attribute, String valuesString){
        Element select = util.addElement(attribute, "Select");
        Element option = new Element("Option");
        option.setAttribute("value", "");
        option.setText("");
        select.getChildren().add(option);
        Element value;
        String name;
        valuesString = valuesString.substring(1, valuesString.length() -1);
        System.out.println("\n\n\n*************\nvaluesString: " +valuesString +"\n*************\n\n\n");
        String[] values = valuesString.split(",");
        
        for(int i=0; i < values.length; i++){
            
            name = values[i];
            option = new Element("Option");
            option.setAttribute("value", name);
            if(name.equalsIgnoreCase(attribute.getChildText("DefaultValue")))
                option.setAttribute("selected", "true");
            option.setText(name);
            select.getChildren().add(option);
        }
     }
    
    
    /**
     *returns the mymessage from the last request performed as xml with Data as the root
     */
    private String messageAsXml(){
        
        Element data = new Element("Data");
        if(mymessages != null && mymessages.length() > 0)
            util.addElementAndValue(data, "mymessages", mymessages);
        util.addElementAndValue(data, "mymessage", mymessage);
        return util.convertResponseToXML(data);
    }
    
    
    

    
    
    /*
     * this method is called from modify_select.  It returns the xml that represents
     * a list of all objects of the type myobject, with the condition that "Special"
     * is false.  It identifies the primary key of this object in the xml in order
     * for the page to make that field a link to click on that will bring up the
     * modify page on that object. 
     */
    public String getObjectList(UserBean userBean, ConditionBean conditionBean){
        System.out.println("In getObjectList, userBean.toString() =" + userBean.toString() + "\nrequestBean.toString() = " + toString());
        Element data = getObjectListElement(userBean, conditionBean, null);
        
        if(data == null) return messageAsXml();
        return util.convertResponseToXML(data);
    }    
    
    
    public String getAccountList(UserBean userBean, ConditionBean conditionBean){
        System.out.println("In getAccountList, userBean.toString() =" + userBean.toString() + "\nrequestBean.toString() = " + toString());
        Element data = getObjectListElement(userBean, conditionBean, null);
        try{
        //removed unwanted fields: description and subaccounts (accountaccounts)
        Iterator itr = (data.getChildren()).iterator();
        //System.out.println("\n\n\n((((((((((((((((((((((((((((((((((((((((\n");
        while(itr.hasNext()) {
            Element child = (Element)itr.next();
            if("Attributes".equalsIgnoreCase(child.getName())){
                Element attirData = child.getChild("Data");
                //System.out.println("attirData:");
                //util.convertResponseToXML(attirData);
                //Iterator thru Attributes & children (AccountProject, AccountAccount, etc.)
                Iterator itr2 = (attirData.getChildren()).iterator();
                while(itr2.hasNext()) {
                    Element childchild = (Element)itr2.next();
                    //System.out.println("childchild:");
                    //util.convertResponseToXML(childchild);
                    if(childchild.getChildText("Name") != null && childchild.getChildText("Name").equalsIgnoreCase("Description")) {
                        childchild.setAttribute("Hidden", "True");
                    } else if(childchild.getName().equalsIgnoreCase("AccountAccount")) {
                        childchild.setAttribute("Hidden", "True");
                        Iterator itr3 = (childchild.getChildren()).iterator();
                        while(itr3.hasNext()) {
                            ((Element)itr3.next()).setAttribute("Hidden", "True");
                        }
                    }
                }
            }else if("Account".equalsIgnoreCase(child.getName())){
                if(child.getChild("Description") != null) child.getChild("Description").setAttribute("Hidden", "True");
                if(child.getChild("AccountAccounts") != null) {
                    child.getChild("AccountAccounts").setAttribute("Hidden", "True");
                    child.getChild("AccountAccounts").removeAttribute("Link");
                }
            }
        }
        }catch(Exception e){
            System.out.println("ops!");
            e.printStackTrace();
        }
            
        if(data == null) return messageAsXml();
        return util.convertResponseToXML(data);
    }
    
    /* no longer used
    private void setUpAccountQuery(HttpServletRequest servletRequest, String toOrFrom){
        System.out.println("setUpAccountQuery");
        //request.setObject("Account");
        request.setOption("UseRules", "True");
        request.setOption("SubtractReservationFromAmount", "True");
        request.setOption("SortByExpendability", "True");
               
        if(servletRequest.getParameter(toOrFrom+"Id") != null){
            request.setCondition("Id", servletRequest.getParameter(toOrFrom+"Id"));
        }
        else{
            request.setOption("User", servletRequest.getParameter(toOrFrom+"User"));
            request.setOption("Project", servletRequest.getParameter(toOrFrom+"Project"));
            request.setOption("Machine", servletRequest.getParameter(toOrFrom+"Machine"));   
        }
    }
    */
    
    private Element getObjectListElement(UserBean userBean, ConditionBean conditionBean, HttpServletRequest servletRequest){
        System.out.println("getObjectListElement, myobject:"+ myobject);
        //find out the primary key of this object in order to know which 
        //attribute to make a link to the modify page:
        String[] primaryKey = getPrimaryKeys(userBean, myobject);
        
        //error condition:
        if(primaryKey == null || primaryKey.length == 0) 
            return null;//messageAsXml();
        
        userBean.setKey(primaryKey[0]);  
        
        //get the default attributes to set the selection & sort or tros
        Element attributes = getAttributes(userBean, myobject);
        
        //if special is an attribute of this object, don't include those objects
        request.setAction("Query");
        request.setObject("Attribute");
        request.setCondition("Object", myobject);
        Element data = performRequest(userBean).getDataElement();

        if(util.hasChildWithText(data, "Name", "Special"))
            request.setCondition("Special", "False");
        
        request.setAction("Query");
        request.setObject(myobject);
        Iterator itr;
        //if the conditonBean is passed in, add conditons to the query:
        if(conditionBean != null){
            setConditions(conditionBean);
            setOptions(conditionBean);
        }
        
        if("Undelete".equalsIgnoreCase(myaction))
            request.setCondition("Deleted", "True");
        
        //1. set default selections:
        itr = (attributes.getChildren()).iterator();
        while(itr.hasNext()) {
            Element child = (Element)itr.next();
            if(conditionBean != null && conditionBean.getFieldNames() != null && conditionBean.getFieldOperators() != null){
                if(!conditionBean.getFieldNames().startsWith(child.getChildText("Name")) )
                    request.setSelection(child.getChildText("Name"));
                else setFields(conditionBean);
            }else if(conditionBean == null && primaryKey[0].equalsIgnoreCase(child.getChildText("Name")))
                request.setSelection(child.getChildText("Name"), "Sort");
            else if(conditionBean == null )
                request.setSelection(child.getChildText("Name"));   
        }
        
        data = performRequest(userBean).getDataElement();

        
        if(data != null){
            String keys, names;
            itr = (data.getChildren()).iterator();
            while(itr.hasNext()) {
                keys = "";
                names = "";
                Element child = (Element)itr.next();
                for(int i = 0; i < primaryKey.length; i++){
                    keys += child.getChildText(primaryKey[i]) + ",";
                    names += primaryKey[i] + ",";
                }
                util.addElementAndValue(child, "PrimaryKeyValues", keys);
                util.addElementAndValue(child, "PrimaryKeyNames", names);      
                
            }
            util.setChildrenAttributes(data, "PrimaryKeyValues", "Hidden", "True");
            util.setChildrenAttributes(data, "PrimaryKeyNames", "Hidden", "True");
        }
        else data = new Element("Data");
        
        //now get any links associated with this object if it is "Project", like Project has projectusers, etc.
        
        this.addComplexObjectChildren(userBean, data, attributes, primaryKey[0]); 
        
        
        //if we're listing accounts, add on to the end the Amount element for the table header:
        if("Account".equalsIgnoreCase(myobject)){
            //Element attribute = new Element("Attribute");
            //Element amount = new Element("Name");
            //amount.setText("Amount");
            //attribute.getChildren().add(amount);
            //attributes.getChild("Data").getChildren().add(attribute);
            System.out.println("attributes: ");
            util.convertResponseToXML(attributes);
            //start with an existing attribute and just change the name and add it in at the end
            Element amountAttribute = (Element)attributes.getChild("Attribute").clone();
            amountAttribute.getChild("Name").setText("Amount");
            amountAttribute.getChildren().add(new Element("DontSort"));
            attributes.getChildren().add(amountAttribute);
            System.out.println("attributes: ");
            util.convertResponseToXML(attributes);
        }
                
        util.addElement(data, "Attributes").addContent(attributes);
        
        addObjectActionMessage(data);
        
        //if the user pressed one of the table headers to sort, pass that info back into the page:
        if((conditionBean != null) && (conditionBean.getFieldNames() != null) && (conditionBean.getFieldNames().length() > 0)){
            util.addElementAndValue(data, "FieldName", conditionBean.getFieldNames());
            util.addElementAndValue(data, "FieldOperator", conditionBean.getFieldOperators());
        }else{
            util.addElementAndValue(data, "FieldName", primaryKey[0]);
            util.addElementAndValue(data, "FieldOperator", "Sort");        
        }
        
        if((conditionBean != null) && (conditionBean.getConditionNames() != null) && (conditionBean.getConditionNames().length() > 0))
            util.addElementAndValue(data, "ConditionName", conditionBean.getConditionNames());
        if((conditionBean != null) && (conditionBean.getConditionValues() != null) && (conditionBean.getConditionValues().length() > 0))
            util.addElementAndValue(data, "ConditionValue", conditionBean.getConditionValues());
        if((conditionBean != null) && (conditionBean.getConditionOperators() != null) && (conditionBean.getConditionOperators().length() > 0))
            util.addElementAndValue(data, "ConditionOperator", conditionBean.getConditionOperators());
        
        
        
        System.out.println("getObjectList's data: " + util.convertResponseToXML(data));
        return data;
    }
    
    
    private void addComplexObjectChildren(UserBean userBean, Element data, Element attributes, String pkey){
        request.setAction("Query");
        request.setObject("Object");//"Project"+object
        request.setCondition("Parent", myobject);
        Element links = performRequest(userBean).getDataElement();
        
        //deal with Accounts who have a link to Allocations but it is not stored that way
        if("Account".equalsIgnoreCase(myobject)){
            Element allocation = new Element("Object");
            Element name = new Element("Name");
            name.setText("Allocation");
            allocation.getChildren().add(name);
            links.getChildren().add(allocation);
            //also for now remove the organization & Accounts links
            if(links == null || links.getChildren() == null) return;
            Iterator itr = (links.getChildren()).iterator();
            Element child;
            while(itr.hasNext()) {
                child = ((Element)itr.next());
                if(child.getChildText("Name") != null && (
                    child.getChildText("Name").equalsIgnoreCase("AccountOrganization") || 
                    child.getChildText("Name").equalsIgnoreCase("AccountAccount")))
                    itr.remove();
            }
        }
        
        
        System.out.println("links to "+ myobject);
        util.convertResponseToXML(links);
        if(links == null || links.getChildren() == null) return;
        Iterator itr = (links.getChildren()).iterator();
        //loop thru all of the ProjectUsers, ProjectProjects, or ProjectMachines and match up
        //who is on which project
        String childName;
        Element projectElement, child, size;
        while(itr.hasNext()) {
            child = ((Element)itr.next());
            childName = child.getChildText("Name");
            addLinkingChildren(childName, pkey, userBean, data);
        }    
        //loop thru again to get the links attributes to use as column headers and
        //to get the max counts of each child in order to do cell spacing
        itr = (links.getChildren()).iterator();
        while(itr.hasNext()) {
            child = ((Element)itr.next());
            childName = child.getChildText("Name");
            if(!"Allocation".equalsIgnoreCase(childName)){
                //get the default attributes to set the selection & sort or tros, the table header, and blank links
                Element projectAttributes = getAttributes(userBean, childName);
                System.out.println("projectAttributes: ");
                util.convertResponseToXML(projectAttributes);
                projectAttributes.setName(childName);
                attributes.getChildren().add(projectAttributes);
                addMaxChildCounts(childName+"s", data, projectAttributes);
            }else{
		//the column header has already been taken care of, just get the maxcounts so that we
		//can fill in blank ones for when there are none
                try{
                Element allocationAttributes = new Element("Data");
                Element attribute = new Element("Attribute");
                Element name = new Element("Name");
                name.setText("Sum");
                attribute.getChildren().add(name);
                allocationAttributes.getChildren().add(attribute);
                addMaxChildCounts("Allocations", data, allocationAttributes);    
                }catch(Exception e){e.printStackTrace();}
	    }
        }


    }
    
    
    private void addMaxChildCounts(String object, Element data, Element objectData){
        
        Iterator itr = (data.getChildren()).iterator();
        Iterator itr2, itr3;
        Element child, childChild, blankChild;
        int count = 0;
        while(itr.hasNext()) {
            child = (Element)itr.next();//should be a project
            if(child.getChild("MaxChildCount")==null){
                util.addElementAndValue(child, "MaxChildCount", "0");
            }
            itr2 = (child.getChildren()).iterator();
            while(itr2.hasNext()) {//iterate thru each attribute: Users, Projects, & Machines
                childChild = (Element)itr2.next();
                if(childChild.getName().equalsIgnoreCase(object)){//IE: Users
                    count = 0;
                    count = childChild.getChildren().size();
                    System.out.println("count for " + object);
                    util.convertResponseToXML(childChild);
                    System.out.println(count);
                    try{
                        if(count > Integer.parseInt(child.getChildText("MaxChildCount")))
                            child.getChild("MaxChildCount").setText(Integer.toString(count));
                    }catch(Exception e){}
                    //if there are no children of this type, put in a blank one as a spacer:
                    if(count == 0){
                        itr3 = (objectData.getChildren()).iterator();
                        Element spacer = new Element(objectData.getName());
                        while(itr3.hasNext()) {//iterate thru each attribute: Users, Projects, & Machines
                            blankChild = (Element)itr3.next();
                            //if the child's Name attribute is not the object selected
                            if(!blankChild.getChildText("Name").equalsIgnoreCase(myobject))
                                util.addElementAndValue(spacer, blankChild.getChildText("Name"),  "");
                        }
                        childChild.addContent(spacer);
                    }
                }
            }
            
        }
        util.setChildrenAttributes(data, "MaxChildCount", "Hidden", "True");    
    }
    
    
    private Element getAttributes(UserBean userBean, String object){
        request.setAction("Query");
        request.setObject("Attribute");
        request.setCondition("Object", object);
        request.setCondition("Hidden", "True", "NE");
        return performRequest(userBean).getDataElement();
        
    }
    
    
    public void addObjectActionMessage(Element data){
        
        if(mymessages != null && mymessages.length() > 0)
            util.addElementAndValue(data, "mymessages", mymessages);
        util.addElementAndValue(data, "myobject", myobject);
        util.addElementAndValue(data, "mymessage", mymessage);
        util.addElementAndValue(data, "myaction", myaction);
    }
    

     //String[] children = {"AccountUser", "AccountProject", "AccountMachine", "AccountAccount"};
        // this.addLinkingChildren(children[i], "Id", userBean, data);
    private void addLinkingChildren(String object, String pkey, UserBean userBean, Element parentData){   
        System.out.println("in addLinkingChildren: object=" +object+", pkey="+pkey);
        //1. for every project, add a Users, Projects, or Machines child that we're about to fill in:
        
        util.setChildrenChildrenAndAttribute(parentData, object + "s", "Link", "True");
        
        //2. query for ProjectUsers, ProjectProjects, or ProjectMachines:
        request.setAction("Query");
        request.setObject(object);//"Project"+object
        if("Allocation".equalsIgnoreCase(object)){
            request.setCondition("Active", "True");
            request.setSelection("Amount", "Sum");
            request.setSelection("Account", "GroupBy");
        }
        
        Element data = performRequest(userBean).getDataElement();
        if(data == null || data.getChildren() == null) return;
        Iterator itr = (data.getChildren()).iterator();
        //loop thru all of the ProjectUsers, ProjectProjects, or ProjectMachines and match up
        //who is on which project
        String parentName;
        Element parentElement, child, size;
        while(itr.hasNext()) {
            child = ((Element)itr.next());
            parentName = child.getChildText(myobject);
            parentElement = util.getChildsParent(parentData, pkey, parentName);//childname, childValue
            if(parentElement != null){
                child.removeChild(myobject);
                parentElement.getChild(object + "s").getChildren().add(child.clone());
            }
        }
        System.out.println("\n\n:addLinkingChildren's data: " + util.convertResponseToXML(parentData)+ "\n*****\n\n");
    }   

    
    /*
     * returns the primary keys for object's with more than one primary key
     */
    public String[] getPrimaryKeys(UserBean userBean, String object){
        System.out.println("getPrimaryKeys");
        //do an attribute query to find out the primary key of this object in order to know which 
        //attribute to make a link to the modify page:
        //Request request = new Request();
        request.setAction("Query");
        request.setObject("Attribute");
        request.setCondition("Object", object);
        request.setCondition("PrimaryKey", "True");        
        request.setSelection("Name", "Sort");
        Element data = performRequest(userBean).getDataElement();
                
        if(data == null) 
            return null;
        //return the primaryKey(s)
        //return data.getChild("Attribute").getChildText("Name");     
        Iterator itr = (data.getChildren()).iterator();
        Element child = null;
        String childText = null;
        Vector keys = new Vector();
        while(itr.hasNext()) {
            child = ((Element)itr.next());
            keys.addElement(child.getChildText("Name"));
        }
        String[] keyStrings = new String[keys.size()];
        keys.toArray(keyStrings);
        return keyStrings;
    }
   
    
      /*
     * returns the primary key for object
     */
    public String getPrimaryKey(UserBean userBean, String object){
        System.out.println("getPrimaryKey");
        //do an attribute query to find out the primary key of this object in order to know which 
        //attribute to make a link to the modify page:
        //Request request = new Request();
        request.setAction("Query");
        request.setObject("Attribute");
        request.setCondition("Object", object);
        request.setCondition("PrimaryKey", "True");        
        request.setSelection("Name", "Sort");
        Element data = performRequest(userBean).getDataElement();
                
        if(data == null) 
            return null;
        //return the primaryKey
        return data.getChild("Attribute").getChildText("Name");     
    }
    
    
     
    
    /*
     * this method prepares the request object for the query necessary for
     * the create page.  it is called when myaction is "Modify" or "Create"
     * 
     */
    private void setDefaultAttributeSelections(String usersAction){
        System.out.println("In setDefaultAttributeSelections");
        addCondition();
        request.setAction("Query");
        
        if("Create".equalsIgnoreCase(myaction) || "modify_project".equalsIgnoreCase(usersAction) || "Modify".equalsIgnoreCase(myaction) )
            request.setCondition("Hidden", "False");
        
        if(!"Modify".equalsIgnoreCase(myaction) )
            request.setCondition("DataType", "AutoGen", "NE");
        request.setObject("Attribute");
        request.setSelection("Name");
        request.setSelection("DataType");
        request.setSelection("PrimaryKey");
        request.setSelection("Required");
        request.setSelection("DefaultValue");
        request.setSelection("Values");
        request.setSelection("Description");
        //request.setSelection("Size");
        request.setSelection("Sequence", "Sort");
        request.setSelection("Fixed");
       
        //These don't seem to be used for create:
        //request.setSelection("Required");
        //request.setSelection("Hidden");
        //request.setSelection("Fixed");
        //request.setSelection("Usage");
    }
    
 
    
    
    
    
    /*
     * this method perpares the request object for an object query
     */
    private void prepareRequestforQuery(){
        System.out.println("In prepareRequestforQuery");
        addCondition();
        request.setAction("Query");
        request.setObject("Attribute");
        request.setSelection("Name", "Sort");
        request.setSelection("DataType");
    }
    
    
    
    
   
    /**
     * This method is called by the admin_input.jsp to return xml depending on what action
     * the user selected.
     */
    public String doAction(HttpServletRequest httpRequest, ConditionBean conditionBean, UserBean userBean, boolean setData, AccountBean accountBean){
        System.out.println("In doAction, myaction="+myaction +", myobject="+myobject);
        mymessages = "";
        Element data = doActionGetElement(httpRequest, conditionBean, userBean, accountBean);
        if("modify_object".equalsIgnoreCase(conditionBean.getThisAction()) || setData) 
            userBean.setOriginalObject(data);
        String xml = "";
        if(data == null) 
            return messageAsXml();
        
        addObjectActionMessage(data);
        
        mymessages = "";
        userBean.setUserAction("");//reset any actions
        return util.convertResponseToXML(data);
    }
    
    
    
    
    /**
     * called by doAction
     */
    private Element doActionGetElement(HttpServletRequest httpRequest, ConditionBean conditionBean, UserBean userBean, AccountBean accountBean){
        System.out.println("In doActionGetElement");
        if("modifyProject".equalsIgnoreCase(myaction) || "modifyAccount".equalsIgnoreCase(myaction) || 
           "modifyDepositShare".equalsIgnoreCase(myaction) || "modifyRole".equalsIgnoreCase(myaction))
            return doModifyComplexObject(httpRequest, userBean, conditionBean);
        
        boolean doRequest = true;
        request.setAction(myaction);
        request.setObject(myobject);
        if("create".equalsIgnoreCase(myaction)){
            setAssignments(httpRequest);
        }else if("query".equalsIgnoreCase(myaction)){
            setConditions(conditionBean);
            setFields(conditionBean);
        }else if("modify".equalsIgnoreCase(myaction)){
            doRequest = setAssignments(conditionBean, httpRequest, userBean);//setAssignments(conditionBean);
        }else if(("Quote".equalsIgnoreCase(myaction) || "Reserve".equalsIgnoreCase(myaction) || "Charge".equalsIgnoreCase(myaction)) && "Job".equalsIgnoreCase(myobject)) {
            setDatum(httpRequest);
        }else if("createProject".equalsIgnoreCase(myaction)){
            return doCreateProject(httpRequest, userBean);
        }else if("createReservation".equalsIgnoreCase(myaction)){
            return doCreateReservation(httpRequest, userBean);
        }else if("createQuotation".equalsIgnoreCase(myaction)){
            return doCreateQuotation(httpRequest, userBean);
        }else if("createAccount".equalsIgnoreCase(myaction)){
            return doCreateAccount(httpRequest, userBean, accountBean);
        //}else if("createDepositShare".equalsIgnoreCase(myaction)){
            //return doCreateDepositShare(httpRequest, userBean);
        //}else if("Transfer".equalsIgnoreCase(myaction)){
        //    return this.makeTransfer(httpRequest, userBean, accountBean);
        }else if("createRoles".equalsIgnoreCase(myaction)){
            return doCreateRoles(httpRequest, userBean);
        }else if("Withdraw".equalsIgnoreCase(myaction) ||"Transfer".equalsIgnoreCase(myaction) || "Refund".equalsIgnoreCase(myaction) || "Undo".equalsIgnoreCase(myaction)){// || "Transfer".equalsIgnoreCase(myaction)){
            setOptions(httpRequest);
            //doRequest = false;
        }else if("Deposit".equalsIgnoreCase(myaction)){
            doDeposit(userBean, httpRequest);
        }else{ 
            setConditions(conditionBean);
        }
        
        setOptions(conditionBean);
        
        
        if(!doRequest){
            Element data = new Element("Data");
            util.addElement(data, myobject);
            return data;
        }
        Response response = performRequest(userBean);
        Element data = response.getDataElement();
        
        if((data == null) && (userBean.getUserAction() != null) && (userBean.getUserAction().endsWith("project"))){
            data = new Element("Data");
            util.addElement(data, myobject);
        }
        System.out.println("doActionGetElement returning: "+ util.convertResponseToXML(data));
        return (Element)data;
    }
    
    
    private void setDatum(HttpServletRequest httpRequest){
        Datum datum = new Datum(myobject);
        
        Enumeration paramNames = httpRequest.getParameterNames();
        String paramName, paramValue;
        
        while (paramNames.hasMoreElements()){
            
            paramName = (String)paramNames.nextElement();
            paramValue = httpRequest.getParameter(paramName);
            System.out.println("datum param: "+paramName+"="+paramValue);
            
            if(paramValue != null && paramValue.length() > 0){
                if(paramName.equalsIgnoreCase("Guarantee"))
                    request.setOption("Guarantee", paramValue);
                else
                    datum.setValue(paramName, paramValue);
            }
        }
        
        request.setDatum(datum);
    }
    
    
    /*
     * this method uses the fieldNames and fieldOperators in the conditionBean
     * to call setSelection on the request object.  This method is called when 
     * querying an object.
     */
    private void setFields(ConditionBean conditionBean){
        System.out.println("In setFields");
        //variables used in setting fields to display
        String attribute;
        String operator;
        String[] attributes = conditionBean.getFieldNamesAsArray();
        String[] operators = conditionBean.getFieldOperatorsAsArray();
        
        for(int i = 0; i < attributes.length; i++){    
            attribute = attributes[i];
            try{
                operator = operators[i];
            }catch(IndexOutOfBoundsException e){operator = null;}
            //have to have an attribute in order to add a selection:
            if((attribute != null) && (attribute.length() > 0)){
                if((operator != null) && (operator.length() == 0)) operator = null;
                request.setSelection(attribute, operator);
                System.out.println("Set selection: " + attribute + ", " + operator);
            }
        }
        
        if(conditionBean.isHidden())
            request.setOption("ShowHidden", "True");
    }
    
    
    
    
    
    
    
    
    /*
     * this method uses the conditionBean's condition's to set
     * conditions in the request bean
     */
    private boolean setConditions(ConditionBean conditionBean){
        boolean foundCondition = false;
        System.out.println("In setConditions");
        //variables used in setCondition call:
        String name = "";
        String value = "";
        String conditionOperator = "";
        String conjunction = "";
        String group = "";
        String[] names = conditionBean.getConditionNamesAsArray();
        String[] values = conditionBean.getConditionValuesAsArray();
        String[] conditionOperators = conditionBean.getConditionOperatorsAsArray();
        String[] conjunctions = conditionBean.getConjunctionsAsArray();
        String[] groups = conditionBean.getGroupsAsArray();
        
        for(int i = 0; i < names.length; i++){
            name = names[i];
            try{
                value = values[i];
            }catch(IndexOutOfBoundsException e){value = null;}
            try{
                conditionOperator = conditionOperators[i];
            }catch(IndexOutOfBoundsException e){conditionOperator = null;}
            try{
                conjunction = conjunctions[i];
            }catch(IndexOutOfBoundsException e){conjunction = null;}
            try{
                group = groups[i];
            }catch(IndexOutOfBoundsException e){group = null;}
            
            //have to at least have a name
            if((name != null) && (name.length() > 0)){
               //can optionally have condtionOperator
                if((value != null) && (value.length() == 0))value = null;
                if((conditionOperator != null) && (conditionOperator.length() == 0))conditionOperator = null;
                if((conjunction != null) && (conjunction.length() == 0))conjunction = null;   
                if((group != null) && (group.length() == 0))group = null;   
                /*if("Delete".equalsIgnoreCase(myaction) || "Undelete".equalsIgnoreCase(myaction)){
                    if(i == 0 && names.length > 1)
                        request.setCondition(name, value, "EQ", "", "1");
                    else if((i == (names.length -1)) && (names.length > 1))
                        request.setCondition(name, value, "EQ", "Or", "-1");
                    else
                        request.setCondition(name, value, "EQ", "Or", "0");
                //}
                else*/
                    request.setCondition(name, value, conditionOperator, conjunction, group);
                System.out.println("setCondition: " + name +", "+ value+", "+conditionOperator+", "+conjunction+", "+group);
                foundCondition = true;
            }
        }
        
        
        /*
         counter = 1;
            length = response.getCount();
            while(itr.hasNext()) {
                attribute = (Element)itr.next();
                id = attribute.getChildText("Id");
                //find matching AccountProjects, AccountUsers, AccountMachines.
                //fist add the conditions to the request before passing it on to the addLinkingChildren method:
                if(counter == 1 && length > 1)
                    request.setCondition("Parent", id, "EQ", "", "1");
                else if(counter == length && length > 1)
                    request.setCondition("Parent", id, "EQ", "Or", "-1");
                else
                    request.setCondition("Parent", id, "EQ", "Or", "0");
                counter++;
            }
         */
        return foundCondition;
    }
    
    
     /*
     * this method uses the conditionBean's condition's to set
     * conditions in the request bean
     */
    private boolean setOptions(ConditionBean conditionBean){
        boolean foundCondition = false;
        System.out.println("In setOptions");
        //variables used in setCondition call:
        String name = "";
        String value = "";
        String[] names = conditionBean.getOptionNamesAsArray();
        String[] values = conditionBean.getOptionValuesAsArray();
        
        for(int i = 0; i < names.length; i++){
            name = names[i];
            try{
                value = values[i];
            }catch(IndexOutOfBoundsException e){value = null;}
                       
            //have to at least have a name
            if((name != null) && (name.length() > 0)){
               //can optionally have condtionOperator
                if((value != null) && (value.length() == 0))value = null;
                request.setOption(name, value);
                System.out.println("setOption: " + name +", "+ value);
                foundCondition = true;
            }
        }
        return foundCondition;
    }     
    
    /*
     * this method uses the conditionBean's condition's to set
     * conditions in the request bean
     */
    private void setOptions(HttpServletRequest servletRequest){
        boolean foundCondition = false;
        System.out.println("In setOptions with servletrequest object");
        //variables used in setCondition call:
        Enumeration paramNames = servletRequest.getParameterNames();
        String paramName;
        String[] paramValues;
        while (paramNames.hasMoreElements()){
            paramName = (String)paramNames.nextElement();
            paramValues = servletRequest.getParameterValues(paramName);
            for(int i = 0; i < paramValues.length; i++){
                System.out.println("param: "+paramName+" = "+paramValues[i]);
                if(paramValues[i] != null && paramValues[i].length() > 0)
                    request.setOption(paramName, paramValues[i]);
            }
        }
    }
    
    
    
    
    
    private boolean setAssignments(ConditionBean conditionBean, HttpServletRequest httpRequest, UserBean userBean){
        boolean modified = false;
        if("modify_object".equalsIgnoreCase(conditionBean.getThisAction())){
            modified = setConditions(conditionBean);
            if(modified) {//if we've determined which object to modify, see which attributes to modify:
                modified = this.setModifiedFields(userBean.getOriginalObject(), httpRequest);
            }
            return modified;
            //setAssignments(httpRequest);
        }
        else return setAssignmentsAndConditions(conditionBean);
    }
    
    
    
    
    /*
     * called when creating a new object, simply takes every paramName and value pair
     * from the httpRequest object and calls setAssignment on the request object
     */
    private void setAssignments(HttpServletRequest httpRequest){
        System.out.println("In setAssignment");
        Enumeration paramNames = httpRequest.getParameterNames();
        String paramName, paramValue;
        while (paramNames.hasMoreElements()){
            paramName = (String)paramNames.nextElement();
            paramValue = httpRequest.getParameter(paramName);
            System.out.println("request param: "+paramName+"="+paramValue);
            //igore params that were used in the conditionBean:
            if(!"conditionNames".equalsIgnoreCase(paramName) && !"conditionValues".equalsIgnoreCase(paramName) &&
               !"viewType".equalsIgnoreCase(paramName) && !"thisAction".equalsIgnoreCase(paramName) && 
               !paramName.endsWith("optionValue") && !paramName.endsWith("optionName") ){
                if(paramValue != null && paramValue.length() > 0) {
                    request.setAssignment(paramName, paramValue);
                    System.out.println("request.setAssignment("+paramName+", "+paramValue+");");
                }
            }
        }
    }
    
    
    /*
     * this is called when modifying an object.  It uses the fieldNames,
     * fieldOperators, and fieldValues from the condititonBean to call
     * setAssignment on the request object
     */
    private boolean setAssignmentsAndConditions(ConditionBean conditionBean){
        System.out.println("In setAssignmentsAndConditions");
        boolean modified = false;
        setConditions(conditionBean);
        //variables used in setting fields to display
        String attribute;
        String operator;
        String fieldValue;
        String[] attributes = conditionBean.getFieldNamesAsArray();
        String[] operators = conditionBean.getFieldOperatorsAsArray();
        String[] fieldValues = conditionBean.getFieldValuesAsArray();
        
        
        for(int i = 0; i < attributes.length; i++){    
            attribute = attributes[i];
            try{
                fieldValue = fieldValues[i];
            }catch(IndexOutOfBoundsException e){fieldValue = null;}
            try{
                operator = operators[i];
            }catch(IndexOutOfBoundsException e){operator = null;}
            //have to have an attribute in order to add a selection:
            if((attribute != null) && (attribute.length() > 0)){
                if((operator != null) && (operator.length() == 0)) operator = null;
                if((fieldValue != null) && (fieldValue.length() == 0)) fieldValue = null;
                request.setAssignment(attribute, fieldValue, operator);
                modified = true;
            }
        }
        return modified;
    }
    
    

     //IE: object would be "User", "Project", "Machine"
     private void createProjectChildren(String object, HttpServletRequest httpRequest, UserBean userBean, Element parentData){   
        
        Element projectChild = util.addElement(parentData, object + "s");
        Element data;
        String paramName, paramValue;
        String[] paramValues;
        Enumeration paramNames = httpRequest.getParameterNames();
        
        while (paramNames.hasMoreElements()){
            paramName = (String)paramNames.nextElement();               
            //if the param is named one of the children, create it
            if(paramName.equalsIgnoreCase(object)){
                paramValues = httpRequest.getParameterValues(paramName);   
                for(int i = 0; i < paramValues.length; i++){
                    if(paramValues[i] != null && paramValues[i].length() > 0){
                        request.setAction("Create");
                        request.setObject("Project"+object);
                        request.setAssignment("Name", paramValues[i]);//this is the username selected from the combo box
                        request.setAssignment("Project", httpRequest.getParameter("Name"));//this is the name of the new project typed in
                        //test if user selected to have this thing be 'inactive':
                        
                        if(httpRequest.getParameter(paramValues[i]+object+"Active") != null)
                            request.setAssignment("Active", "False");
                        if(httpRequest.getParameter(paramValues[i]+object+"Admin") != null)
                            request.setAssignment("Admin", "True");
                        data = performRequest(userBean).getDataElement();
                        mymessages += mymessage + "\n";
                        //error condition
                        if(data == null) 
                            return;//do something here for error condition
                        else
                            util.addElementAndValue(projectChild, object + "Name", data.getChild("Project"+object).getChildText("Name"));
                    }
                }
                
            }
        }
        
    }      
     
     private void createAccountChildren( String object, String[] accountChildren, String[] accountChildrenActive, 
                                            String[] accountChildrenAllowDesc, String accountName, UserBean userBean, 
                                            Element parentData){   
        
        Element projectChild = util.addElement(parentData, object + "s");
        Element data;
        String paramName, paramValue;
        String[] paramValues;
        
        for(int i = 0; i < accountChildren.length; i++){
            request.setAction("Create");
            request.setObject("Account"+object);
            request.setAssignment("Name", accountChildren[i]);//this is the username selected from the combo box
            request.setAssignment("Account", accountName);//this is the name of the new project typed in
            request.setAssignment("Access", accountChildrenActive[i]);
            if(accountChildrenAllowDesc != null && accountChildrenAllowDesc.length == accountChildren.length)
                request.setAssignment("AllowDescendants", accountChildrenAllowDesc[i]);
            data = performRequest(userBean).getDataElement();
            mymessages += mymessage + "\n";
            //error condition
            if(data != null && data.getChild("Account"+object) != null) 
                util.addElementAndValue(projectChild, object + "Name", data.getChild("Account"+object).getChildText("Name"));
            
        }
    }      
     
     /*
     private void createDepositShareChildren( String object, String[] depositShareChildren, String[] depositShareChildrenActive, 
                                              String depositShareName, UserBean userBean, Element parentData){   
        
        Element projectChild = util.addElement(parentData, object + "s");
        Element data;
        String paramName, paramValue;
        String[] paramValues;
        
        for(int i = 0; i < depositShareChildren.length; i++){
            request.setAction("Create");
            request.setObject("DepositShare"+object);
            request.setAssignment("Name",depositShareChildren[i]);//this is the username selected from the combo box
            request.setAssignment("Parent", depositShareName);//this is the name of the new project typed in
            if(depositShareChildrenActive !=  null) request.setAssignment("Access", depositShareChildrenActive[i]);
            data = performRequest(userBean).getDataElement();
            mymessages += mymessage + "\n";
            //error condition
            if(data != null && data.getChild("DepositShare"+object) != null) 
                util.addElementAndValue(projectChild, object + "Name", data.getChild("DepositShare"+object).getChildText("Name"));
            
        }
    }   
     
      */
     
     /*
      * this method is called when a user is creating a new reservation thru the manage interface
      * where all information about the reservation as well as its user, project, and machine
      * are all created in this one method call.
      */
    private Element doCreateReservation(HttpServletRequest httpRequest, UserBean userBean){
        Enumeration paramNames = httpRequest.getParameterNames();
        String paramName, paramValue;
        request.setAction("Create");
        request.setObject("Reservation");
        
        //these are all required except description, and javascript should have made sure
        //the user filled them in, if not the create will catch it and inform the user
        //assignments:
        if(httpRequest.getParameter("JobId") != null && httpRequest.getParameter("JobId").length() > 0) 
            request.setAssignment("JobId", httpRequest.getParameter("JobId"));
        if(httpRequest.getParameter("EndTime") != null && httpRequest.getParameter("EndTime").length() > 0) 
            request.setAssignment("EndTime", httpRequest.getParameter("EndTime"));
        if(httpRequest.getParameter("Description") != null && httpRequest.getParameter("Description").length() > 0) 
            request.setAssignment("Description", httpRequest.getParameter("Description"));
        
        //options:
        if(httpRequest.getParameter("Amount") != null && httpRequest.getParameter("Amount").length() > 0) 
            request.setOption("Amount", httpRequest.getParameter("Amount"));
        if(httpRequest.getParameter("User") != null && httpRequest.getParameter("User").length() > 0) 
            request.setOption("User", httpRequest.getParameter("User"));
        if(httpRequest.getParameter("Project") != null && httpRequest.getParameter("Project").length() > 0) 
            request.setOption("Project", httpRequest.getParameter("Project"));
        if(httpRequest.getParameter("Machine") != null && httpRequest.getParameter("Machine").length() > 0) 
            request.setOption("Machine", httpRequest.getParameter("Machine"));
        
        return performRequest(userBean).getDataElement();
    }
    
    
    
    /*
      * this method is called when a user is creating a new reservation thru the manage interface
      * where all information about the reservation as well as its user, project, and machine
      * are all created in this one method call.
      */
    private Element doCreateQuotation(HttpServletRequest httpRequest, UserBean userBean){
        Enumeration paramNames = httpRequest.getParameterNames();
        String paramName, paramValue;
        request.setAction("Create");
        request.setObject("Quotation");
        
        //these are all required except description, and javascript should have made sure
        //the user filled them in, if not the create will catch it and inform the user
        //assignments:
        
        if(httpRequest.getParameter("EndTime") != null && httpRequest.getParameter("EndTime").length() > 0) 
            request.setAssignment("EndTime", httpRequest.getParameter("EndTime"));
        if(httpRequest.getParameter("Project") != null && httpRequest.getParameter("Project").length() > 0) 
            request.setAssignment("Project", httpRequest.getParameter("Project"));
        if(httpRequest.getParameter("User") != null && httpRequest.getParameter("User").length() > 0) 
            request.setAssignment("User", httpRequest.getParameter("User"));
        if(httpRequest.getParameter("Machine") != null && httpRequest.getParameter("Machine").length() > 0) 
            request.setAssignment("Machine", httpRequest.getParameter("Machine"));
        if(httpRequest.getParameter("WallDuration") != null && httpRequest.getParameter("WallDuration").length() > 0) 
            request.setAssignment("WallDuration", httpRequest.getParameter("WallDuration"));
        if(httpRequest.getParameter("Amount") != null && httpRequest.getParameter("Amount").length() > 0) 
            request.setAssignment("Amount", httpRequest.getParameter("Amount"));
        if(httpRequest.getParameter("Used") != null && httpRequest.getParameter("Used").length() > 0) 
            request.setAssignment("Used", httpRequest.getParameter("Used"));
        if(httpRequest.getParameter("Description") != null && httpRequest.getParameter("Description").length() > 0) 
            request.setAssignment("Description", httpRequest.getParameter("Description"));
                
        return performRequest(userBean).getDataElement();
    }
    
     /*
      * this method is called when a user is creating a new project thru the manage interface
      * where all information about the project as well as its users, project, and machines
      * are all created in this one method call.
      */
     private Element doCreateProject(HttpServletRequest httpRequest, UserBean userBean){
        System.out.println("In doCreateProject");
        
        Enumeration paramNames = httpRequest.getParameterNames();
        String paramName, paramValue;
        String[] paramValues;
        
        //1rst create a Project: loop thru params to sort of ones only for Project object and create it.
        request.setAction("Create");
        request.setObject("Project");
        while (paramNames.hasMoreElements()){
            paramName = (String)paramNames.nextElement();
            //if the param is not one of these, it is an attribute of Project, so add it to the request:
            //switching if to be other way around: only these params are attributes of project:
            //if(!"Machine".equalsIgnoreCase(paramName) && !"User".equalsIgnoreCase(paramName) && 
               //!"Project".equalsIgnoreCase(paramName) && (httpRequest.getParameter(paramName) != null) && 
            if(("Active".equalsIgnoreCase(paramName) || "Name".equalsIgnoreCase(paramName) || "Description".equalsIgnoreCase(paramName)) &&
                (httpRequest.getParameter(paramName).length() > 0)){
                paramValue = httpRequest.getParameter(paramName);   
                request.setAssignment(paramName, paramValue);
                System.out.println("   Param: " + paramName +"="+paramValue);
            }
        }
        
        //this will clear out the request object after it executes the request.
        Element data =  performRequest(userBean).getDataElement();
        
        //save message from creating just the project because it will get reset 
        //when creating all the projectUsers, projectMachines, projectProjects.
        mymessages = mymessage + "\n";
        
        //error condition
        if(data == null) 
            return data;
        Element project = data.getChild("Project");
        
        createProjectChildren("User", httpRequest, userBean, project);
        //createProjectChildren("Project", httpRequest, userBean, project);
        createProjectChildren("Machine", httpRequest, userBean, project);
        
        
        mymessage = "Create Project Results:";
        this.addObjectActionMessage(data);

        
        
        String xml = util.convertResponseToXML(data);
        System.out.println("Created Project xml: "+xml);
        return data;
     }

    
     
     private Element doCreateRoles(HttpServletRequest httpRequest, UserBean userBean){
        System.out.println("In doCreateRoles");
         //1rst create the role itself:
        printParams(httpRequest);
        
        String newRoleName = httpRequest.getParameter("Name");
        //1rst create a Project: loop thru params to sort of ones only for Project object and create it.
        request = new Request("Role", "Create");
        request.setAssignment("Name", newRoleName);
        if(httpRequest.getParameter("Description") != null && httpRequest.getParameter("Description").length() > 0) 
            request.setAssignment("Description", httpRequest.getParameter("Description"));
        
        Element data2 =  performRequest(userBean).getDataElement();
        mymessages = mymessage + "\n";
        
        if(data2 == null) return null;
        Element data;
        //2nd create all the roleusers associated with this role
        String[] roleUsers = httpRequest.getParameterValues("User");
        if(roleUsers != null){
            for(int i = 0; i < roleUsers.length; i++){
                request = new Request("RoleUser", "Create");
                request.setAssignment("Role", newRoleName);
                request.setAssignment("Name", roleUsers[i]);
                data =  performRequest(userBean).getDataElement();
                mymessages += mymessage + "\n";
                if(data == null) return null;
            }
        }
        
        //3rd create the permissions
        //if nothing there, just return what we've done so far
        System.out.println("permissions params: " + httpRequest.getParameter("objects") + ", " +
                            httpRequest.getParameter("actions") +", " +
                            httpRequest.getParameter("instances") );
        if((httpRequest.getParameter("objects") == null || httpRequest.getParameter("objects").length() == 0) ||
           (httpRequest.getParameter("actions") == null || httpRequest.getParameter("actions").length() == 0) ||
           (httpRequest.getParameter("instances") == null || httpRequest.getParameter("instances").length() == 0) ) 
            return data2;
        
        String[] objects = httpRequest.getParameter("objects").split(",");
        String[] actions = httpRequest.getParameter("actions").split(",");
        String[] instances = httpRequest.getParameter("instances").split(",");
        for(int i = 0; i < objects.length; i++){
            request = new Request("RoleAction", "Create");
            request.setAssignment("Role", newRoleName);
            request.setAssignment("Object", objects[i]);
            request.setAssignment("Name", actions[i]);
            request.setAssignment("Instance", instances[i]);
            data =  performRequest(userBean).getDataElement();
            mymessages += mymessage + "\n";
            if(data == null) return null;
        }
        
        
        //set the messages
        mymessage = "Create Role Results:";
        
        return data2;

     }
     
     
     /*
      * this method is called when a user is creating a new project thru the manage interface
      * where all information about the project as well as its users, project, and machines
      * are all created in this one method call.
      */
     private Element doCreateAccount(HttpServletRequest httpRequest, UserBean userBean, AccountBean accountBean){
        System.out.println("In doCreateAccount");
        this.printParams(httpRequest);
        
        
        
        //1rst create a Project: loop thru params to sort of ones only for Project object and create it.
        request = new Request("Account", "Create");
        if(httpRequest.getParameter("Name") != null && httpRequest.getParameter("Name").length() > 0)
            request.setAssignment("Name", httpRequest.getParameter("Name"));
        if(httpRequest.getParameter("CreditLimit") != null && httpRequest.getParameter("CreditLimit").length() > 0)
            request.setAssignment("CreditLimit", httpRequest.getParameter("CreditLimit"));
        if(httpRequest.getParameter("Description") != null && httpRequest.getParameter("Description").length() > 0)
            request.setAssignment("Description", httpRequest.getParameter("Description"));
        
                
        //this will clear out the request object after it executes the request.
        Element data =  performRequest(userBean).getDataElement();
        
        //save message from creating just the project because it will get reset 
        //when creating all the projectUsers, projectMachines, projectProjects.
        mymessages = mymessage + "\n";
        
        //error condition
        if(data == null) 
            return data;
        Element account = data.getChild("Account");
        String accountId = account.getChildText("Id");
        
        String xml = util.convertResponseToXML(account);
        System.out.println("Created Account xml: "+xml);
        //if(accountBean.getAccountProjectAsArray() != null) 
        this.createAccountChildren("Machine", accountBean.getAccountMachineAsArray(), accountBean.getAccountMachineActiveAsArray(), null, accountId, userBean, account);    
        this.createAccountChildren("Project", accountBean.getAccountProjectAsArray(), accountBean.getAccountProjectActiveAsArray(), null, accountId, userBean, account);
        this.createAccountChildren("User",    accountBean.getAccountUserAsArray(),    accountBean.getAccountUserActiveAsArray(), null, accountId, userBean, account);
        this.createSubAccounts(accountId, userBean, account, httpRequest);
        
        //if(accountBean.getAccountMachineAsArray() != null) 
            
        //if(accountBean.getAccountUserAsArray() != null) 
            
        mymessage = "Create Account Results:";
        this.addObjectActionMessage(data);

        
        
        xml = util.convertResponseToXML(data);
        System.out.println("Created Account xml: "+xml);
         
        return data;
     }
     
     
     private void createSubAccounts(String accountId, UserBean userBean, Element account, HttpServletRequest httpRequest){
        Enumeration paramNames = httpRequest.getParameterNames();
        String paramName, paramValue, subaccount;
        Element data;
        //look for param names that begin with "depositShare" to get all subaccounts
        while (paramNames.hasMoreElements()){
            paramName = (String)paramNames.nextElement();
            if(paramName != null && paramName.startsWith("subaccountId")){
                subaccount = paramName.substring("subaccountId".length());
                request = new Request("AccountAccount", "Create");
                request.setAssignment("Id", subaccount);
                request.setAssignment("Account", accountId);
                request.setAssignment("DepositShare", httpRequest.getParameter(paramName));
                if(httpRequest.getParameter("overflow" + subaccount) != null)
                    request.setAssignment("OverFlow", "True");
                else request.setAssignment("OverFlow", "False");
                data = performRequest(userBean).getDataElement();
                mymessages += mymessage + "\n";
                if(data == null) return;
            }
        }
        
     }
     
      /*
      * this method is called when a user is creating a new project thru the manage interface
      * where all information about the project as well as its users, project, and machines
      * are all created in this one method call.
      
     private Element doCreateDepositShare(HttpServletRequest httpRequest, UserBean userBean){
        System.out.println("In doDepositShare");
        
        Enumeration paramNames = httpRequest.getParameterNames();
        String paramName, paramValue;
        String[] paramValues;
        
        //1rst create a Project: loop thru params to sort of ones only for Project object and create it.
        request.setAction("Create");
        request.setObject("DepositShare");
        
        request.setAssignment("Project", httpRequest.getParameter("Project"));
        request.setAssignment("Amount", httpRequest.getParameter("Amount"));
        request.setAssignment("Description", httpRequest.getParameter("Description"));
        
        
        
        //this will clear out the request object after it executes the request.
        Element data =  performRequest(userBean).getDataElement();
        
        //save message from creating just the project because it will get reset 
        //when creating all the projectUsers, projectMachines, projectProjects.
        mymessages = mymessage + "\n";
        
        //error condition
        if(data == null) 
            return data;
        Element depositShare = data.getChild("DepositShare");
        String depositShareId = depositShare.getChildText("Id");
        
        String xml = util.convertResponseToXML(depositShare);
        System.out.println("Created depositShare xml: "+xml);
        //accountBean.getAccountUserAsArray(), accountBean.getAccountUserActiveAsArray()
        if(httpRequest.getParameter("DepositShareProjectUser") != null && httpRequest.getParameter("DepositShareProjectUser").length() > 0){
            String[] users = httpRequest.getParameter("DepositShareProjectUser").split(",");
            String[] usersAccess = httpRequest.getParameter("DepositShareProjectUserActive").split(",");
            this.createDepositShareChildren("User", users, usersAccess, depositShareId, userBean, depositShare);
        }
        if(httpRequest.getParameter("ProjectProject") != null && httpRequest.getParameter("ProjectProject").length() > 0){
            String[] users = httpRequest.getParameter("ProjectProject").split(",");
            this.createDepositShareChildren("Project", users, null, depositShareId, userBean, depositShare);
        }
        if(httpRequest.getParameter("DepositShareProjectMachine") != null && httpRequest.getParameter("DepositShareProjectMachine").length() > 0){
            String[] machines = httpRequest.getParameter("DepositShareProjectMachine").split(",");
            String[] machinesAccess = httpRequest.getParameter("DepositShareProjectMachineActive").split(",");
            this.createDepositShareChildren("Machine", machines, machinesAccess, depositShareId, userBean, depositShare);
        }
        
        mymessage = "Create Deposit Share Results:";
        this.addObjectActionMessage(data);
        
        
        xml = util.convertResponseToXML(data);
        System.out.println("Created Deposit Share xml: "+xml);
        return data;
     }
     
     
     public String populateListsForDepositShare(UserBean userBean, HttpServletRequest httpRequest){
         System.out.println("populateListsForDepositShare 1");
         return populateListsForDepositShare(userBean, httpRequest.getParameter("Project"), httpRequest.getParameter("Amount"), httpRequest.getParameter("Description"), "");
     }
     
     public String populateListsForDepositShare(UserBean userBean, ConditionBean conditionBean){
         System.out.println("populateListsForDepositShare 2");
         String project, amount, description = "";
         String[] id = conditionBean.getConditionValuesAsArray();
         request= new Request("DepositShare", "Query");
         
         request.setCondition("Id", id[0]);
         Element depositShare = performRequest(userBean).getDataElement();
         
         util.convertResponseToXML(depositShare);
         return populateListsForDepositShare(userBean, depositShare.getChild("DepositShare").getChildText("Project"), depositShare.getChild("DepositShare").getChildText("Amount"), depositShare.getChild("DepositShare").getChildText("Description"), depositShare.getChild("DepositShare").getChildText("Id"));
     }
     
     private String populateListsForDepositShare(UserBean userBean, String project, String amount, String description, String id){
        System.out.println("populateListsForDepositShare");
        
        request.setObject("ProjectProject");
        request.setAction("Query");
        request.setSelection("Name");
        request.setCondition("Parent", project);
        Element projects = performRequest(userBean).getDataElement();
        
        request.setObject("ProjectUser");
        request.setAction("Query");
        request.setSelection("Name");
        request.setCondition("Parent", project);
        Element users = performRequest(userBean).getDataElement();

        
        
        request.setObject("ProjectMachine");
        request.setAction("Query");
        request.setSelection("Name");
        request.setCondition("Parent", project);
        Element machines = performRequest(userBean).getDataElement();
        
        
        return "<ProjectChildren>" + util.convertResponseToXML(projects) + 
            util.convertResponseToXML(users)+
            util.convertResponseToXML(machines) + 
            "<SelectedProject>" + project+ "</SelectedProject>" +
            "<Amount>" + amount+ "</Amount>" +
            "<Description>" + description+ "</Description>" +
            "<Id>" + id+ "</Id>" +
            "</ProjectChildren>" ;
     }
    
     */
     
     
     
    private boolean setModifiedFields(HashMap map, HttpServletRequest httpRequest){
        Set projectKeys = map.keySet();
        Iterator itr = projectKeys.iterator();
        String attributeName, attributeValue = null;
        boolean changedFlag = false;
        while(itr.hasNext()) {//for each of the keys about just the project info
            attributeName = ((String)itr.next());
            attributeValue = httpRequest.getParameter(attributeName);
            if(attributeValue != null){
                if(attributeValue.compareTo((String)map.get(attributeName)) != 0){
                    changedFlag = true;
                    request.setAssignment(attributeName, attributeValue);
                }
            }
        }
        return changedFlag;
    }
    
    
    
    
     
     
     private Element doModifyComplexObject(HttpServletRequest httpRequest, UserBean userBean, ConditionBean conditionBean){
        System.out.println("In doModifyComplexObject:\n\n");
        String pkey = this.getPrimaryKey(userBean, myobject);
        
        String paramName;
        String[] paramValues;
        HashMap map = userBean.getOriginalObject();
        boolean changedFlag = setModifiedFields(map, httpRequest);
        
        
        
        Element data = null;
        String parentName = (String)map.get(pkey);//primary key: Name for Project, Id for Account//"Name"
        String message = "";
        if(changedFlag){
            request.setAction("Modify");
            request.setObject(myobject);//myobject
            request.setCondition(pkey, parentName);//pkey
            data = performRequest(userBean).getDataElement();
            message += mymessage+"\n";
        }else{
            request.setAction("Query");
            request.setObject(myobject);//myobject
            request.setCondition(pkey, parentName);//pkey
            data = performRequest(userBean).getDataElement();
        }
        
        
        
        TreeSet tree = new TreeSet(new Comparator() { 
            public int compare(java.lang.Object a, java.lang.Object b) {
                String infoA = (String)a;
                String infoB = (String)b;
                //want it in reverse order
                return infoB.compareTo(infoA);
            }
        });
        
        if(!"Role".equalsIgnoreCase(myobject)){
            map = userBean.getOriginalObjectLinks();
            tree.addAll(map.keySet());
            Iterator itr = tree.iterator();
            String attributeName, attributeValue, actives, accesses, allowDescs, admins = null;
            while(itr.hasNext()) {//for each of the keys about the project's links
                attributeName = ((String)itr.next());
                attributeValue = httpRequest.getParameter(attributeName);
                System.out.println("attributeName: "+ attributeName + ", attributeValue: "+ attributeValue);
                actives = httpRequest.getParameter(attributeName+"Active");
                accesses = httpRequest.getParameter(attributeName+"Access");
                allowDescs = httpRequest.getParameter(attributeName+"AllowDesc");
                admins = httpRequest.getParameter(attributeName+"Admin");
                message += modifyObjectChildren(parentName, attributeName, (HashMap)map.get(attributeName), 
                                      attributeValue, actives, accesses, allowDescs, admins, userBean, data);
            }
        //have to do RoleUser & RoleObjectAction differently since it has 3 primary keys 
        }else{
             message += doModifyRoles(parentName, userBean, data, httpRequest);
        }
        //clear out any info still left in the request bean:
        request = new Request();
        
        //set the messages
        mymessage = "Modify " + myobject + "Results:";//myobject
        mymessages = message;
        return data;
     }
     
     
     
     
     private String doModifyRoles(String parentName, UserBean userBean, Element data, HttpServletRequest httpRequest){     
        HashMap maps = userBean.getOriginalObjectLinks();
        HashMap map = (HashMap)maps.get("RoleUser");
        String[] users = httpRequest.getParameterValues("User");
        String key;
        String messages = "";
        //first do the users
        for(int i = 0; i < users.length; i++) {
            //if they are in the hashmap, then they're not new:
            if(map.containsKey(users[i]))
                map.remove(users[i]);
            else{
                request = new Request("RoleUser", "Create");
                request.setAssignment("Role", parentName);
                request.setAssignment("Name", users[i]);
                data =  performRequest(userBean).getDataElement();
                messages += mymessage + "\n";
                if(data == null) return null;
            }
        }
        if(map.size() > 0){
            //for any thats left in the hashmap, they were removed so delete them
            Iterator itr = map.keySet().iterator();                
            while(itr.hasNext()) {//for each of the keys left delete the projectLink
                key = (String)itr.next();
                request = new Request("RoleUser", "Delete");
                request.setCondition("Role", parentName);
                request.setCondition("Name", key);
                data =  performRequest(userBean).getDataElement();
                messages += mymessage + "\n";
                if(data == null) return null;
            }
        }

        //next do the roleActions
        Vector originalLinks = userBean.getRoleObjecActionVector();
        String[] objects = httpRequest.getParameter("objects").split(",");
        String[] actions = httpRequest.getParameter("actions").split(",");
        String[] instances = httpRequest.getParameter("instances").split(",");
        
        for(int i = 0; i < objects.length; i++){
            key = objects[i] + "," + actions[i] + "," +  instances[i];
            //if the original list contains the same key, nothing changed so just
            //remove it from originalLinks
            if(originalLinks.contains(key)){
                originalLinks.remove(key);
            }else{
                request = new Request("RoleAction", "Create");
                request.setAssignment("Role", parentName);
                request.setAssignment("Object", objects[i]);
                request.setAssignment("Name", actions[i]);
                request.setAssignment("Instance", instances[i]);
                data =  performRequest(userBean).getDataElement();
                messages += mymessage + "\n";
                if(data == null) return null;
            }   
        }
        String[] keys;
        //now remove any that are still left in the vector
        for(int i = 0; i < originalLinks.size(); i++){
            key = (String)originalLinks.get(i);
            keys = key.split(",");
            request = new Request("RoleAction", "Delete");
            request.setCondition("Role", parentName);
            request.setCondition("Object", keys[0]);
            request.setCondition("Name", keys[1]);
            request.setCondition("Instance", keys[2]);
            data =  performRequest(userBean).getDataElement();
            messages += mymessage + "\n";
            if(data == null) return null;
        }
        return messages;
     }
     
     
     
     //called to modify a project's ProjectUsers, ProjectMachines, ProjectProjects
     private String modifyObjectChildren(String parentName, String objectName, HashMap projectLinks,  
                                          String projectLinksNames, String activeValues, String accessValues, String allowDescValues,
                                          String adminValues, UserBean userBean, Element parentData){
        
        System.out.println("modifyObjectChildren: " + 
                            parentName + ", " + objectName + ", " + projectLinks + ", " + projectLinksNames + ", " + 
                            activeValues+ ", " + accessValues+ ", " + allowDescValues+ ", " + adminValues);
        //if there wasn't anything there before, and there still isn't anything, 
        //nothing to add, remove or modify, so just return;
        if(projectLinks.size() == 0 && projectLinksNames.length() == 0){
            System.out.println("if there wasn't anything there before, and there still isn't anything, nothing to add, remove or modify");
            return "";
        }
        //if(){
         //   System.out.println("if there wasn't anything there before, but now is, just create the new ones");
        //}
        
        String message = "";
        String[] names = projectLinksNames.split(",");
        String[] actives = null;
        String[] accesses = null;
        String[] allowDescs = null;
        String[] admins = null;
        if(activeValues != null) actives = activeValues.split(",");
        if(accessValues != null) accesses = accessValues.split(",");
        if(allowDescValues != null) allowDescs = allowDescValues.split(",");
        if(adminValues != null) admins = adminValues.split(",");
        String attributeName, oldAttributeValue = null;
        boolean doRequest = false;
        Element data = null;
        
        //Strip off the "Project" for the new element we're making = objectName.substring(7 <length of 'project'>) in order to get "Users"
        Element projectChild = util.addElement(parentData.getChild(myobject), objectName.substring(myobject.length()) + "s");
        request = new Request();
        for(int i = 0; i < names.length; i++){
            request.setObject(objectName);//will set what kind of object we're modifing, or adding
            //if(actives != null) request.setAssignment("Active", actives[i]);
            //if(accesses != null) request.setAssignment("Access", accesses[i]);
            //if(allowDescs != null) request.setAssignment("AllowDescendants", allowDescs[i]);
            doRequest = false;
            //might have blank values when none are selected:
            if( names[i].length() > 0 ){
                if(projectLinks.containsKey(names[i])){
                    oldAttributeValue = (String)projectLinks.get(names[i]);
                    String[] act_acc_alw = oldAttributeValue.split(",");
                    //if(oldAttributeValue.compareTo(actives[i]) != 0){
                    if((actives != null) && (act_acc_alw[0].compareTo(actives[i]) != 0)){
                        request.setAssignment("Active", actives[i]);
                        doRequest = true;
                    }
                    if((accesses != null) && (act_acc_alw[0].compareTo(accesses[i]) != 0)){
                        request.setAssignment("Access", accesses[i]);
                        doRequest = true;
                    }
                    if(act_acc_alw.length == 2){//setting Access and AllowDescendants
                        if((allowDescs != null) && (act_acc_alw[1].compareTo(allowDescs[i]) != 0)){
                            request.setAssignment("AllowDescendants", allowDescs[i]);
                            doRequest = true;
                        }
                        else if((admins != null) && (act_acc_alw[1].compareTo(admins[i]) != 0)){
                            request.setAssignment("Admin", admins[i]);
                            doRequest = true;
                        }
                    }
                    if(doRequest){
                        request.setAction("Modify");
                        request.setCondition("Name", names[i]);
                        request.setCondition(myobject, parentName);
                    }
                }else{
                    doRequest = true;
                    if(actives != null) request.setAssignment("Active", actives[i]);
                    if(accesses != null) request.setAssignment("Access", accesses[i]);
                    if(allowDescs != null) request.setAssignment("AllowDescendants", allowDescs[i]);
                    if(admins != null) request.setAssignment("Admin", admins[i]);
                    request.setAction("Create");
                    request.setAssignment("Name", names[i]);
                    request.setAssignment(myobject, parentName);
                }
                if(doRequest){
                    data = performRequest(userBean).getDataElement();
                    message += mymessage +"\n";
                    if(data != null && data.getChild(objectName) != null)//error condition
                        util.addElementAndValue(projectChild, objectName.substring(myobject.length()), data.getChild(objectName).getChildText("Name"));//7=length of 'project'
                }else if(projectLinks.containsKey(names[i])){
                    System.out.println("projectLinks.containsKey: "+ names[i]);
                    //if we didn't do a modify or create and this name is in the hash, we're not changing anything,
                    //but add this name back in so that we'll see them in the results frame:
                    util.addElementAndValue(projectChild, objectName, names[i]);
                }//otherwise we're deleteing this guy, so don't put him in there
                //remove from hashmap if there so that any left over can be deleted
                projectLinks.remove(names[i]);
            }
            
            System.out.println("projectChild: " + objectName.substring(myobject.length()));
            util.convertResponseToXML(projectChild);
            request = new Request();//to clear out the setObject, and setAssignment in case no request is performed
        }
        
        Set projectKeys = projectLinks.keySet();
        Iterator itr = projectKeys.iterator();
                
        while(itr.hasNext()) {//for each of the keys left delete the projectLink
            attributeName = (String)itr.next();
            oldAttributeValue = (String)projectLinks.get(attributeName);
            if(attributeName != null && attributeName.length() > 0 &&
                oldAttributeValue != null && oldAttributeValue.length() > 0){
                request.setObject(objectName);//will set what kind of object we're modifing, or adding
                request.setAction("Delete");
                request.setCondition("Name", attributeName);
                request.setCondition(myobject, parentName);
                performRequest(userBean).getDataElement();
                message += mymessage+"\n";
            }
        }
        return message;
        
        
     }
        
        
        
     
     
     public String loadProjectInputs(UserBean userBean, HttpServletRequest request, String conditionValues, AccountBean accountBean){
        userBean.setUserAction("modify_project");
        userBean.setShowHidden(null);

        Element data = new Element("Data");        
        
        Element projectData = getInputData(userBean);
        addObjectActionMessage(projectData);
        data.getChildren().add(projectData);
        
        ConditionBean conditionBean = new ConditionBean();

        //we only need the names of the machines/projects/users since thats all we're displaying
        conditionBean.setFieldNames("Description,Name,Special");
        conditionBean.setConditionNames("Special");
        conditionBean.setConditionValues("False");

        setMyaction("Query");
        setMyobject("User");
        
        data.getChildren().add(doActionGetElement(request, conditionBean, userBean, accountBean));

        //setMyobject("Project");
        //data.getChildren().add(doActionGetElement(request, conditionBean, userBean, accountBean));

        setMyobject("Machine");
        data.getChildren().add(doActionGetElement(request, conditionBean, userBean, accountBean));

        
        return util.convertResponseToXML(data);
     }
     
     
    public String loadAccountInputs(UserBean userBean, HttpServletRequest request, String conditionValues, AccountBean accountBean){
        userBean.setUserAction("modify_Account");
        userBean.setShowHidden(null);

        Element data = new Element("Data");        
        
        Element projectData = getInputData(userBean);
        addObjectActionMessage(projectData);
        data.getChildren().add(projectData);
        
        ConditionBean conditionBean = new ConditionBean();

        //we only need the names of the machines/projects/users since thats all we're displaying
        conditionBean.setFieldNames("Description,Name,Special");
        //conditionBean.setConditionNames("Special");
        //conditionBean.setConditionValues("False");

        setMyaction("Query");
        setMyobject("User");
        
        data.getChildren().add(doActionGetElement(request, conditionBean, userBean, accountBean));

        setMyobject("Project");
        data.getChildren().add(doActionGetElement(request, conditionBean, userBean, accountBean));

        setMyobject("Machine");
        data.getChildren().add(doActionGetElement(request, conditionBean, userBean, accountBean));

        
        return util.convertResponseToXML(data);
     }
    
        
     
     
     
    public String loadThisProjectInfo(ConditionBean conditionBean, UserBean userBean, HttpServletRequest servletRequest, AccountBean accountBean){
        System.out.println("loadThisProjectInfo");
        
        conditionBean.setFieldNames("");
        conditionBean.setConditionNames("Name");

        setMyobject("Project");
        Element data = new Element("Data");
        
        Element projectData = doActionGetElement(servletRequest, conditionBean, userBean, accountBean);
        userBean.setOriginalObject(projectData);
        
        conditionBean.setConditionNames("Project");
        //conditionValue was already set to the name of the project we're loading from the form submit to the mod_proj page
        setMyobject("ProjectUser");
        Element projectUser = this.doActionGetElement(servletRequest, conditionBean, userBean, accountBean);
        if(projectUser.getChildren().size() == 0) 
            projectUser =  (Element)new Element("Data").addContent(new Element("ProjectUser"));
        data.getChildren().add(projectUser);
        
        
        setMyobject("ProjectMachine");
        Element projectMachine = this.doActionGetElement(servletRequest, conditionBean, userBean, accountBean);
        if(projectMachine.getChildren().size() == 0) 
            projectMachine =  (Element)new Element("Data").addContent(new Element("ProjectMachine"));
        data.getChildren().add(projectMachine);
        
        //make hashmap for object links & pkeys"
        
        HashMap pkeys = new HashMap();
        pkeys.put("ProjectUser", "Name");
        pkeys.put("ProjectMachine", "Name");
        
        
        userBean.setOriginalObjectLinks(data, pkeys);//"Name" is the primary key

        data.getChildren().add(projectData);
        
        //get ready to modify this project: bean uses this when doAction is called from results.jsp
        setMyobject("Project");
        setMyaction("modifyProject");

        userBean.setUserAction("");        
        addObjectActionMessage(data);
        
        
        return util.convertResponseToXML(data);
    }
    
    
    
    /*
     public String loadThisDepositShareInfo(ConditionBean conditionBean, UserBean userBean, HttpServletRequest servletRequest, AccountBean accountBean){
        System.out.println("loadThisDepositShareInfo");
        
        conditionBean.setFieldNames("");
        conditionBean.setConditionNames("Id");

        
        setMyaction("Query");
        
        Element data = new Element("Data");
        request= new Request("DepositShare", "Query");
        String[] id = conditionBean.getConditionValuesAsArray();
        request.setCondition("Id", id[0]);
         
        Element depositShareData = performRequest(userBean).getDataElement();
        userBean.setOriginalObject(depositShareData);
        
        conditionBean.setConditionNames("Parent");
        //conditionValue was already set to the name of the project we're loading from the form submit to the mod_proj page
        setMyobject("DepositShareUser");
        Element projectUser = this.doActionGetElement(servletRequest, conditionBean, userBean, accountBean);
        if(!projectUser.hasChildren())projectUser = new Element("Data").addContent(new Element("DepositShareUser"));
        data.getChildren().add(projectUser);
        
        setMyobject("DepositShareProject");
        Element projectProject = this.doActionGetElement(servletRequest, conditionBean, userBean, accountBean);
        if(!projectProject.hasChildren()) projectProject = new Element("Data").addContent(new Element("DepositShareProject"));
        data.getChildren().add(projectProject);

        setMyobject("DepositShareMachine");
        Element projectMachine = this.doActionGetElement(servletRequest, conditionBean, userBean, accountBean);
        if(!projectMachine.hasChildren()) projectMachine = new Element("Data").addContent(new Element("DepositShareMachine"));
        data.getChildren().add(projectMachine);
        
        userBean.setOriginalObjectLinks(data, "DepositShare");

        data.getChildren().add(depositShareData);
        
        //get ready to modify this project: bean uses this when doAction is called from results.jsp
        setMyobject("DepositShare");
        setMyaction("modifyDepositShare");

        userBean.setUserAction("");        
        addObjectActionMessage(data);
        
        
        return util.convertResponseToXML(data);
    }
      */
     
     
     
     
    public String loadThisAccountInfo(ConditionBean conditionBean, UserBean userBean, HttpServletRequest servletRequest, AccountBean accountBean){
        System.out.println("loadThisAccountInfo");
        
        conditionBean.setFieldNames("");
        conditionBean.setConditionNames("Id");//pkey

        setMyobject("Account");
        Element data = new Element("Data");
        
        Element projectData = doActionGetElement(servletRequest, conditionBean, userBean, accountBean);
        userBean.setOriginalObject(projectData);
        
        conditionBean.setConditionNames("Account");
        //conditionValue was already set to the name of the project we're loading from the form submit to the mod_proj page
        setMyobject("AccountUser");
        Element projectUser = this.doActionGetElement(servletRequest, conditionBean, userBean, accountBean);
        if(projectUser.getChildren().size() == 0)
            projectUser = (Element)new Element("Data").addContent(new Element("AccountUser"));
        data.getChildren().add(projectUser);
        
        setMyobject("AccountProject");
        Element projectProject = this.doActionGetElement(servletRequest, conditionBean, userBean, accountBean);
        if(projectProject.getChildren().size() == 0) 
            projectProject = (Element)new Element("Data").addContent(new Element("AccountProject"));
        data.getChildren().add(projectProject);

        setMyobject("AccountMachine");
        Element projectMachine = (Element)(this.doActionGetElement(servletRequest, conditionBean, userBean, accountBean));
        if(projectMachine.getChildren().size() == 0) 
            projectMachine =  (Element)new Element("Data").addContent(new Element("AccountMachine"));
        data.getChildren().add(projectMachine);
        
        
        HashMap pkeys = new HashMap();
        pkeys.put("AccountUser", "Name");
        pkeys.put("AccountProject", "Name");
        pkeys.put("AccountMachine", "Name");
        pkeys.put("AccountAccount", "Id");
        
        userBean.setOriginalObjectLinks(data, pkeys); 

        data.getChildren().add(projectData);
        
        //get ready to modify this project: bean uses this when doAction is called from results.jsp
        setMyobject("Account");
        setMyaction("modifyAccount");

        userBean.setUserAction("");        
        addObjectActionMessage(data);
        
        
        return util.convertResponseToXML(data);
    }
     
    
    private void printParams(HttpServletRequest servletRequest){
        Enumeration paramNames = servletRequest.getParameterNames();
        String paramName;
        String[] paramValues;
        while (paramNames.hasMoreElements()){
            paramName = (String)paramNames.nextElement();
            paramValues = servletRequest.getParameterValues(paramName);
            for(int i = 0; i < paramValues.length; i++){
                System.out.println("param: "+paramName+"["+i+"] = "+paramValues[i]);
            }
        }
    }
    
    private void doDeposit(UserBean userBean, HttpServletRequest servletRequest){
        System.out.println("doDeposit");
        Enumeration paramNames = servletRequest.getParameterNames();
        String paramName;
        String[] paramValues;
        while (paramNames.hasMoreElements()){
            paramName = (String)paramNames.nextElement();
            paramValues = servletRequest.getParameterValues(paramName);
            //igore params that were used in the conditionBean:
            //if(!"conditionNames".equalsIgnoreCase(paramName) && !"conditionValues".equalsIgnoreCase(paramName) &&
            //   !"viewType".equalsIgnoreCase(paramName) && !"thisAction".equalsIgnoreCase(paramName)){
                //if(paramValue != null && paramValue.length() > 0) {
                for(int i = 0; i < paramValues.length; i++){
                    //request.setAssignment(paramName, paramValue);
                    System.out.println("param: "+paramName+" = "+paramValues[i]);
                    if(!paramName.endsWith("Radio") && paramValues[i] != null && paramValues[i].length() > 0)
                        request.setOption(paramName, paramValues[i]);
                }
            //}
        }
    }
    
    private void doWithdrawal(UserBean userBean, HttpServletRequest servletRequest){
        System.out.println("doDeposit");
        Enumeration paramNames = servletRequest.getParameterNames();
        String paramName;
        String[] paramValues;
        while (paramNames.hasMoreElements()){
            paramName = (String)paramNames.nextElement();
            paramValues = servletRequest.getParameterValues(paramName);
            //igore params that were used in the conditionBean:
            //if(!"conditionNames".equalsIgnoreCase(paramName) && !"conditionValues".equalsIgnoreCase(paramName) &&
            //   !"viewType".equalsIgnoreCase(paramName) && !"thisAction".equalsIgnoreCase(paramName)){
                //if(paramValue != null && paramValue.length() > 0) {
                for(int i = 0; i < paramValues.length; i++){
                    //request.setAssignment(paramName, paramValue);
                    System.out.println("param: "+paramName+" = "+paramValues[i]);
                    if(!paramName.endsWith("Radio") && paramValues[i] != null && paramValues[i].length() > 0)
                        request.setOption(paramName, paramValues[i]);
                }
            //}
        }
    }
    
    
    
    
    
    private Element doAccountQuery(UserBean userBean, HttpServletRequest servletRequest){
        ConditionBean conditions = new ConditionBean();
        
        String optionNames = "Active,UseRules,";
        String optionValues = "True,True,";
        
        if(servletRequest.getParameter("User") != null && servletRequest.getParameter("User").length() > 0){
            optionNames += "User,";
            optionValues += servletRequest.getParameter("User")+",";
        }if(servletRequest.getParameter("Project") != null && servletRequest.getParameter("Project").length() > 0){
            optionNames += "Project,";
            optionValues += servletRequest.getParameter("Project")+",";
        }if(servletRequest.getParameter("Machine") != null && servletRequest.getParameter("Machine").length() > 0){
            optionNames += "Machine,";
            optionValues += servletRequest.getParameter("Machine")+",";
        }
        
        conditions.setOptionName(optionNames);
        conditions.setOptionValue(optionValues);
        request = new Request("Account", "Query");
        setOptions(conditions);
        Element accounts = performRequest(userBean).getDataElement();
        
        if(accounts.getChild("Account") == null) return accounts;
        
        //now add Allocations as children to these account
        conditions = new ConditionBean();
        addAccountConditions(accounts, conditions, false);
        conditions.setFieldNames("Amount,CreditLimit,Account");
        conditions.setFieldOperators("Sum,Sum,GroupBy");
        setConditions(conditions);
        setFields(conditions);
        
        request.setAction("Query");
        request.setObject("Allocation");
        
        Element data = performRequest(userBean).getDataElement();
        if(data == null || data.getChildren() == null) return data;
        Iterator itr = (data.getChildren()).iterator();
        
        util.setChildrenChildrenAndAttribute(accounts, "Allocations", "Link", "True");
        
        String parentName;
        Element parentElement, child, size;
        while(itr.hasNext()) {
            child = ((Element)itr.next());
            parentName = child.getChildText("Account");
            parentElement = util.getChildsParent(accounts, "Id", parentName);
            if(parentElement != null)
                parentElement.getChild("Allocations").getChildren().add(child.clone());
            
        }
        
        
        System.out.println("Accounts with Allocations");
        util.convertResponseToXML(accounts);
        
        return accounts;
               
    }
    
        
    //on account queries set user, etc. as options, but on reservation queries set them as conditions
    private void doReservationQuery(UserBean userBean, Element accounts){
        //ConditionBean conditions = new ConditionBean();
        
        //addAccountConditions(accounts, conditions, true);
        //conditions.setFieldNames("Amount,Account");
        //conditions.setFieldOperators("Sum,GroupBy");
        //add selections Amount, sum and Account, groupby
        //return this.getObjectListElement(userBean, conditions, null);
        request = new Request();
        request.setAction("Query");
        request.setObject("Reservation");
        request.setObject("ReservationAllocation");
        request.setSelection(new Selection("Amount", "Sum", "ReservationAllocation"));
        request.setSelection(new Selection("Account", "GroupBy", "ReservationAllocation"));
        request.setCondition(new Condition("EndTime", "now", "GE", "And", "0", "Reservation"));
        request.setCondition(new Condition("Reservation", "Id", "EQ", "And", "0", "ReservationAllocation", "Reservation"));
        //this.setConditions(conditions);
        //this.setFields(conditions);
        
        Element account;
        
        Iterator itr = accounts.getChildren().iterator();
        System.out.println("accounts.getChildren().size: " + accounts.getChildren().size() );
        int length = accounts.getChildren().size();
        int counter = 1;
        while(itr.hasNext()) {
            account = (Element)itr.next();
            //System.out.println("accounts.getChildren().size: " + accounts.getChildren().size() );
            
            if(account.getChildText("Id") != null){
                //conditionValues += account.getChildText("Id") +",";
                
                if(counter == 1 && length > 1)
                    request.setCondition(new Condition("Account", account.getChildText("Id"), "EQ", "And", "+1", "ReservationAllocation"));
                else if(counter == length && length > 1)
                    request.setCondition(new Condition("Account", account.getChildText("Id"), "EQ", "Or", "-1", "ReservationAllocation"));
                else
                    request.setCondition(new Condition("Account", account.getChildText("Id"), "EQ", "Or", "0", "ReservationAllocation"));
                counter++;
            }
        }
                
        
        Element data = performRequest(userBean).getDataElement();
        
        
        if(data == null || data.getChildren() == null) return;
        itr = (data.getChildren()).iterator();
        
        util.setChildrenChildrenAndAttribute(accounts, "ReservationAllocations", "Link", "True");
        
        String parentName;
        Element parentElement, child, size;
        while(itr.hasNext()) {
            child = ((Element)itr.next());
            parentName = child.getChildText("Account");
            parentElement = util.getChildsParent(accounts, "Id", parentName);
            if(parentElement != null)
                parentElement.getChild("ReservationAllocations").getChildren().add(child.clone());
            
        }
               
    }
 
    
    private void addAccountConditions(Element accounts, ConditionBean conditions, boolean isReservationQuery){
        String conditionNames = "", conditionOperators = "", conditionValues = "", conjunctions = "", groups = "";
        if(isReservationQuery){
            //conditionNames = "EndTime,";
            //conditionOperators = "GE,";
            //conditionValues = "now,";
            //conjunctions = ",and,";
            //groups = ",1,";
            conditionNames = ",";
            conditionOperators = ",";
            conditionValues = ",";
            conjunctions = ",,";
            groups = ",1,";
        }else{
            conditionNames = "Active,";
            conditionOperators = ",";
            conditionValues = "True,";
            conjunctions = ",and,";
            groups = ",1,";
        }
        //loop thru accounts and set a condition for each one using or: Account = <id> OR
        Element account;
        
        Iterator itr = accounts.getChildren().iterator();
        System.out.println("accounts.getChildren().size: " + accounts.getChildren().size() );
        
        while(itr.hasNext()) {
            account = (Element)itr.next();
            //System.out.println("accounts.getChildren().size: " + accounts.getChildren().size() );
            if(account.getChildText("Id") != null){
                groups += ",";
                conditionNames += "Account,";
                conditionValues += account.getChildText("Id") +",";
                conditionOperators += ",";
                conjunctions += "Or,";
            }
        }
        if(accounts.getChildren().size() == 1)
            groups = "";
        else
            groups = groups.substring(0, groups.length() -2) + "-1";
        
        conditions.setConditionNames(conditionNames);
        conditions.setConditionValues(conditionValues);
        conditions.setConditionOperators(conditionOperators);
        conditions.setConjunctions(conjunctions);
        conditions.setGroups(groups);
    }
    
     public String getUsageReport(UserBean userBean, HttpServletRequest servletRequest){
        System.out.println("In getUsageReport:");
        request = new Request("Transaction", "Query");
        request.setCondition("Object", "Job");
        request.setCondition("Action","Charge");
        if(servletRequest.getParameter("Project") != null && servletRequest.getParameter("Project").length() > 0)
            request.setCondition("Project",servletRequest.getParameter("Project"));
        if(servletRequest.getParameter("StartTime") != null && servletRequest.getParameter("StartTime").length() > 0)
            request.setCondition("CreationTime",servletRequest.getParameter("StartTime"), "GE");
        if(servletRequest.getParameter("EndTime") != null && servletRequest.getParameter("EndTime").length() > 0)
            request.setCondition("CreationTime",servletRequest.getParameter("EndTime"), "LT");
        request.setSelection("User","GroupBy");
        request.setSelection("Amount","Sum");
        request.setSelection("Amount","Count");
        request.setSelection("Amount","Average");
        
             
        Element data = new Element("Display");
        data.addContent(performRequest(userBean).getDataElement());
        
        
        //pass back in what the user selected to re-select them
        util.addElementAndValue(data, "Project", servletRequest.getParameter("Project"));
        util.addElementAndValue(data, "StartTime", servletRequest.getParameter("StartTime"));
        util.addElementAndValue(data, "EndTime", servletRequest.getParameter("EndTime"));
        util.addElementAndValue(data, "DisplayTime", servletRequest.getParameter("DisplayTime"));
        return util.convertResponseToXML(data);
    }
    
    
    public String displayBalance(UserBean userBean, HttpServletRequest servletRequest){
        
        //1) list accounts
        System.out.println("In displayBalance:");
        String[] children = {"AccountUser", "AccountProject", "AccountMachine", "AccountAccount"};
        Element accounts = new Element("Accounts");
        myobject = "Account";
        Element acctElements = doAccountQuery(userBean, servletRequest);
        accounts.addContent(acctElements);
        
       // System.out.println("accounts:");
        util.convertResponseToXML(acctElements);
        
        //2) list reservations. only do query if we have at least one account
        //Element reservations = new Element("Reservations");
        myobject = "Reservation";
        
        //System.out.println("accounts: ");
        //util.convertResponseToXML(acctElements);
        if(acctElements.getChild("Account") != null)//has to be at least one account
            doReservationQuery(userBean, acctElements);
        //System.out.println("reservations:");
        //util.convertResponseToXML(reservations);
        
             
        Element data = new Element("Display");
        data.addContent(accounts);
        //data.addContent(reservations);
        //data.addContent(balance);
        
        //pass back in what the user selected to re-select them
        util.addElementAndValue(data, "User", servletRequest.getParameter("User"));
        util.addElementAndValue(data, "Project", servletRequest.getParameter("Project"));
        util.addElementAndValue(data, "Machine", servletRequest.getParameter("Machine"));
        util.addElementAndValue(data, "DisplayTime", servletRequest.getParameter("DisplayTime"));
        return util.convertResponseToXML(data);
    }
    
    
     public String getAccountStatement(UserBean userBean, HttpServletRequest servletRequest){
        String start = "-infinity";
        String end = "now";
        if(servletRequest.getParameter("StartTime") != null && servletRequest.getParameter("StartTime").length() > 0) 
            start = servletRequest.getParameter("StartTime");
        if(servletRequest.getParameter("EndTime") != null && servletRequest.getParameter("EndTime").length() > 0) 
            end = servletRequest.getParameter("EndTime");
        
        Element display = new Element("Display");
        Element beginningBalance = new Element("BeginningBalance");
        request = new Request("Allocation", "Query");
        request.setCondition("Account",  servletRequest.getParameter("Id"));
        request.setCondition("Active", "True");
        request.setOption("Time", start);
        request.setSelection("Amount", "Sum");
        System.out.println("1rst query: ");
        beginningBalance.setContent(performRequest(userBean).getDataElement());
        display.getChildren().add(beginningBalance);
        
        Element totalCredits = new Element("TotalCredits");
        request = new Request("Transaction", "Query");
        request.setCondition("Account",  servletRequest.getParameter("Id"));
        request.setCondition("Delta", "0", "GT");
        request.setCondition("CreationTime", start, "GE");
        request.setCondition("CreationTime", end, "LT");
        request.setSelection("Delta", "Sum");
        System.out.println("2nd query: ");
        totalCredits.setContent(performRequest(userBean).getDataElement());
        display.getChildren().add(totalCredits);
        
        Element totalDebits = new Element("TotalDebits");
        request = new Request("Transaction", "Query");
        request.setCondition("Account",  servletRequest.getParameter("Id"));
        request.setCondition("Delta", "0", "LE");
        request.setCondition("CreationTime", start, "GE");
        request.setCondition("CreationTime", end, "LT");
        request.setSelection("Delta", "Sum");
        System.out.println("3rd query: ");
        totalDebits.setContent(performRequest(userBean).getDataElement());
        display.getChildren().add(totalDebits);
        
        
        Element endingBalance = new Element("EndingBalance");
        request = new Request("Allocation", "Query");
        request.setCondition("Account",  servletRequest.getParameter("Id"));
        request.setCondition("Active", "True");
        request.setOption("Time", end);
        request.setSelection("Amount", "Sum");
        
        System.out.println("4th query: ");
        endingBalance.setContent(performRequest(userBean).getDataElement());
        display.getChildren().add(endingBalance);
        
        
        //now, if they chose to itemize, do additional queries:
        if(servletRequest.getParameter("Itemize") != null && servletRequest.getParameter("Itemize").equalsIgnoreCase("true")){
            Element credits = new Element("Credits");
            request = new Request("Transaction", "Query");
            request.setCondition("Account",  servletRequest.getParameter("Id"));
            request.setCondition("Delta", "0", "GT");
            request.setCondition("CreationTime", start, "GE");
            request.setCondition("CreationTime", end, "LT");
            request.setSelection("Action");
            request.setSelection("Child");
            request.setSelection("CreationTime");
            request.setSelection("Description");
            request.setSelection("Delta");
            System.out.println("5th query: ");
            credits.setContent(performRequest(userBean).getDataElement());
            display.getChildren().add(credits);
            
            Element debits = new Element("Debits");
            request = new Request("Transaction", "Query");
            request.setCondition("Account",  servletRequest.getParameter("Id"));
            request.setCondition("Delta", "0", "LE");
            request.setCondition("CreationTime", start, "GE");
            request.setCondition("CreationTime", end, "LT");
            request.setSelection("Action");
            request.setSelection("Child");
            request.setSelection("CreationTime");
            request.setSelection("Description");
            request.setSelection("Delta");
            System.out.println("6th query: ");
            debits.setContent(performRequest(userBean).getDataElement());
            display.getChildren().add(debits);
        }
        
        //data.addContent(accounts);
        //pass back in what the user selected to re-select them
        util.addElementAndValue(display, "Id", servletRequest.getParameter("Id"));
        util.addElementAndValue(display, "StartTime", servletRequest.getParameter("StartTime"));
        util.addElementAndValue(display, "EndTime", servletRequest.getParameter("EndTime"));
        util.addElementAndValue(display, "Itemize", servletRequest.getParameter("Itemize"));
        util.addElementAndValue(display, "DisplayTime", servletRequest.getParameter("DisplayTime"));
         return util.convertResponseToXML(display);
     }
    
    
    
    
    public String loadThisRoleInfo(ConditionBean conditionBean, UserBean userBean, HttpServletRequest servletRequest){
        System.out.println("loadThisRoleInfo");
        
        conditionBean.setFieldNames("");
        conditionBean.setConditionNames("Name");
        setMyaction("Query");
        setMyobject("Role");
        Element data = new Element("Data");
        
        Element roleData = doActionGetElement(servletRequest, conditionBean, userBean, null);
        userBean.setOriginalObject(roleData);
        
        conditionBean.setConditionNames("Role");
        //conditionValue was already set to the name of the project we're loading from the form submit to the mod_proj page
        setMyobject("RoleUser");
        Element roleUser = this.doActionGetElement(servletRequest, conditionBean, userBean, null);
        if(roleUser.getChildren().size() == 0) 
            roleUser =  (Element)new Element("Data").addContent(new Element("RoleUser"));
        data.getChildren().add(roleUser);
        
        
        //make hashmap for object links & pkeys"
        HashMap pkeys = new HashMap();
        pkeys.put("RoleUser", "Name");
        
        userBean.setOriginalObjectLinks(data, pkeys);//"Name" is the primary key
   
        setMyobject("RoleAction");
        Element roleAction = this.doActionGetElement(servletRequest, conditionBean, userBean, null);
        if(roleAction.getChildren().size() == 0) 
            roleAction =  (Element)new Element("Data").addContent(new Element("RoleAction"));
        data.getChildren().add(roleAction);
        
        userBean.setRoleObjecActionVector(roleAction);
        
        data.getChildren().add(roleData);
        
        //get ready to modify this project: bean uses this when doAction is called from results.jsp
        //setMyobject("Role");
        //setMyaction("modifyRole");

        userBean.setUserAction("");        
        addObjectActionMessage(data);
        
        
        return util.convertResponseToXML(data);
    }
    
    
    
    
    
    /* no longer used
    public String verifyAccounts(UserBean userBean, HttpServletRequest servletRequest){
        Element results = new Element("results");
        Element from = this.getObjectListElement(userBean, null, servletRequest, "from");
        from.setName("From");
        results.addContent(from);
        Element to = this.getObjectListElement(userBean, null, servletRequest, "to");
        to.setName("To");
        results.addContent(to);
        
        //pass back in params user selected to pre-fill form:
        Element params = new Element("Params");
        
        Enumeration paramNames = servletRequest.getParameterNames();
        String paramName;
        String paramValue;
        while (paramNames.hasMoreElements()){
            paramName = (String)paramNames.nextElement();
            paramValue = servletRequest.getParameter(paramName);
            if(paramName.startsWith("to") || paramName.startsWith("from") || paramName.startsWith("amount")){
                util.addElementAndValue(params, paramName, paramValue);
            }
        }
        results.addContent(params);
        
       
        System.out.println("verifyAccounts's data: " + util.convertResponseToXML(results));
        return util.convertResponseToXML(results);
    }
    */
    
    public Element makeTransfer(HttpServletRequest httpRequest, UserBean userBean, AccountBean accountBean){
        System.out.println("In makeTransfer");
        
        accountBean.makeTransfer(request);
        
        
        
        //this will clear out the request object after it executes the request.
        Element data =  performRequest(userBean).getDataElement();
        
        //save message from creating just the project because it will get reset 
        //when creating all the projectUsers, projectMachines, projectProjects.
        mymessages = mymessage + "\n";
        
        //error condition
        if(data == null) 
            return data;
        
        System.out.println("Transfer Account xml: "+util.convertResponseToXML(data));
        return data;
    }
    
    
    
    
    public String getJobQuoteInputs(UserBean userBean){
        //1) query ChargeRate where Type = Resource, select names
        request = new Request("ChargeRate", "Query");
        request.setCondition("Type", "Resource");
        request.setSelection("Name");
        Element resources =  new Element("Resource");
        resources.addContent(performRequest(userBean).getDataElement());
        
        //2) query ChargeRate where Type != Resource, setOption Unique=True, select Type
        request = new Request("ChargeRate", "Query");
        request.setCondition("Type", "Resource", "NE");
        request.setOption("Unique", "True");
        request.setSelection("Type");
        Element others =  new Element("Other");
        others.addContent(performRequest(userBean).getDataElement());
        
        Element data =  new Element("Data");
        data.addContent(resources);
        data.addContent(others);
        
        
        
        addObjectActionMessage(data);
        return util.convertResponseToXML(data);
    }
    
    
    public String getChargeJobInputs(UserBean userBean){
        setMyaction("Create");
        Element inputs = getInputData(userBean);
        Element user = util.getChildsParent(inputs, "Name", "User");
        user.getChild("Required").setText("True");
        user.getChild("Name").setText("UserId");
        Element project = util.getChildsParent(inputs, "Name", "Project");
        project.getChild("Required").setText("True");
        project.getChild("Name").setText("ProjectId");
        Element machine = util.getChildsParent(inputs, "Name", "Machine");
        machine.getChild("Required").setText("True");
        machine.getChild("Name").setText("MachineName");
        util.getChildsParent(inputs, "Name", "WallDuration").getChild("Required").setText("True");
        
        setMyaction("Charge");
        //addObjectActionMessage(inputs);//done in getJobQuoteInputs method
        return "<Data>" + util.convertResponseToXML(inputs) + getJobQuoteInputs(userBean) +"</Data>";
    }
    
    
    public Element getAccess(UserBean userBean){
        request = new Request("RoleUser", "Query");
        //request.setSelection("Parent");
        request.setCondition("Name", userBean.getUsername());
        request.setCondition("Name", "ANY", "EQ", "Or", "0");
        Response response = performRequest(userBean);
        Element data = response.getDataElement();
        
        
        request = new Request("RoleAction", "Query");
        Iterator itr = (data.getChildren()).iterator();
        int counter = 1;
        int length = response.getCount();
        Element attribute;
        String parent;
        while(itr.hasNext()) {
            attribute = (Element)itr.next();
            parent = attribute.getChildText("Role");
            if(counter == 1 && length > 1)
                request.setCondition("Role", parent, "EQ", "", "1");
            else if(counter == length && length > 1)
                request.setCondition("Role", parent, "EQ", "Or", "-1");
            else
                request.setCondition("Role", parent, "EQ", "Or", "0");
            counter++;
        }
        
        return performRequest(userBean).getDataElement();
    
    }
    
    
    
    
    
    /*
    public String verifyAccountsOld(UserBean userBean, HttpServletRequest servletRequest){
        System.out.println("verifyAccounts");
        
        myobject = "Account";
        request.setAction("Query");
        request.setObject("Account");
        
        request.setOption("UseRules", "True");
        request.setOption("SubtractReservationFromAmount", "True");
        request.setOption("SortByExpendability", "True");
        
        
        //pass back in params user selected to pre-fill form:
        Element params = new Element("Params");
        
        
        
        if(servletRequest.getParameter("fromId") != null){
            request.setCondition("Id", servletRequest.getParameter("fromId"));
            util.addElementAndValue(params, "fromId", servletRequest.getParameter("fromId"));
        }
        else{
            request.setOption("User", servletRequest.getParameter("fromUser"));
            request.setOption("Project", servletRequest.getParameter("fromProject"));
            request.setOption("Machine", servletRequest.getParameter("fromMachine"));   
            
            util.addElementAndValue(params, "fromUser", servletRequest.getParameter("fromUser"));
            util.addElementAndValue(params, "fromProject", servletRequest.getParameter("fromProject"));
            util.addElementAndValue(params, "fromMachine", servletRequest.getParameter("fromMachine"));
        }
        //System.out.println("in verify accounts:\n"+ request.toString());
        Element data = performRequest(userBean).getDataElement();
        
        String[] primaryKey = getPrimaryKeys(userBean, myobject);
        userBean.setKey(primaryKey[0]);  
        //get the default attributes to set the selection 
        Element attributes = getAttributes(userBean, myobject);
        //now get any links associated with this object if it is "Project", like Project has projectusers, etc.
        this.addComplexObjectChildren(userBean, data, attributes, primaryKey[0]); 
        addObjectActionMessage(data);
        //System.out.println("verifyAccounts's data: " + util.convertResponseToXML(data));
        data.setName("From");
        Element results = new Element("results");
        results.addContent(data);
        
        
        request.setAction("Query");
        request.setObject("Account");
        request.setOption("UseRules", "True");
        request.setOption("SubtractReservationFromAmount", "True");
        request.setOption("SortByExpendability", "True");
        if(servletRequest.getParameter("toId") != null){
            request.setCondition("Id", servletRequest.getParameter("toId"));
            util.addElementAndValue(params, "toId", servletRequest.getParameter("toId"));
        }
        else{
            request.setOption("User", servletRequest.getParameter("toUser"));
            request.setOption("Project", servletRequest.getParameter("toProject"));
            request.setOption("Machine", servletRequest.getParameter("toMachine")); 
            
            util.addElementAndValue(params, "toUser", servletRequest.getParameter("toUser"));
            util.addElementAndValue(params, "toProject", servletRequest.getParameter("toProject"));
            util.addElementAndValue(params, "toMachine", servletRequest.getParameter("toMachine"));       
        }
        //System.out.println("in verify accounts:\n"+ request.toString());
        Element data2 = performRequest(userBean).getDataElement();
        
 
        //now get any links associated with this object if it is "Project", like Project has projectusers, etc.
        this.addComplexObjectChildren(userBean, data2, attributes, primaryKey[0]); 
        addObjectActionMessage(data2);
        //System.out.println("verifyAccounts's data: " + util.convertResponseToXML(data2));
        
        //to.getChildren().addAll(data2.getChildren());
        data2.setName("To");
        results.addContent(data2);
        results.addContent(params);
        
        results.addContent(attributes);
        
        System.out.println("verifyAccounts's data: " + util.convertResponseToXML(results));
        return util.convertResponseToXML(results);
    }
    
/*
     Enumeration paramNames = servletRequest.getParameterNames();
        String paramName;
        String paramValues;
        while (paramNames.hasMoreElements()){
            paramName = (String)paramNames.nextElement();
            paramValues = servletRequest.getParameter(paramName);
            System.out.println(paramName +" = "+paramValues);
        }
 */    
    
    
    
    //main for testing purposes
    public static void main(String[] args) {
      try{
          //RequestBean requestBean = new RequestBean();
          //requestBean.setHomeDir("C:\\Gold\\gold_gui\\web\\");
          //UserBean userBean = new UserBean();
          //userBean.setPassword("xyz");
          //userBean.setUsername("zjohns");
          //requestBean.getObjectsXML(userBean);
          
          
          ElementUtil util = new ElementUtil();
          RequestBean requestBean = new RequestBean();
          Element access = requestBean.getAccess(new UserBean());
          
          
      }catch(Exception e){
          e.printStackTrace();
      }
    }
      
    public String toString() {
        String info = "";
        if(conditionName != null) info += "\n  conditionName: " + conditionName;
        if(conditionValue != null) info += "\n  conditionValue: " + conditionValue;
        if(homeDir != null) info += "\n  homeDir: " + homeDir;
        if(myaction != null) info += "\n  myaction: " + myaction;
        if(mymessage != null) info += "\n  mymessage: " + mymessage;
        if(mymessages != null) info += "\n  mymessages: " + mymessages;
        if(myobject != null) info += "\n  myobject: " + myobject;
        return info;
    }    
    
}


