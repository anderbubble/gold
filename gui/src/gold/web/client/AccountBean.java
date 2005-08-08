/*
 * AccountBean.java
 *
 * Created on May 3, 2004, 11:00 AM
 */

package gold.web.client;


import gold.*;
import org.jdom.*;
import java.util.*;

/**
 *
 * @author  d3l028
 */
public class AccountBean {
    
    /**
     * Holds value of property accountProject.
     */
    private String accountProject;
    
    /**
     * Holds value of property accountUser.
     */
    private String accountUser;
    
    /**
     * Holds value of property accountMachine.
     */
    private String accountMachine;
    
    /**
     * Holds value of property accountProjectActive.
     */
    private String accountProjectActive;
    
    /**
     * Holds value of property accountProjectAllowDesc.
     */
    private String accountProjectAllowDesc;
    
    /**
     * Holds value of property accountUserActive.
     */
    private String accountUserActive;
    
    /**
     * Holds value of property accountMachineActive.
     */
    private String accountMachineActive;
    
    /**
     * Holds value of property endTime.
     */
    private String endTime;
    
    /**
     * Holds value of property activationTime.
     */
    private String activationTime;
    
    /**
     * Holds value of property type.
     */
    private String type;
    
    /**
     * Holds value of property creditLimit.
     */
    private String creditLimit;
    
    /**
     * Holds value of property description.
     */
    private String description;
    
    /**
     * Holds value of property amount.
     */
    private String amount;
    
    /**
     * Holds value of property fromIds.
     */
    private String fromIds;
    
    /**
     * Holds value of property toIds.
     */
    private String toIds;
    
    /**
     * Holds value of property fromUser.
     */
    private String fromUser;
    
    /**
     * Holds value of property fromProject.
     */
    private String fromProject;
    
    /**
     * Holds value of property fromMachine.
     */
    private String fromMachine;
    
    /**
     * Holds value of property toUser.
     */
    private String toUser;
    
    /**
     * Holds value of property toProject.
     */
    private String toProject;
    
    /**
     * Holds value of property toMachine.
     */
    private String toMachine;
    
    /** Creates a new instance of AccountBean */
    public AccountBean() {
    }
    
    /**
     * Getter for property accountProject.
     * @return Value of property accountProject.
     */
    public String getAccountProject() {
        return this.accountProject;
    }
    
    /**
     * Setter for property accountProject.
     * @param accountProject New value of property accountProject.
     */
    public void setAccountProject(String accountProject) {
        this.accountProject = accountProject;
    }
    
    /**
     * Getter for property accountUser.
     * @return Value of property accountUser.
     */
    public String getAccountUser() {
        return this.accountUser;
    }
    
    /**
     * Setter for property accountUser.
     * @param accountUser New value of property accountUser.
     */
    public void setAccountUser(String accountUser) {
        this.accountUser = accountUser;
    }
    
    /**
     * Getter for property accountMachine.
     * @return Value of property accountMachine.
     */
    public String getAccountMachine() {
        return this.accountMachine;
    }
    
    /**
     * Setter for property accountMachine.
     * @param accountMachine New value of property accountMachine.
     */
    public void setAccountMachine(String accountMachine) {
        this.accountMachine = accountMachine;
    }
    
    /**
     * Getter for property accountProjectActive.
     * @return Value of property accountProjectActive.
     */
    public String getAccountProjectActive() {
        return this.accountProjectActive;
    }
    
    /**
     * Setter for property accountProjectActive.
     * @param accountProjectActive New value of property accountProjectActive.
     */
    public void setAccountProjectActive(String accountProjectActive) {
        this.accountProjectActive = accountProjectActive;
    }
    
    /**
     * Getter for property accountProjectAllowDesc.
     * @return Value of property accountProjectAllowDesc.
     */
    public String getAccountProjectAllowDesc() {
        return this.accountProjectAllowDesc;
    }
    
    /**
     * Setter for property accountProjectAllowDesc.
     * @param accountProjectAllowDesc New value of property accountProjectAllowDesc.
     */
    public void setAccountProjectAllowDesc(String accountProjectAllowDesc) {
        this.accountProjectAllowDesc = accountProjectAllowDesc;
    }
    
    /**
     * Getter for property accountUserActive.
     * @return Value of property accountUserActive.
     */
    public String getAccountUserActive() {
        return this.accountUserActive;
    }
    
    /**
     * Setter for property accountUserActive.
     * @param accountUserActive New value of property accountUserActive.
     */
    public void setAccountUserActive(String accountUserActive) {
        this.accountUserActive = accountUserActive;
    }
    
    /**
     * Getter for property accountMachineActive.
     * @return Value of property accountMachineActive.
     */
    public String getAccountMachineActive() {
        return this.accountMachineActive;
    }
    
    /**
     * Setter for property accountMachineActive.
     * @param accountMachineActive New value of property accountMachineActive.
     */
    public void setAccountMachineActive(String accountMachineActive) {
        this.accountMachineActive = accountMachineActive;
    }
    
    /**
     * Getter for property endTime.
     * @return Value of property endTime.
     */
    public String getEndTime() {
        return this.endTime;
    }
    
    /**
     * Setter for property endTime.
     * @param endTime New value of property endTime.
     */
    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }
    
    /**
     * Getter for property activationTime.
     * @return Value of property activationTime.
     */
    public String getActivationTime() {
        return this.activationTime;
    }
    
    /**
     * Setter for property activationTime.
     * @param activationTime New value of property activationTime.
     */
    public void setActivationTime(String activationTime) {
        this.activationTime = activationTime;
    }
    
    /**
     * Getter for property type.
     * @return Value of property type.
     */
    public String getType() {
        return this.type;
    }
    
    /**
     * Setter for property type.
     * @param type New value of property type.
     */
    public void setType(String type) {
        this.type = type;
    }
    
    /**
     * Getter for property creditLimit.
     * @return Value of property creditLimit.
     */
    public String getCreditLimit() {
        return this.creditLimit;
    }
    
    /**
     * Setter for property creditLimit.
     * @param creditLimit New value of property creditLimit.
     */
    public void setCreditLimit(String creditLimit) {
        this.creditLimit = creditLimit;
    }
    
    /**
     * Getter for property description.
     * @return Value of property description.
     */
    public String getDescription() {
        return this.description;
    }
    
    /**
     * Setter for property description.
     * @param description New value of property description.
     */
    public void setDescription(String description) {
        this.description = description;
    }
    
    /**
     * Getter for property amount.
     * @return Value of property amount.
     */
    public String getAmount() {
        return this.amount;
    }
    
    /**
     * Setter for property amount.
     * @param amount New value of property amount.
     */
    public void setAmount(String amount) {
        this.amount = amount;
    }
    
    
    
    
    public String[] getAccountUserAsArray(){
        return accountUser.split(",");
    }
    
    public String[] getAccountUserActiveAsArray(){
        return accountUserActive.split(",");
    }
    
    public String[] getAccountProjectAsArray(){
        return accountProject.split(",");
    }
    
    public String[] getAccountProjectActiveAsArray(){
        return accountProjectActive.split(",");
    }
    
    public String[] getAccountProjectAllowDescAsArray(){
        return accountProjectAllowDesc.split(",");
    }
    
    public String[] getAccountMachineAsArray(){
        return accountMachine.split(",");
    }
    
    public String[] getAccountMachineActiveAsArray(){
        return accountMachineActive.split(",");
    }
    
    
    public String[] getFromIdsAsArray(){
        return fromIds.split(",");
    }
    
    public String[] getToIdsAsArray(){
        return toIds.split(",");
    }
    /*
      
      
      
    
    public String[] getAccountUserAsArray(){
        if(accountUser != null) return accountUser.split(",");
        return null;
    }
    
    public String[] getAccountUserActiveAsArray(){
        if(accountUserActive != null) return accountUserActive.split(",");
        return null;
    }
    
    public String[] getAccountProjectAsArray(){
        if(accountProject != null) return accountProject.split(",");
        return null;
    }
    
    public String[] getAccountProjectActiveAsArray(){
        if(accountProjectActive != null) return accountProjectActive.split(",");
        return null;
    }
    
    public String[] getAccountProjectAllowDescAsArray(){
        if(accountProjectAllowDesc != null) return accountProjectAllowDesc.split(",");
        return null;
    }
    
    public String[] getAccountMachineAsArray(){
        if(accountMachine != null) return accountMachine.split(",");
        return null;
    }
    
    public String[] getAccountMachineActiveAsArray(){
        if(accountMachineActive != null) return accountMachineActive.split(",");
        return null;
    }
    
    
    public String[] getFromIdsAsArray(){
        if(fromIds != null) return fromIds.split(",");
        return null;
    }
    
    public String[] getToIdsAsArray(){
        if(toIds != null) return toIds.split(",");
        return null;
    } 
      
     */
    
    /**
     * Getter for property toIds.
     * @return Value of property toIds.
     */
    public String getToIds() {
        return this.toIds;
    }
    
    /**
     * Setter for property toIds.
     * @param toIds New value of property toIds.
     */
    public void setToIds(String toIds) {
        this.toIds = toIds;
    }
    
    /**
     * Getter for property fromIds.
     * @return Value of property fromIds.
     */
    public String getFromIds() {
        return this.fromIds;
    }
    
    /**
     * Setter for property fromIds.
     * @param fromIds New value of property fromIds.
     */
    public void setFromIds(String fromIds) {
        this.fromIds = fromIds;
    }
    
    /**
     * Getter for property fromUser.
     * @return Value of property fromUser.
     */
    public String getFromUser() {
        return this.fromUser;
    }
    
    /**
     * Setter for property fromUser.
     * @param fromUser New value of property fromUser.
     */
    public void setFromUser(String fromUser) {
        this.fromUser = fromUser;
    }
    
    /**
     * Getter for property fromProject.
     * @return Value of property fromProject.
     */
    public String getFromProject() {
        return this.fromProject;
    }
    
    /**
     * Setter for property fromProject.
     * @param fromProject New value of property fromProject.
     */
    public void setFromProject(String fromProject) {
        this.fromProject = fromProject;
    }
    
    /**
     * Getter for property fromMachine.
     * @return Value of property fromMachine.
     */
    public String getFromMachine() {
        return this.fromMachine;
    }
    
    /**
     * Setter for property fromMachine.
     * @param fromMachine New value of property fromMachine.
     */
    public void setFromMachine(String fromMachine) {
        this.fromMachine = fromMachine;
    }
    
    /**
     * Getter for property toUser.
     * @return Value of property toUser.
     */
    public String getToUser() {
        return this.toUser;
    }
    
    /**
     * Setter for property toUser.
     * @param toUser New value of property toUser.
     */
    public void setToUser(String toUser) {
        this.toUser = toUser;
    }
    
    /**
     * Getter for property toProject.
     * @return Value of property toProject.
     */
    public String getToProject() {
        return this.toProject;
    }
    
    /**
     * Setter for property toProject.
     * @param toProject New value of property toProject.
     */
    public void setToProject(String toProject) {
        this.toProject = toProject;
    }
    
    /**
     * Getter for property toMachine.
     * @return Value of property toMachine.
     */
    public String getToMachine() {
        return this.toMachine;
    }
    
    /**
     * Setter for property toMachine.
     * @param toMachine New value of property toMachine.
     */
    public void setToMachine(String toMachine) {
        this.toMachine = toMachine;
    }

    public void createAccount(Request request){
        //request.setAssignment("Type", type);
        //request.setAssignment("Amount", amount);
        request.setAssignment("CreditLimit", creditLimit);
        //request.setAssignment("ActivationTime", activationTime);
        //request.setAssignment("EndTime", endTime);
        if(description != null) request.setAssignment("Description", description);
    }
    
    
    public void makeTransfer(Request request){
        request.setAction("Transfer");
        request.setObject("Account");
        request.setOption("Amount", amount);
        String[] ids;
        if(fromIds != null && getFromIdsAsArray().length > 0){
            ids = getFromIdsAsArray();
            for(int i = 0; i < ids.length; i++)
                request.setOption("FromId", ids[i]);
        }else{
            request.setOption("FromProject", fromProject);
            request.setOption("FromUser", fromUser);
            request.setOption("FromMachine", fromMachine);
        }
        if(toIds != null && getToIdsAsArray().length > 0){
            ids = getToIdsAsArray();
            for(int i = 0; i < ids.length; i++)
                request.setOption("ToId", ids[i]);
        }else{
            request.setOption("ToProject", toProject);
            request.setOption("ToUser", toUser);
            request.setOption("ToMachine", toMachine);
        }
    }
    
    //user defined methods:
    public String toString() {
        return "\ntype: " + type + "\n" +
               "amount: " + amount + "\n"+
               "creditLimit: " + creditLimit  + "\n"+
               "activationTime: " + activationTime + "\n" +
               "endTime: " + endTime  + "\n"+
               "description: " + description  + "\n"+
               "accountUsers: " +accountUser  + "\n"+
               "accountUsersActive: " + accountUserActive  + "\n"+
               "accountProject: " + accountProject  + "\n" +
               "accountProjectActive: " + accountProjectActive  + "\n"+
               "accountProjectAllowDesc: " + accountProjectAllowDesc  + "\n"+
               "accountMachine: " + accountMachine  + "\n"+
               "accountMachineActive: " + accountMachineActive  + "\n\n"+
               "fromIds: " + fromIds + "\n"+
               "fromMachine: " + fromMachine + "\n"+
               "fromProject: " + fromProject + "\n"+
               "fromUser: " + fromUser + "\n"+
               "toIds: " + toIds + "\n"+
               "toMachine: " + toMachine + "\n"+
               "toProject: " + toProject + "\n"+
               "toUser: " + toUser + "\n";
    }
 
}
