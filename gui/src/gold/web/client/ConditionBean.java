/*
 * ConditionBean.java
 *
 * Created on August 6, 2003, 8:31 PM
 */

package gold.web.client;

import java.beans.*;

/**
 *
 * @author  zjohns
 */
public class ConditionBean {
        
    /** Holds value of property conjunctions. */
    private String conjunctions;
    
    /** Holds value of property groups. */
    private String groups;
    
    /** Holds value of property conditionNames. */
    private String conditionNames;
    
    /** Holds value of property conditionOperators. */
    private String conditionOperators;
    
    /** Holds value of property values. */
    private String conditionValues;
    
    /** Holds value of property fieldNames. */
    private String fieldNames;
    
    /** Holds value of property fieldOperators. */
    private String fieldOperators;
    
    /** Holds value of property hidden. */
    private boolean hidden;
    
    /** Holds value of property fieldValues. */
    private String fieldValues;
    
    /** Holds value of property viewType. */
    private String viewType;
    
    /** Holds value of property thisAction. */
    private String thisAction;
    
    /** Holds value of property optionName. */
    private String optionName;    
    
    /** Holds value of property optionValue. */
    private String optionValue;
    
    /** Creates new ConditionBean */
    public ConditionBean() {
        fieldNames = "";
        fieldOperators  = "";
        fieldValues  = "";
        conjunctions  = "";
        groups  = "";
        conditionNames  = "";
        conditionOperators = "";
        conditionValues = "";
        optionName = "";
        optionValue = "";
        
        viewType = "";      
        thisAction = "";      
        
        this.hidden = false;
    }
    
    public String[] getConditionOperatorsAsArray(){
        return conditionOperators.split(",");
    }
    public String[] getConjunctionsAsArray(){
        return conjunctions.split(",");
    }
    public String[] getGroupsAsArray(){
        return groups.split(",");
    }
    public String[] getConditionNamesAsArray(){
        return conditionNames.split(",");
    }
    public String[] getConditionValuesAsArray(){
        return conditionValues.split(",");
    }
    public String[] getFieldNamesAsArray(){
        return fieldNames.split(",");
    }
    public String[] getFieldOperatorsAsArray(){
        return fieldOperators.split(",");
    }
    public String[] getFieldValuesAsArray(){
        return fieldValues.split(",");
    }
    public String[] getOptionNamesAsArray(){
        return optionName.split(",");
    }
    public String[] getOptionValuesAsArray(){
        return optionValue.split(",");
    }
    
    /////////////////////////////////////////////////////////////
    // 
    //                  IDE GENERATED METHODS:
    //
    /////////////////////////////////////////////////////////////
    
    /** Getter for property conjunctions.
     * @return Value of property conjunctions.
     *
     */
    public String getConjunctions() {
        return this.conjunctions;
    }
    
    /** Setter for property conjunctions.
     * @param conjunctions New value of property conjunctions.
     *
     */
    public void setConjunctions(String conjunctions) {
        this.conjunctions = conjunctions;
        System.out.println("setconjunctions: " + conjunctions);
    }
    
    /** Getter for property groups.
     * @return Value of property groups.
     *
     */
    public String getGroups() {
        return this.groups;
    }
    
    /** Setter for property groups.
     * @param groups New value of property groups.
     *
     */
    public void setGroups(String groups) {
        this.groups = groups;
        System.out.println("setgroups: " + groups);
    }
    
    /** Getter for property names.
     * @return Value of property names.
     *
     */
    public String getConditionNames() {
        return this.conditionNames;
    }
    
    /** Setter for property names.
     * @param names New value of property names.
     *
     */
    public void setConditionNames(String conditionNames) {
        this.conditionNames = conditionNames;
        System.out.println("setConditionNames: " + conditionNames);
    }
    
    /** Getter for property conditionOperators.
     * @return Value of property conditionOperators.
     *
     */
    public String getConditionOperators() {
        return this.conditionOperators;
    }
    
    /** Setter for property conditionOperators.
     * @param conditionOperators New value of property conditionOperators.
     *
     */
    public void setConditionOperators(String conditionOperators) {
        this.conditionOperators = conditionOperators;
        System.out.println("setconditionOperators: " + conditionOperators);
    }
    
    /** Getter for property values.
     * @return Value of property values.
     *
     */
    public String getConditionValues() {
        return this.conditionValues;
    }
    
    /** Setter for property values.
     * @param values New value of property values.
     *
     */
    public void setConditionValues(String values) {
        this.conditionValues = values;
        System.out.println("setConditionValues: " + conditionValues);
    }
    
    /** Getter for property attributes.
     * @return Value of property attributes.
     *
     */
    public String getFieldNames() {
        return this.fieldNames;
    }
    
    /** Setter for property attributes.
     * @param attributes New value of property attributes.
     *
     */
    public void setFieldNames(String fieldNames) {
        this.fieldNames = fieldNames;
        System.out.println("setFieldNames: " + fieldNames);
    }
    
    /** Getter for property operator.
     * @return Value of property operator.
     *
     */
    public String getFieldOperators() {
        return this.fieldOperators;
    }
    
    /** Setter for property operator.
     * @param operator New value of property operator.
     *
     */
    public void setFieldOperators(String fieldOperators) {
        this.fieldOperators = fieldOperators;
        System.out.println("setfieldOperators: " + fieldOperators);
    }
    
    /** Getter for property hidden.
     * @return Value of property hidden.
     *
     */
    public boolean isHidden() {
        return this.hidden;
    }    
    
    /** Setter for property hidden.
     * @param hidden New value of property hidden.
     *
     */
    public void setHidden(boolean hidden) {
        this.hidden = hidden;
        System.out.println("sethidden: " + hidden);
    }
    
    /** Getter for property fieldValues.
     * @return Value of property fieldValues.
     *
     */
    public String getFieldValues() {
        return this.fieldValues;
    }
    
    /** Setter for property fieldValues.
     * @param fieldValues New value of property fieldValues.
     *
     */
    public void setFieldValues(String fieldValues) {
        this.fieldValues = fieldValues;
    }
    
    /** Getter for property viewType.
     * @return Value of property viewType.
     *
     */
    public String getViewType() {
        return this.viewType;
    }
    
    /** Setter for property viewType.
     * @param viewType New value of property viewType.
     *
     */
    public void setViewType(String viewType) {
        this.viewType = viewType;
        System.out.println("setviewType: " + viewType);
    }
    
    /** Getter for property thisAction.
     * @return Value of property thisAction.
     *
     */
    public String getThisAction() {
        return this.thisAction;
    }
    
    /** Setter for property thisAction.
     * @param thisAction New value of property thisAction.
     *
     */
    public void setThisAction(String thisAction) {
        this.thisAction = thisAction;
        System.out.println("setthisAction: " + thisAction);
    }
    
    /** Getter for property optionNames.
     * @return Value of property optionNames.
     *
     */
    public String getOptionName() {
        return this.optionName;
    }
    
    /** Setter for property optionNames.
     * @param optionNames New value of property optionNames.
     *
     */
    public void setOptionName(String optionName) {
        this.optionName = optionName;
    }
    
    /** Getter for property optionValues.
     * @return Value of property optionValues.
     *
     */
    public String getOptionValue() {
        return this.optionValue;
    }
    
    /** Setter for property optionValues.
     * @param optionValues New value of property optionValues.
     *
     */
    public void setOptionValue(String optionValue) {
        this.optionValue = optionValue;
    }
    
}
