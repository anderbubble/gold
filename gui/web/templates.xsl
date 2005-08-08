<?xml version="1.0" encoding="UTF-8" ?>

<!--
    Document   : templates.xsl
    Created on : September 2003
    Author     : zjohns, Geoff Elliott
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xhtml" indent = "yes"/>

<xsl:template name="Header">
    <xsl:param name = "myaction" select="//myaction"/>
    <xsl:param name = "myobject" select="//myobject"/>
    <div class="header">
        <div class="leftFlare"><img src="images/header_flare_left.gif" width="16" height="36" alt="" /></div>
        <div class="rightFlare"><img src="images/header_flare_right.gif" width="16" height="36" alt="" /></div>
        <h1><xsl:value-of select="$myaction"/><xsl:text> </xsl:text><xsl:value-of select="$myobject"/>(s)</h1>
    </div>
</xsl:template>



<xsl:template match="DataType" >
    <xsl:choose >
        <xsl:when test = "../Select" >
            <xsl:apply-templates select="../Select"/>
        </xsl:when>
        <xsl:when test = ".='Boolean'" >
            <xsl:apply-templates select="." mode="radio"/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates select="." mode="input"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>



<xsl:template match="DataType" mode = "input" >
  <xsl:variable name = "fixed">
      <xsl:choose>
        <xsl:when test="//myaction='Modify'"><xsl:value-of select="../Fixed"/></xsl:when>
        <xsl:otherwise>f</xsl:otherwise>
      </xsl:choose>
  </xsl:variable>


  <xsl:choose>
      <xsl:when test="$fixed='True'">
        <input type="text" name="{../Name}" id="{../Name}" value="{../DefaultValue}" size="30"  disabled="y" />
      </xsl:when>
      <xsl:otherwise>
        <input type="text" name="{../Name}" id="{../Name}" value="{../DefaultValue}" size="30"  />
      </xsl:otherwise>
  </xsl:choose>
</xsl:template>



<xsl:template match="DataType" mode = "radio" >
<xsl:if test="../DefaultValue='True'" >
    <input type="radio" name="{../Name}" id="{../Name}Yes" value="True" checked="true" /> <label for="{../Name}Yes">Yes</label>
    <input type="radio" name="{../Name}" id="{../Name}No" value="False" /> <label for="{../Name}No">No</label>
</xsl:if>
<xsl:if test="../DefaultValue='False'" >
    <input type="radio" name="{../Name}" id="{../Name}Yes" value="True" /> <label for="{../Name}Yes">Yes</label>
    <input type="radio" name="{../Name}" id="{../Name}No" value="False" checked="true" /> <label for="{../Name}No">No</label>
</xsl:if>
</xsl:template>



<xsl:template match="Select" >
<select name="{../Name}" id="{../Name}">
    <xsl:for-each select="./Option">
        <xsl:copy-of select = "." />
    </xsl:for-each>
</select>
</xsl:template>



<xsl:template match="Description" >
    <xsl:choose>
        <xsl:when test="../DataType='Boolean'">
            <strong class="rowLabel"><xsl:call-template name="PrimaryKey"/><xsl:call-template name="RequiredField"/><xsl:value-of select="."/></strong>
        </xsl:when>
        <xsl:otherwise>
            <label for="{../Name}" class="rowLabel"><xsl:call-template name="PrimaryKey"/><xsl:call-template name="RequiredField"/><xsl:value-of select="."/>:</label>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>



<xsl:template name="PrimaryKey">
    <xsl:if test="../PrimaryKey='True'">
        <img src="images/primary_key.gif" width="14" height="9" class="primaryKey" alt="Primary Key" />
    </xsl:if>
</xsl:template>



<xsl:template name="RequiredField" >
    <xsl:if test="../Required='True' and //myaction != 'Modify'">
        <span class="required">*</span>
    </xsl:if>
</xsl:template>



<xsl:template name="SubmitRow">
    <xsl:param name = "myaction" select="//myaction"/>
    <xsl:param name = "myobject" select="//myobject"/>
    <hr />
    <div id="submitRow">
        <input type="button" name="create" id="formSubmit" value="{$myaction} {$myobject}(s)" onClick="submitForm()" />
    </div>
</xsl:template>



<xsl:template match ="Attribute">
    <div class="row">
        <xsl:apply-templates select="Description"/>
        <xsl:apply-templates select="DataType"/>
    </div>
</xsl:template>








<xsl:template name="NameSelect">
    <xsl:param name="onchange" />
    <xsl:param name="disabled">false</xsl:param>
    <xsl:param name="exclude_special" select="true()" />
    <div class="multiSelect" id="{name(./*[1])}MultiSelect">
    <label for="{name(./*[1])}"><xsl:value-of select="name(./*[1])"/>s</label>
    <!--possilbe to have onchange="changeActivationTable('{name(./*[1])}'); setProjectMembers('{name(./*[1])}');" -->
    <select name="{name(./*[1])}" id="{name(./*[1])}" size="10" multiple="yes"><!--this gets the current node's (.) (which will be a <Data> tag) first node (*[1]) and outputs the name of that node (ie User, Project, or Machine)-->
    <xsl:attribute name="onchange">
    <xsl:if test="$onchange != ''"><xsl:value-of select="$onchange"/></xsl:if>
    </xsl:attribute>
    <xsl:if test="$disabled = 'true'"><xsl:attribute name="disabled">true</xsl:attribute></xsl:if>
        <xsl:if test="count(./*)>0 and ./*[1]/Special">
            <xsl:if test="$exclude_special = false()">
            <xsl:for-each select="./child::*"><!--loops thru all of the current node's (.) children (child::*) -->
                <xsl:sort select = "./Name" />
                <xsl:if test="./Special='True'"><!-- this test if the current node's value of the child node "Special" has a value of f-->
                    <option value="{./Name}"><xsl:value-of select="./Name"/></option>
                </xsl:if>
            </xsl:for-each>
            </xsl:if>
            <xsl:for-each select="./child::*"><!--loops thru all of the current node's (.) children (child::*) -->
                <xsl:sort select = "./Name" />
                <xsl:if test="./Special='False'"><!-- this test if the current node's value of the child node "Special" has a value of f-->
                    <option value="{./Name}"><xsl:value-of select="./Name"/></option>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
        <xsl:if test="count(./*)>0 and not(./*[1]/Special)">
        <!-- if it dosn't even have a Special attribute, list them all-->
            <xsl:for-each select="./child::*">
                <option value="{./Name}"><xsl:value-of select="./Name"/></option>
            </xsl:for-each>
        </xsl:if>
        <xsl:if test="count(./*)=0">
        <!-- if we don't have any, put in a blank option so that the GUI doesn't get screwd up -->
            <option value=""></option>
        </xsl:if>
        <!-- if we only have one, but it doesn't have a Name tag under it, can't use so put in a blank option-->
        <xsl:if test="count(./*)=1 and not(./*[1]/Name)">
            <option value=""></option>
        </xsl:if>
    </select>
    </div>
</xsl:template>



<xsl:template name="NameRadio">
    <xsl:param name="object">Project</xsl:param>
    <xsl:param name="displayName"><xsl:value-of select="name(./*[1])"/></xsl:param>
    <div class="headRow">
        <div class="primaryKeyActivation"><xsl:value-of select="$displayName"/></div>
        <xsl:if test="$object = 'Project'">
            <div class="active">Inactive</div>
            <xsl:if test="name(./*[1]) = 'User'">
                <div class="active">Admin</div>
            </xsl:if>
        </xsl:if>
        <xsl:if test="$object = 'Account' or $object = 'DepositShare'">
            <div class="active">Denied</div>
            
        </xsl:if>
    </div>
    <xsl:if test="count(./*)>0">
    <xsl:for-each select="./child::*">
        <xsl:sort select = "./Special" order="descending"/>
        <xsl:sort select = "./Name"/>
        <!-- this test if the current node's value of the child node "Special" has a value of f-->
        <xsl:if test="./Name">
        <div class="activationRow" id="{./Name}{name(../*[1])}ActivationRow">
            <div class="primaryKeyActivation"><xsl:value-of select="./Name"/></div>
            <div class="active"><input type="checkbox" name="{./Name}{name(../*[1])}Active" id="{./Name}{name(../*[1])}Active"              onchange="setMembers('{name(../*[1])}', '{$object}');"/></div>
            <!--xsl:if test="($object = 'Account') and (name(../*[1]) = 'Project')">
                <div class="active"><input type="checkbox" name="{./Name}{name(../*[1])}AllowDesc" id="{./Name}{name(../*[1])}AllowDesc" onchange="setMembers('{name(../*[1])}','{$object}');"/></div>
            </xsl:if-->
            <xsl:if test="($object = 'Project') and (name(../*[1]) = 'User')">
                <div class="active"><input type="checkbox" name="{./Name}{name(../*[1])}Admin" id="{./Name}{name(../*[1])}Admin" onchange="setMembers('{name(../*[1])}','{$object}');"/></div>
            </xsl:if>
        </div>
        </xsl:if>
    </xsl:for-each>
    </xsl:if>
</xsl:template>




<xsl:template name="SpecialValueRadios">
    <xsl:for-each select="./child::*"><!--this loops thru all of the the current node's children (which should be all children of a <Data> tag like <User> or <Machine> )-->
        <xsl:if test="./Special='True'"><!--this test if the current node's value of the child node "Special" has a value of t-->
            <input type="radio" name="{name(.)}" id="{name(.)}{./Name}" value="{./Name}" onclick="check{name(.)}(this.name, this.id)"/> <label for="{name(.)}{./Name}"><xsl:value-of select="./Description"/></label><br/>
        </xsl:if>
    </xsl:for-each>
    <input type="radio" name="{name(./*[1])}" id="specific{name(./*[1])}" value="specific{name(./*[1])}" onclick="check{name(./*[1])}(this.name, this.id)"/> <label for="specific{name(./*[1])}">Specific <xsl:value-of select="name(./*[1])"/>s</label><br/>
    <!--name(./*[1]) gets the current node's (which should be <data>) first child and returns the name of it (so it would return either 'User', 'Mcahine', or 'Project' -->
</xsl:template>




<xsl:template name="RequiredDescription">
    <p id="requiredDesc">Fields marked with a red asterisk (<span class="required">*</span>) are required.</p>
</xsl:template>

<xsl:template name="PrimaryKeyDescription">
    <p id="primaryKeyDesc">Primary key fields are marked with a key icon (<img src="images/primary_key.gif" width="14" height="9" class="primaryKey" alt="Primary Key" />)</p>
</xsl:template>



<xsl:template name="NameCombo">
    <xsl:param name="disabled">false</xsl:param>
    <xsl:param name="onclick" />
    <xsl:param name="required" />
    <xsl:param name="name"><xsl:value-of  select="name(./*[1])" /></xsl:param>
    <div class="multiSelect" id="{name(./*[1])}MultiSelect">
    <label for="{$name}" class="rowLabel">
    <xsl:if test="string-length($required) != 0">
    <span class="required">*</span>
    </xsl:if>
    <xsl:value-of select="name(./*[1])"/>s:
    </label>
    <select name="{$name}" id="{$name}" >
    <xsl:attribute name="onclick"><xsl:value-of select="$onclick" /></xsl:attribute>
    <xsl:if test="$disabled = 'true'">
    <xsl:attribute name="disabled"><xsl:value-of select="$disabled" /></xsl:attribute>
    </xsl:if>
    <xsl:if test="count(./*)>0">
        <!-- first list the special ones-->
        <xsl:for-each select="./child::*">
            <xsl:sort select = "./Name" />
            <xsl:if test="./Name != '' and ./Name != ' ' and ./Special = 'True'">
                <option value="{./Name}">
                <xsl:if test="./Name = 'ANY'">
                <xsl:attribute name="selected">true</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="./Name"/></option>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="./child::*">
            <xsl:sort select = "./Name" />
            <xsl:if test="./Name != '' and ./Name != ' ' and ./Special = 'False'">
                <option value="{./Name}"><xsl:value-of select="./Name"/></option>
            </xsl:if>
        </xsl:for-each>
    </xsl:if>
    </select>
    </div>
</xsl:template>












    <xsl:template name="lf2br">
        <!-- import $StringToTransform -->
    <xsl:param name="StringToTransform"/>
    <xsl:choose>
            <!-- string contains linefeed -->
            <xsl:when test="contains($StringToTransform,'&#xA;')">
                <!-- output substring that comes before the first linefeed -->
        <!-- note: use of substring-before() function means        -->
        <!-- $StringToTransform will be treated as a string,       -->
        <!-- even if it is a node-set or result tree fragment.     -->
        <!-- So hopefully $StringToTransform is really a string!   -->
        <xsl:value-of select="substring-before($StringToTransform,'&#xA;')"/>
        <!-- by putting a 'br' element in the result tree instead  -->
        <!-- of the linefeed character, a <br> will be output at   -->
                <!-- that point in the HTML                                -->
        <br />
        <!-- repeat for the remainder of the original string -->
        <xsl:call-template name="lf2br">
                    <xsl:with-param name="StringToTransform">
                    <xsl:value-of select="substring-after($StringToTransform,'&#xA;')"/>
                    </xsl:with-param>
        </xsl:call-template>
            </xsl:when>
            <!-- string does not contain newline, so just output it -->
            <xsl:otherwise>
                <xsl:value-of select="$StringToTransform"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    
    
<xsl:template name="SpecialValueCheckboxes">
    <xsl:param name="use_defaults" select="false()"/>
    <xsl:param name="displayname" select="name(./*[1])"/>
    <input type="checkbox" name="{name(./*[1])}Radio" id="{name(./*[1])}ANY" value="ANY" onclick="changeActivationTable('{name(./*[1])}'); setMembers('{name(./*[1])}', '{//myobject}');">
    <xsl:if test="$use_defaults = true() and name(./*[1]) = 'Machine'"><xsl:attribute name='checked'>true</xsl:attribute></xsl:if>
    </input>
    <label for="{name(./*[1])}ANY"> Any </label><br />
    
    <xsl:if test="name(./*[1]) != 'Project'">
    <input type="checkbox" name="{name(./*[1])}Radio" id="{name(./*[1])}MEMBERS" value="MEMBERS" onclick="changeActivationTable('{name(./*[1])}'); setMembers('{name(./*[1])}', '{//myobject}');">
    <xsl:if test="$use_defaults = true() and name(./*[1]) = 'User'"><xsl:attribute name='checked'>true</xsl:attribute></xsl:if>
    </input>
    <label for="{name(./*[1])}MEMBERS"> Member </label><br />
    </xsl:if>
    
    <input type="checkbox" name="{name(./*[1])}Radio" id="{name(./*[1])}SPECIFIC" value="{name(./*[1])}SPECIFIC" onclick="toggleSelect('{name(./*[1])}')">
    <xsl:if test="$use_defaults = true() and name(./*[1]) = 'Project'"><xsl:attribute name='checked'>true</xsl:attribute></xsl:if>
    </input>
    <label for="{name(./*[1])}SPECIFIC"> Specific <xsl:value-of select="$displayname"/>s</label><br />
    <br />
</xsl:template>



</xsl:stylesheet>