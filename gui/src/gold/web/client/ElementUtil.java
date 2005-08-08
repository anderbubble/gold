/*
 * ElementUtil.java
 *
 * Created on November 12, 2003, 8:31 PM
 */

package gold.web.client;


import gold.CanonicalXMLOutputter;

import org.jdom.Element;
import java.util.Iterator;
import java.util.*;

/**
 *
 * @author  d3l028
 */
public class ElementUtil extends Object implements java.io.Serializable {
    /*
     * this method adds to the data element a new element named elementName with the
     * value of elementValue
     */
    public Element addElementAndValue(Element data, String elementName, String elementValue){
        Element element = new Element(elementName);
        element.setText(elementValue);
        data.getChildren().add(element);
        return element;
    }
    
    
    
    
    /*
     * adds just a new element to data named elementName
     */
    public Element addElement(Element data, String elementName){
        Element element = new Element(elementName);
        data.getChildren().add(element);
        return element;
    }
    
    
        
    
    public Element getChildsParent(Element data, String childName, String childValue){
        Iterator itr = (data.getChildren()).iterator();
        Element child;
        while(itr.hasNext()){
            child = (Element)itr.next();//this will be a project
            //this will be a child of project, IE: <Name>
            if(child.getChildText(childName).equalsIgnoreCase(childValue))
                return child;
        }
        return null;
    }
        
    /*
     * for every child with childname this method sets an attribute of name 
     * attributeName with the value of attributeValue
     */
    public void setChildrenAttributes(Element data, String childName, String attributeName, String attributeValue){
        Iterator itr = (data.getChildren()).iterator();
         while(itr.hasNext()) 
            ((Element)itr.next()).getChild(childName).setAttribute(attributeName, attributeValue);
    }
    
    /*
     * for every child with childname this method sets an attribute of name 
     * attributeName with the value of attributeValue
     */
    public void setChildrenChildren(Element data, String childChildName){
        Iterator itr = (data.getChildren()).iterator();
        while(itr.hasNext()) {
            Element child = (Element)itr.next();
            this.addElement(child, childChildName);
        }
    }
    
    public void setChildrenChildrenAndAttribute(Element data, String childChildName, String AttributeName, String AttributeValue){
        Iterator itr = (data.getChildren()).iterator();
        while(itr.hasNext()) {
            Element child = (Element)itr.next();
            Element newChild = this.addElement(child, childChildName);
            newChild.setAttribute(AttributeName, AttributeValue);
        }
    }   
    /*
     * returns true if this data has a child named child with the text of text
     */
    public boolean hasChildWithText(Element data, String child, String text){            
        Iterator itr = (data.getChildren()).iterator();
        while(itr.hasNext()) {
            Element thing = (Element)itr.next();
            if(text.equalsIgnoreCase(thing.getChildText(child))){
                return true;
            }
        }
        return false;
    }

    public boolean hasChildWithTexts(Element data, String child, String text, String child2, String text2){            
        Iterator itr = (data.getChildren()).iterator();
        while(itr.hasNext()) {
            Element thing = (Element)itr.next();
            if(text.equalsIgnoreCase(thing.getChildText(child)) && 
               text2.equalsIgnoreCase(thing.getChildText(child2)) ){
                return true;
            }
        }
        return false;
    }
    
    public boolean hasAccessToObject(Element access, String object){
        return hasChildWithText(access, "Object", "ANY") || hasChildWithText(access, "Object", object);
    }
    
    public boolean hasAccessToObjectWithAction(Element access, String object, String action){
        return (hasChildWithTexts(access, "Object", "ANY", "Name", "ANY") || 
               hasChildWithTexts(access, "Object", "ANY", "Name", action) ||
               hasChildWithTexts(access, "Object", object, "Name", "ANY") ||
               hasChildWithTexts(access, "Object", object, "Name", action) );
    }
    
    
    /*
     * this method converts the xml represented by data into a string and returns it
     */
    public static String convertResponseToXML(Element data){
        if(data == null) return "";
        CanonicalXMLOutputter xmlout = new CanonicalXMLOutputter();
        String xml = xmlout.outputString(data);
        System.out.println("XML: " +xml);
        return xml;
    }
 
    /*
     *ie of data:
    <Data>
      <Project>
          <Name>dingleberry2</Name> 
          <Active>t</Active> 
          <Description>sticky</Description> 
      </Project>
    </Data>
     */
    public HashMap convertIntoHashMap(Element data){
        System.out.println("\n\n*****************************\n\nThe Map:");
        HashMap map = new HashMap();
        Iterator itr, itr2 = null;
        itr = (data.getChildren()).iterator();
        Element child, childChild = null;
        String childText = null;
        while(itr.hasNext()) {
            child = ((Element)itr.next());
            //so hashmap should have key value pairs like: [MPP4, t]
            if(child.getChildren().size() > 0){
                itr2 = (child.getChildren()).iterator();
                while(itr2.hasNext()) {
                    childChild = ((Element)itr2.next());
                    childText = childChild.getText();
                    //case for booleans where we get back 't' or 'f' but we're expected to send 'True' or 'False'
                    if(childChild.getName().equalsIgnoreCase("Active") && childText != null){
                        if(childText.equalsIgnoreCase("True")) childText = "True";
                        else if (childText.equalsIgnoreCase("False")) childText = "False";
                    }
                    map.put(childChild.getName(), childText);
                }
            }
        }
        
        System.out.println(map.toString() +"\n\n*****************************\n\n");
        return map;
    }
    
    
    
   /*
     * this method converts the xml fomatted Element data into a hashmap of hashmaps of key, value pairs:
     */
    public HashMap convertIntoLinkingHashMap(Element data, HashMap pkeys){
        HashMap map = new HashMap();
        //for projects, this will be 4 children, each named Data, and will store:
        //project info, projectUsers, projectProjects, projectMachines
        Iterator itr = (data.getChildren()).iterator();
        Element child, childChild = null;
        Iterator itr2 = null;
        while(itr.hasNext()) {
            child = ((Element)itr.next());
            itr2 = (child.getChildren()).iterator();
            childChild = (Element)itr2.next();
            map.put(childChild.getName(), makeHash(child, (String)pkeys.get(childChild.getName())));
        }        
        System.out.println("\n\n*****************************\n\nLinking Map:" + map.toString() +"\n\n*****************************\n\n");
        return map;
    }
    
 
/*IE: of data passed in:
    <Data>
        <ProjectMachine>
            <Parent>dingleberry2</Parent> 
            <Name>MPP4</Name> 
            <Active>t</Active> 
        </ProjectMachine>
        <ProjectMachine>
            <Parent>dingleberry2</Parent> 
            <Name>ZoeMachine</Name> 
            <Active>t</Active> 
        </ProjectMachine>
    </Data>
 *
 *or
 *
    <Data>
        <Project>
            <Name>dingleberry2</Name> 
            <Active>t</Active> 
            <Description>sticky</Description> 
        </Project>
    </Data>
 *
*/
    private HashMap makeHash(Element data, String pkey){
        HashMap map = new HashMap(); 
        Iterator itr = (data.getChildren()).iterator();
        Element child = null;
        String childText = null;
        while(itr.hasNext()) {
            child = ((Element)itr.next());
            childText = "";
            //so hashmap should have key value pairs like: [MPP4, t]
            if(child.getChildren().size() > 0){
                //map.put(child.getChildText("Name"), child.getChildText("Active"));
                if(child.getChildText("Active") != null)
                    childText = child.getChildText("Active");
                if(child.getChildText("Admin") != null)
                    childText += ","+child.getChildText("Admin");
                if(child.getChildText("Access") != null)
                    childText += ","+child.getChildText("Access");
                if(child.getChildText("AllowDescendants") != null)
                    childText += ","+child.getChildText("AllowDescendants");
                if(child.getChildText("DepositShare") != null)
                    childText += ","+child.getChildText("DepositShare");
                if(child.getChildText("AllowDescendants") != null)
                    childText += ","+child.getChildText("AllowDescendants");
                if(child.getChildText("Instance") != null)
                    childText += ","+child.getChildText("Instance");
                //case for roleUsers
                
                //case for booleans where we get back 't' or 'f' but we're expected to send 'True' or 'False'
                //if(childText.equalsIgnoreCase("t")) childText = "True";
                //else if (childText.equalsIgnoreCase("f")) childText = "False";
                
                map.put(child.getChildText(pkey), childText);
            }
        }
        return map;
    }
    
    
    //make a vector of the elements in order to test if it contains another element
    public Vector convertRoleObjecActionIntoVector(Element data){
        Iterator itr = (data.getChildren()).iterator();
        Element child;
        String childText = "";
        Vector dataVector = new Vector();
        while(itr.hasNext()) {
            child = ((Element)itr.next());
            childText = child.getChildText("Object") + "," +child.getChildText("Name") + "," + child.getChildText("Instance");
            dataVector.add(childText);            
        }
        return dataVector;
    }
    
}
