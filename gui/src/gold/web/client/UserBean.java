/*
 * UserBean.java
 *
 * Created on September 29, 2003, 9:48 AM
 */

package gold.web.client;

import java.beans.*;
import gold.*;
import org.jdom.*;
//import java.util.*;
import java.util.regex.*;
import java.util.*;
//import java.util.regex;
/**
 *
 * @author  d3l028
 */
public class UserBean implements java.io.Serializable {
        
    /** Holds value of property username. */
    private String username;    
    
    /** Holds value of property password. */
    private String password;    
    
    /** Holds value of property admin. */
    private boolean admin;    
   
    /** Holds value of property showHidden. */
    private String showHidden;    
   
    /** Holds value of property userAction. */
    private String userAction;
    
    /** Holds value of property data. */
    private Element data;
    
    /** Holds value of property searchCriteria. */
    private String searchCriteria;
    
    /** Holds value of property key. */
    private String key;
    
    
    // holds the value of a loaded complex object's linking children, 
    //like a Project's ProjectUsers, ProjectMachines, & ProjectProjects
    private HashMap originalObjectLinks;
    
    // holds the value of a loaded complex object's linking children, 
    //like a Project's ProjectUsers, ProjectMachines, & ProjectProjects
    private Vector roleObjecActionVector;
    
    // holds the value of a loaded complex object, like attributes of a Project or Account:
    private HashMap originalObject;
    
    
    
    /** Creates new UserBean */
    public UserBean() {
        searchCriteria = "";
        originalObject = null;
        originalObjectLinks = null;
    }
    

    public boolean authenticate(){
        try{
            //Message mesg = new Message(Gold.TOKEN_PASSWORD, username, password);//zjohns is username, xyz password
            Chunk mesgChunk = new Chunk(Gold.TOKEN_PASSWORD, username, password);//zjohns is username, xyz password
            Request r = new Request("RoleUser", "Query");
            r.setSelection("Role");
            r.setCondition("Name", username);
            
            r.setActor(username);
            System.out.println("REQUEST: "+r.toString());
            mesgChunk.setRequest(r);
            Chunk reply = mesgChunk.getChunk();
            Response response = reply.getResponse();
            //int count = response.getCount();


            System.out.println("MESSAGE: "+response.getMessage());
            System.out.println("RESPONSE: "+response.toString());
            admin = false;
            Element datas = response.getDataElement();
            Iterator itr = (datas.getChildren()).iterator();
            Element value;
            while(itr.hasNext()) {
                value = (Element)itr.next();
                if("SystemAdmin".equalsIgnoreCase(value.getChildText("Role")))
                    admin = true;
            }

            return response.getStatus().equalsIgnoreCase("Success");//can be: Success, Warning, or Failure
        
        }catch (Exception e){
            return false;
        }
    }
    
    
    
    /** Getter for property username.
     * @return Value of property username.
     *
     */
    public String getUsername() {
        return this.username;
    }
    
    /** Setter for property username.
     * @param username New value of property username.
     *
     */
    public void setUsername(String username) {
        this.username = username;
    }
    
    /** Getter for property password.
     * @return Value of property password.
     *
     */
    public String getPassword() {
        return this.password;
    }
    
    /** Setter for property password.
     * @param password New value of property password.
     *
     */
    public void setPassword(String password) {
        this.password = password;
    }

    /** Getter for property admin.
     * @return Value of property admin.
     *
     */
    public boolean isAdmin() {
        return this.admin;
    }    
    
    /** Getter for property showHidden.
     * @return Value of property showHidden.
     *
     */
    public String getShowHidden() {
        return this.showHidden;
    }    
    
    /** Setter for property showHidden.
     * @param showHidden New value of property showHidden.
     *
     */
    public void setShowHidden(String showHidden) {
        this.showHidden = showHidden;
    }
    
    /** Getter for property userAction.
     * @return Value of property userAction.
     *
     */
    public String getUserAction() {
        return this.userAction;
    }
    
    /** Setter for property userAction.
     * @param userAction New value of property userAction.
     *
     */
    public void setUserAction(String userAction) {
        this.userAction = userAction;
    }
    
    /** Getter for property data.
     * @return Value of property data.
     *
     */
    public Element getData() {
        return this.data;
    }
    
    /** Setter for property data.
     * @param data New value of property data.
     *
     */
    public void setData(Element newData) {
        data = newData;
    }
    
    
    public void setOriginalObject(Element datas) {
        ElementUtil util = new ElementUtil();
        System.out.println("setOriginalObject: " + util.convertResponseToXML(datas));
        originalObject = util.convertIntoHashMap(datas);
    }
    
    public void setOriginalObjectLinks(Element datas, HashMap pkeys) {
        ElementUtil util = new ElementUtil();
        System.out.println("setOriginalObjectLinks: ");
        util.convertResponseToXML(datas);
        originalObjectLinks = util.convertIntoLinkingHashMap(datas, pkeys);
    }
    
   public void setRoleObjecActionVector(Element datas){
        ElementUtil util = new ElementUtil();
        System.out.println("setRoleObjecActionVector: ");
        util.convertResponseToXML(datas);
        roleObjecActionVector = util.convertRoleObjecActionIntoVector(datas);
   }
    
    public HashMap getOriginalObject() {
        return originalObject;
    }
    
    public HashMap getOriginalObjectLinks() {
        return originalObjectLinks;
    }
    
    public Vector getRoleObjecActionVector() {
        return roleObjecActionVector;
    }
    /** Getter for property criteria.
     * @return Value of property criteria.
     *
     */
    public String getSearchCriteria() {
        return this.searchCriteria;
    }
    
    /** Setter for property criteria.
     * @param criteria New value of property criteria.
     *
     */
    public void setSearchCriteria(String searchCriteria) {
        this.searchCriteria = searchCriteria;
    }
    
    
    
    public String getSearchResults(RequestBean requestBean) {
        System.out.println("In getSearchResults");
        //in case user just presses "search" button without any search criteria we want to return everything:
        boolean blank = false;
        if(searchCriteria == null || searchCriteria.length() == 0){
            searchCriteria = ".";
            blank = true;
        }
        
        Element copiedData =  new Element("Data");
        
        List list = data.getChildren();
        Iterator itr = list.iterator();
        Element attribute;
        String attributeText = "";
        Matcher matcher;
        Pattern pattern = Pattern.compile(searchCriteria);
        while(itr.hasNext()){
            attribute = (Element)itr.next();
            attributeText = attribute.getChildText(key);
            if(attributeText != null){
                matcher = pattern.matcher(attributeText);
                if(matcher.find()){
                    copiedData.addContent((Element)attribute.clone());          
                    System.out.println("matched " + searchCriteria + " against " + attributeText);
                }
                else 
                    System.out.println( searchCriteria +" did not match " + attributeText);
            }
        }
        if(blank) searchCriteria = "";
        ElementUtil util = new ElementUtil();
        util.addElementAndValue(copiedData, "searchCriteria", searchCriteria);
        util.addElementAndValue(copiedData, "myprimarykey", key);
        requestBean.addObjectActionMessage(copiedData);
               
        
        return util.convertResponseToXML(copiedData);
    }
    
    
    
    
    
    public String getSearchResults2(RequestBean requestBean) {
        System.out.println("In getSearchResults");
        Element copiedData = (Element)data.clone();
        //first find out how to search (% is wildcard and can be at end, beginning, or both):
        int searchWith =0;
        String tempSearchCriteria = searchCriteria;
        ElementUtil util = new ElementUtil();
        if(searchCriteria.equalsIgnoreCase("%")) {
            //if they only input a wildcard, return everything;
            copiedData.getChildren().add(new Element("searchCriteria"));
            Element element = copiedData.getChild("searchCriteria");
            element.setText(searchCriteria);
            return util.convertResponseToXML(copiedData);
        }else if(searchCriteria.charAt(0) == '%'){
            //if '%' at end also...
            if(searchCriteria.charAt(searchCriteria.length()-1) == '%'){
              searchWith = 3;
              tempSearchCriteria = searchCriteria.substring(1, searchCriteria.length() -1); //trim off '%'
            }else {//else we only have '%' at beginning
              searchWith = 1;
              tempSearchCriteria = searchCriteria.substring(1); //trim off '%'
            }
        }else if(searchCriteria.charAt(searchCriteria.length()-1) == '%'){
            //else if '%' at end only
            searchWith = 2;
            tempSearchCriteria = searchCriteria.substring(0, searchCriteria.length() -1); //trim off '%'
        }
        
        
        //using searchCriteria, sort out elements from data that don't match:
        List list = copiedData.getChildren();
        ListIterator itr = list.listIterator(list.size());
        Element attribute;
        String attributeText = "";
        while(itr.hasPrevious()) {
            attribute = (Element)itr.previous();
            attributeText = attribute.getChildText(key);
            if(attributeText != null){
                if( 
                    ((searchWith == 0) && !attributeText.equalsIgnoreCase(tempSearchCriteria)) ||
                    ((searchWith == 1) && !attributeText.toLowerCase().endsWith(tempSearchCriteria.toLowerCase())) ||
                    ((searchWith == 2) && !attributeText.toLowerCase().startsWith(tempSearchCriteria.toLowerCase())) ||
                    ((searchWith == 3) && (attributeText.toLowerCase().indexOf(tempSearchCriteria.toLowerCase()) == -1) )
                  ){
                    System.out.println("tempSearchCriteria"+tempSearchCriteria+", searchWith: " + searchWith +", removing "+attributeText);
                    itr.remove();
                    copiedData.removeContent(attribute);
                }else System.out.println("tempSearchCriteria"+tempSearchCriteria+", searchWith: " + searchWith +", keeping "+attributeText);
            }
        }
        //add searchCriteria to result to put into input field:
        copiedData.getChildren().add(new Element("searchCriteria"));
        Element element = copiedData.getChild("searchCriteria");
        element.setText(searchCriteria);
        copiedData.getChildren().add(new Element("myaction"));
        element = copiedData.getChild("myaction");
        element.setText("Modify");
        return util.convertResponseToXML(copiedData);
    }
    
    /** Getter for property key.
     * @return Value of property key.
     *
     */
    public String getKey() {
        return this.key;
    }
    
    /** Setter for property key.
     * @param key New value of property key.
     *
     */
    public void setKey(String key) {
        this.key = key;
    }
    
    public String toString() {   
        String info = "";
        if(username != null) info += "\nusername: " + username;
        info += "\nadmin: " + String.valueOf(admin);
        if(showHidden != null) info += "\nshowHidden: " + showHidden;
        if(userAction != null) info += "\nuserAction: " + userAction;
        if(searchCriteria != null) info += "\nsearchCriteria: " + searchCriteria;
        if(key != null) info += "\nkey: " + key;
        return info;
    }
    
}
