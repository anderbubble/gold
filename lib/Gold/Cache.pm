#! /usr/bin/perl -wT
################################################################################
#
# Gold Cache object
#
# File   :  Cache.pm
# History:  27 JUL 2004 [Scott Jackson] perl alpha
#           25 OCT 2004 [Scott Jackson] beta mods
#
################################################################################
#                                                                              #
#                              Copyright (c) 2004                              #
#                  Pacific Northwest National Laboratory,                      #
#                         Battelle Memorial Institute.                         #
#                             All rights reserved.                             #
#                                                                              #
################################################################################
#                                                                              #
#     Redistribution and use in source and binary forms, with or without       #
#     modification, are permitted provided that the following conditions       #
#     are met:                                                                 #
#                                                                              #
#     · Redistributions of source code must retain the above copyright         #
#     notice, this list of conditions and the following disclaimer.            #
#                                                                              #
#     · Redistributions in binary form must reproduce the above copyright      #
#     notice, this list of conditions and the following disclaimer in the      #
#     documentation and/or other materials provided with the distribution.     #
#                                                                              #
#     · Neither the name of Battelle nor the names of its contributors         #
#     may be used to endorse or promote products derived from this software    #
#     without specific prior written permission.                               #
#                                                                              #
#     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS      #
#     "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT        #
#     LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS        #
#     FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE           #
#     COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,      #
#     INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,     #
#     BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;         #
#     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER         #
#     CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT       #
#     LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN        #
#     ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE          #
#     POSSIBILITY OF SUCH DAMAGE.                                              #
#                                                                              #
################################################################################
use strict;

=head1 NAME

Gold::Cache - an object metadata cache for quick object property checks

=head1 DESCRIPTION

The B<Gold::Cache> module acts as a metadata cache for properties of objects, actions, attributes, values, roles, passwords and other core objects needed for quick lookups. When any of the cached info is updated, the cache is marked as stale and repopulated from the database. This is a static class.

=head1 ACCESSORS

=over 4

=item $boolean = Gold::Cache->getStale();

=back

=head1 MUTATORS

=over 4

=item Gold::Cache->setStale($boolean);

=back

=head1 OTHER METHODS

=over 4

=item Gold::Cache->populate($database);

=item $boolean = Gold::Cache->objectExists($object)

=item $object = Gold::Cache->associationLookup($parent,$child)

=item @objects = Gold::Cache->listObjects()

=item $value = Gold::Cache->getObjectProperty($object, $property)

=item $boolean = Gold::Cache->attributeExists($object, $attribute)

=item @attributes = Gold::Cache->listAttributes($object)

=item $value = Gold::Cache->getAttributeProperty($object, $attribute, $property)

=item $boolean = Gold::Cache->actionExists($object, $action)

=item @actions = Gold::Cache->listActions($object)

=item $value = Gold::Cache->getActionProperty($object, $action, $property)

=item $boolean = Gold::Cache->roleExists($role)

=item @roles = Gold::Cache->listRoles()

=item $value = Gold::Cache->getRoleProperty($role, $property)

=item $boolean = Gold::Cache->roleActionExists($role, $object, $action, $instance)

=item @roleActions = Gold::Cache->listRoleActions($role, $object, $instance)

=item @roleActionInstances = Gold::Cache->listRoleActionInstances($role, $object, $action, $instance)

=item $value = Gold::Cache->getRoleActionProperty($role, $object, $action, $instance, $property)

=item $boolean = Gold::Cache->roleUserExists($role, $user)

=item @roleUsers = Gold::Cache->listRoleUsers($role)

=item @userRoles = Gold::Cache->listUserRoles($user)

=item $value = Gold::Cache->getRoleUserProperty($role, $user, $property)

=item $boolean = Gold::Cache->passwordExists($password)

=item @passwords = Gold::Cache->listPasswords()

=item $value = Gold::Cache->getPasswordProperty($password, $property)

=item Gold::Cache->toString();

=back

=head1 EXAMPLES

use Gold::Cache;

Gold::Cache->populate($database);

=head1 REQUIRES

Perl 5.6

=head1 AUTHOR

Scott Jackson, Scott.Jackson@pnl.gov

=cut

##############################################################################

package Gold::Cache;

use vars qw($log);
use Data::Properties;
use Error qw(:try);
use Gold::Database;
use Gold::Exception;
use Gold::Global;
use XML::LibXML;

# ----------------------------------------------------------------------------
# Static Variables
# ----------------------------------------------------------------------------

my $_stale = 1;
my $_doc;

# ----------------------------------------------------------------------------
# Accessors
# ----------------------------------------------------------------------------

# Get whether the cache is stale
sub getStale
{
  my ($class) = @_;
  return $_stale;
}

# ----------------------------------------------------------------------------
# Mutators
# ----------------------------------------------------------------------------

# Set whether the cache is stale
sub setStale
{
  my ($class, $stale) = @_;
  $_stale = $stale;
}

# ----------------------------------------------------------------------------
# $string = toString()
# ----------------------------------------------------------------------------

# Serialize message to printable string
sub toString
{ 
  my ($class) = @_;
    
  my $string = "[";
    
  $string .= $_stale;
  $string .= ", ";

  $string .= $_doc->toString() if defined $_doc;

  $string .= "]";

  return $string;
}

# ----------------------------------------------------------------------------
# populate($database)
# ----------------------------------------------------------------------------

# Populates the metadata cache
# It should be passed a database object
sub populate
{
  my ($class, $database) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  # Try to obtain a database handle if we don't already have one
  unless ($database)
  {
    try
    {
      $database = new Gold::Database();
    }
    catch Error with
    {
      throw Gold::Exception("730", "Cache population failed obtaining database handle: " . $_[0]);
    };
  }

  try
  {
    # Instantiate Cache
    $_doc = XML::LibXML::Document->new("1.0", "UTF-8");
    my $cache = $_doc->createElement("Cache");
    $_doc->setDocumentElement($cache);
    
    # Define Objects
    my $objects = $_doc->createElement("Objects");
    $cache->appendChild($objects);
  
    # Populate Objects
  
    # Select objects from database
    my $objectResults = $database->select(object => "Object");
    my $objectCols = $objectResults->{cols};
  
    # Iterate over all objects in database
    foreach my $objectRow (@{$objectResults->{data}})
    {
      my $objectName = $objectRow->[0];
  
      # Create a new object node
      my $object = $_doc->createElement($objectName);
  
      # Populate the object's intrinsic properties
      for (my $i = 0; $i <= $objectCols; $i++)
      {
        my $property = $objectRow->[$i];
        if (defined $property)
        {
          $object->setAttribute($objectResults->{names}->[$i], $property);
        }
      }
  
      # Define attributes for this object
  
      my $attributes = $_doc->createElement("Attributes");
      $object->appendChild($attributes);
  
      # Populate Attributes
      
      # Select attributes for this object from database
      my $attributeResults = $database->select(object => "Attribute", conditions => [ new Gold::Condition(name => "Object", value => $objectName) ], options => [ new Gold::Option(name => "SortBySequence", value => "True") ]);
      my $attributeCols = $attributeResults->{cols};
  
      # Iterate over all attributes for this object in database
  	  foreach my $attributeRow (@{$attributeResults->{data}})
  	  {
  	    my $attributeName = $attributeRow->[1];
  	
  	    # Create a new attribute node
  	    my $attribute = $_doc->createElement($attributeName);
  	
  	    # Populate the attribute's intrinsic properties
  	    for (my $i = 0; $i <= $attributeCols; $i++)
  	    {
  	      my $property = $attributeRow->[$i];
  	      if (defined $property)
  	      {
  	        $attribute->setAttribute($attributeResults->{names}->[$i], $property);
  	      }
  	    }
  	
  	    # Add the attribute to the object
  	    $attributes->appendChild($attribute);
  	  }
  	
      # Define actions for this object
  
      my $actions = $_doc->createElement("Actions");
      $object->appendChild($actions);
  
      # Populate Actions
      
      # Select actions for this object from database
      my $actionResults = $database->select(object => "Action", conditions => [ new Gold::Condition(name => "Object", value => $objectName) ]);
      my $actionCols = $actionResults->{cols};
  
      # Iterate over all actions for this object in database
  	  foreach my $actionRow (@{$actionResults->{data}})
  	  {
  	    my $actionName = $actionRow->[1];
  	
  	    # Create a new action node
  	    my $action = $_doc->createElement($actionName);
  	
  	    # Populate the action's intrinsic properties
  	    for (my $i = 0; $i <= $actionCols; $i++)
  	    {
  	      my $property = $actionRow->[$i];
  	      if (defined $property)
  	      {
  	        $action->setAttribute($actionResults->{names}->[$i], $property);
  	      }
  	    }
  	
  	    # Add the action to the object
  	    $actions->appendChild($action);
  	  }
  
      # Add the object to the cache
      $objects->appendChild($object);
    }
  
    # Define Roles
    my $roles = $_doc->createElement("Roles");
    $cache->appendChild($roles);
  
    # Populate Roles
  
    # Select roles from database
    my $roleResults = $database->select(object => "Role");
    my $roleCols = $roleResults->{cols};
  
    # Iterate over all roles in database
    foreach my $roleRow (@{$roleResults->{data}})
    {
      my $roleName = $roleRow->[0];
  
      # Create a new role node
      my $role = $_doc->createElement($roleName);
  
      # Populate the role's intrinsic properties
      for (my $i = 0; $i <= $roleCols; $i++)
      {
        my $property = $roleRow->[$i];
        if (defined $property)
        {
          $role->setAttribute($roleResults->{names}->[$i], $property);
        }
      }
  
      # Define role actions for this role
  
      my $roleActions = $_doc->createElement("RoleActions");
      $role->appendChild($roleActions);
  
      # Populate Role Actions
      
      # Select role actions for this role from database
      my $roleActionResults = $database->select(object => "RoleAction", conditions => [ new Gold::Condition(name => "Role", value => $roleName) ]);
      my $roleActionCols = $roleActionResults->{cols};
  
      # Iterate over all role actions for this role in database
  	  foreach my $roleActionRow (@{$roleActionResults->{data}})
  	  {
  	    my $roleObjectName = $roleActionRow->[1];
  	    my $roleActionName = $roleActionRow->[2];
  	
  	    # Create a new role action node
  	    my $roleAction = $_doc->createElement($roleObjectName . $roleActionName);
  	
  	    # Populate the role action's intrinsic properties
  	    for (my $i = 0; $i <= $roleActionCols; $i++)
  	    {
  	      my $property = $roleActionRow->[$i];
  	      if (defined $property)
  	      {
  	        $roleAction->setAttribute($roleActionResults->{names}->[$i], $property);
  	      }
  	    }
  	
  	    # Add the role action to the role
  	    $roleActions->appendChild($roleAction);
  	  }
  
      # Define role users for this role
  
      my $roleUsers = $_doc->createElement("RoleUsers");
      $role->appendChild($roleUsers);
  
      # Populate Role Users
      
      # Select role users for this role from database
      my $roleUserResults = $database->select(object => "RoleUser", conditions => [ new Gold::Condition(name => "Role", value => $roleName) ]);
      my $roleUserCols = $roleUserResults->{cols};
  
      # Iterate over all role users for this role in database
  	  foreach my $roleUserRow (@{$roleUserResults->{data}})
  	  {
  	    my $roleUserName = $roleUserRow->[1];
  	
  	    # Create a new role user node
  	    my $roleUser = $_doc->createElement($roleUserName);
  	
  	    # Populate the role user's intrinsic properties
  	    for (my $i = 0; $i <= $roleUserCols; $i++)
  	    {
  	      my $property = $roleUserRow->[$i];
  	      if (defined $property)
  	      {
  	        $roleUser->setAttribute($roleUserResults->{names}->[$i], $property);
  	      }
  	    }
  	
  	    # Add the role user to the role
  	    $roleUsers->appendChild($roleUser);
  	  }
  
      # Add the role to the cache
      $roles->appendChild($role);
    }
  
    # Define Passwords
    my $passwords = $_doc->createElement("Passwords");
    $cache->appendChild($passwords);
  
    # Populate Passwords
  
    # Select passwords from database
    my $passwordResults = $database->select(object => "Password");
    my $passwordCols = $passwordResults->{cols};
  
    # Iterate over all passwords in database
    foreach my $passwordRow (@{$passwordResults->{data}})
    {
      my $passwordName = $passwordRow->[0];
  
      # Create a new password node
      my $password = $_doc->createElement($passwordName);
  
      # Populate the password's intrinsic properties
      for (my $i = 0; $i <= $passwordCols; $i++)
      {
        my $property = $passwordRow->[$i];
        if (defined $property)
        {
          $password->setAttribute($passwordResults->{names}->[$i], $property);
        }
      }
  
      # Add the password to the cache
      $passwords->appendChild($password);
    }
  }
  catch Error with
  {
    throw Gold::Exception("720", "Exception caught while populating metadata cache: " . $_[0]);
  };

  # Mark metadata as no longer stale
  $_stale = 0;
  
  # Log Cache DOM
  if ($log->is_debug())
  {
    $log->debug("Cache DOM:\n" . $_doc->toString());
  }
}

# ----------------------------------------------------------------------------
# $boolean = objectExists($object)
# ----------------------------------------------------------------------------

# Check if Object Exists
sub objectExists
{
  my ($class, $object) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @objectsNodes = $_doc->getElementsByTagName("Objects");
  return $objectsNodes[0]->getChildrenByTagName($object) ? 1 : 0;
}

# ----------------------------------------------------------------------------
# $object = associationLookup($parent,$child)
# ----------------------------------------------------------------------------

# Perform Association Lookup
sub associationLookup
{
  my ($class, $parent, $child) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @objectsNodes = $_doc->getElementsByTagName("Objects");
  foreach my $objectNode ($objectsNodes[0]->childNodes())
  {
    my $association = $objectNode->getAttribute("Association");
    my $parentAttr = $objectNode->getAttribute("Parent");
    my $childAttr = $objectNode->getAttribute("Child");
    if (defined $association && $association eq "True" && defined $parentAttr && $parentAttr eq $parent && defined $childAttr && $childAttr eq $child)
    {
      return $objectNode->nodeName();
    }
  }
  return;
}

# ----------------------------------------------------------------------------
# @objects = listObjects()
# ----------------------------------------------------------------------------

# List Objects
sub listObjects
{
  my ($class) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @objectList = ();
  my @objectsNodes = $_doc->getElementsByTagName("Objects");
  foreach my $objectNode ($objectsNodes[0]->childNodes())
  {
    push (@objectList, $objectNode->nodeName());
  }
  return @objectList;
}

# ----------------------------------------------------------------------------
# $value = getObjectProperty($object, $property)
# ----------------------------------------------------------------------------

# Get Object Property
sub getObjectProperty
{
  my ($class, $object, $property) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @objectsNodes = $_doc->getElementsByTagName("Objects");
  my @objectNodes = $objectsNodes[0]->getChildrenByTagName($object);
  if (@objectNodes)
  {
    return $objectNodes[0]->getAttribute($property);
  }
  return;
}

# ----------------------------------------------------------------------------
# $boolean = attributeExists($object, $attribute)
# ----------------------------------------------------------------------------

# Check if Attribute Exists
sub attributeExists
{
  my ($class, $object, $attribute) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @objectsNodes = $_doc->getElementsByTagName("Objects");
  my @objectNodes = $objectsNodes[0]->getChildrenByTagName($object);
  if (@objectNodes)
  {
    my @attributesNodes = $objectNodes[0]->getChildrenByTagName("Attributes");
    return $attributesNodes[0]->getChildrenByTagName($attribute) ? 1 : 0;
  }
  else
  {
    return 0;
  }
}

# ----------------------------------------------------------------------------
# @attributes = listAttributes($object)
# ----------------------------------------------------------------------------

# List Attributes
sub listAttributes
{
  my ($class, $object) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @attributeList = ();
  my @objectsNodes = $_doc->getElementsByTagName("Objects");
  my @objectNodes = $objectsNodes[0]->getChildrenByTagName($object);
  if (@objectNodes)
  {
    my @attributesNodes = $objectNodes[0]->getChildrenByTagName("Attributes");
    foreach my $attributeNode ($attributesNodes[0]->childNodes())
    {
      push (@attributeList, $attributeNode->nodeName());
    }
  }
  return @attributeList;
}

# ----------------------------------------------------------------------------
# $value = getAttributeProperty($object, $attribute, $property)
# ----------------------------------------------------------------------------

# Get Attribute Property
sub getAttributeProperty
{
  my ($class, $object, $attribute, $property) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @objectsNodes = $_doc->getElementsByTagName("Objects");
  my @objectNodes = $objectsNodes[0]->getChildrenByTagName($object);
  if (@objectNodes)
  {
    my @attributesNodes = $objectNodes[0]->getChildrenByTagName("Attributes");
    my @attributeNodes = $attributesNodes[0]->getChildrenByTagName($attribute);
    if (@attributeNodes)
    {
      return $attributeNodes[0]->getAttribute($property);
    }
  }
  return;
}

# ----------------------------------------------------------------------------
# $boolean = actionExists($object, $action)
# ----------------------------------------------------------------------------

# Check if Action Exists
sub actionExists
{
  my ($class, $object, $action) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @objectsNodes = $_doc->getElementsByTagName("Objects");
  my @objectNodes = $objectsNodes[0]->getChildrenByTagName($object);
  if (@objectNodes)
  {
    my @actionsNodes = $objectNodes[0]->getChildrenByTagName("Actions");
    return $actionsNodes[0]->getChildrenByTagName($action) ? 1 : 0;
  }
  else
  {
    return 0;
  }
}

# ----------------------------------------------------------------------------
# @actions = listActions($object)
# ----------------------------------------------------------------------------

# List Actions
sub listActions
{
  my ($class, $object) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @actionList = ();
  my @objectsNodes = $_doc->getElementsByTagName("Objects");
  my @objectNodes = $objectsNodes[0]->getChildrenByTagName($object);
  if (@objectNodes)
  {
    my @actionsNodes = $objectNodes[0]->getChildrenByTagName("Actions");
    foreach my $actionNode ($actionsNodes[0]->childNodes())
    {
      push (@actionList, $actionNode->nodeName());
    }
  }
  return @actionList;
}

# ----------------------------------------------------------------------------
# $value = getActionProperty($object, $action, $property)
# ----------------------------------------------------------------------------

# Get Action Property
sub getActionProperty
{
  my ($class, $object, $action, $property) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @objectsNodes = $_doc->getElementsByTagName("Objects");
  my @objectNodes = $objectsNodes[0]->getChildrenByTagName($object);
  if (@objectNodes)
  {
    my @actionsNodes = $objectNodes[0]->getChildrenByTagName("Actions");
    my @actionNodes = $actionsNodes[0]->getChildrenByTagName($action);
    if (@actionNodes)
    {
      return $actionNodes[0]->getAction($property);
    }
  }
  return;
}

# ----------------------------------------------------------------------------
# $boolean = roleExists($role)
# ----------------------------------------------------------------------------

# Check if Role Exists
sub roleExists
{
  my ($class, $role) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @rolesNodes = $_doc->getElementsByTagName("Roles");
  return $rolesNodes[0]->getChildrenByTagName($role) ? 1 : 0;
}

# ----------------------------------------------------------------------------
# @roles = listRoles()
# ----------------------------------------------------------------------------

# List Roles
sub listRoles
{
  my ($class) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @roleList = ();
  my @rolesNodes = $_doc->getElementsByTagName("Roles");
  foreach my $roleNode ($rolesNodes[0]->childNodes())
  {
    push (@roleList, $roleNode->nodeName());
  }
  return @roleList;
}

# ----------------------------------------------------------------------------
# $value = getRoleProperty($role, $property)
# ----------------------------------------------------------------------------

# Get Role Property
sub getRoleProperty
{
  my ($class, $role, $property) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @rolesNodes = $_doc->getElementsByTagName("Roles");
  my @roleNodes = $rolesNodes[0]->getChildrenByTagName($role);
  if (@roleNodes)
  {
    return $roleNodes[0]->getAttribute($property);
  }
  return;
}

# ----------------------------------------------------------------------------
# $boolean = roleActionExists($role, $object, $action, $instance)
# ----------------------------------------------------------------------------

# Check if Role Action Exists
sub roleActionExists
{
  my ($class, $role, $object, $action, $instance) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @rolesNodes = $_doc->getElementsByTagName("Roles");
  my @roleNodes = $rolesNodes[0]->getChildrenByTagName($role);
  if (@roleNodes)
  {
    my @roleActionsNodes = $roleNodes[0]->getChildrenByTagName("RoleActions");
    my @roleActionNodes = $roleActionsNodes[0]->getChildrenByTagName($object . $action);
    foreach my $roleActionNode (@roleActionNodes)
    {
      if ($roleActionNode->getAttribute("Instance") eq $instance)
      {
        return 1;
      }
    }
  }
  return 0;
}

# ----------------------------------------------------------------------------
# @roleActions = listRoleActions($role, $object, $instance)
# ----------------------------------------------------------------------------

# List Role Actions
sub listRoleActions
{
  my ($class, $role, $object, $instance) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @roleActionList = ();
  my @rolesNodes = $_doc->getElementsByTagName("Roles");
  my @roleNodes = $rolesNodes[0]->getChildrenByTagName($role);
  if (@roleNodes)
  {
    my @roleActionsNodes = $roleNodes[0]->getChildrenByTagName("RoleActions");
    foreach my $roleActionNode ($roleActionsNodes[0]->childNodes())
    {
      my $objectAttr = $roleActionNode->getAttribute("Object");
      my $actionAttr = $roleActionNode->getAttribute("Name");
      my $instanceAttr = $roleActionNode->getAttribute("Instance");
      if ($objectAttr eq $object && $instanceAttr eq $instance)
      {
        push (@roleActionList, $actionAttr);
      }
    }
  }
  return @roleActionList;
}

# ----------------------------------------------------------------------------
# @roleActionInstances = listRoleActionInstances($role, $object, $action, $instance)
# ----------------------------------------------------------------------------

# List Role Action Instances by Instance Type
sub listRoleActionInstances
{
  my ($class, $role, $object, $action, $instance) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @roleActionInstanceList = ();
  my @rolesNodes = $_doc->getElementsByTagName("Roles");
  my @roleNodes = $rolesNodes[0]->getChildrenByTagName($role);
  if (@roleNodes)
  {
    my @roleActionsNodes = $roleNodes[0]->getChildrenByTagName("RoleActions");
    foreach my $roleActionNode ($roleActionsNodes[0]->childNodes())
    {
      my $objectAttr = $roleActionNode->getAttribute("Object");
      my $actionAttr = $roleActionNode->getAttribute("Name");
      my $instanceAttr = $roleActionNode->getAttribute("Instance");
      if (($objectAttr eq $object || $objectAttr eq "ANY") && ($actionAttr eq $action || $actionAttr eq "ANY"))
      {
        if (($instance eq "ANY" && $instanceAttr eq "ANY") || ($instance eq "SELF" && $instanceAttr eq "SELF") || ($instance eq "MEMBERS" && $instanceAttr eq "MEMBERS") || ($instance eq "ADMIN" && $instanceAttr eq "ADMIN") || ($instance eq "INSTANCE" && ($instanceAttr ne "ANY" && $instanceAttr ne "SELF" && $instanceAttr ne "MEMBERS" && $instanceAttr ne "ADMIN")))
        {
          push (@roleActionInstanceList, $instanceAttr);
        }
      }
    }
  }
  return @roleActionInstanceList;
}

# ----------------------------------------------------------------------------
# $value = getRoleActionProperty($role, $object, $action, $instance, $property)
# ----------------------------------------------------------------------------

# Get Role Action Property
sub getRoleActionProperty
{
  my ($class, $role, $object, $action, $instance, $property) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @rolesNodes = $_doc->getElementsByTagName("Roles");
  my @roleNodes = $rolesNodes[0]->getChildrenByTagName($role);
  if (@roleNodes)
  {
    my @roleActionsNodes = $roleNodes[0]->getChildrenByTagName("RoleActions");
    my @roleActionNodes = $roleActionsNodes[0]->getChildrenByTagName($object . $action);
    if (@roleActionNodes)
    {
      my $instanceAttr = $roleActionNodes[0]->getAttribute("Instance");
      if ($instanceAttr eq $instance)
      {
        return $roleActionNodes[0]->getAttribute($property);
      }
    }
  }
  return;
}

# ----------------------------------------------------------------------------
# $boolean = roleUserExists($role, $user)
# ----------------------------------------------------------------------------

# Check if Role User Exists
sub roleUserExists
{
  my ($class, $role, $user) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @rolesNodes = $_doc->getElementsByTagName("Roles");
  my @roleNodes = $rolesNodes[0]->getChildrenByTagName($role);
  if (@roleNodes)
  {
    my @roleUsersNodes = $roleNodes[0]->getChildrenByTagName("RoleUsers");
    return $roleUsersNodes[0]->getChildrenByTagName($user) ? 1 : 0;
  }
  else
  {
    return 0;
  }
}

# ----------------------------------------------------------------------------
# @roleUsers = listRoleUsers($role)
# ----------------------------------------------------------------------------

# List Role Users
sub listRoleUsers
{
  my ($class, $role) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @roleUserList = ();
  my @rolesNodes = $_doc->getElementsByTagName("Roles");
  my @roleNodes = $rolesNodes[0]->getChildrenByTagName($role);
  if (@roleNodes)
  {
    my @roleUsersNodes = $roleNodes[0]->getChildrenByTagName("RoleUsers");
    foreach my $roleUserNode ($roleUsersNodes[0]->childNodes())
    {
      push (@roleUserList, $roleUserNode->nodeName());
    }
  }
  return @roleUserList;
}

# ----------------------------------------------------------------------------
# @userRoles = listUserRoles($user)
# ----------------------------------------------------------------------------

# List User Roles
sub listUserRoles
{
  my ($class, $user) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @userRoleList = ();
  my @rolesNodes = $_doc->getElementsByTagName("Roles");
  foreach my $roleNode ($rolesNodes[0]->childNodes())
  {
    my @roleUsersNodes = $roleNode->getChildrenByTagName("RoleUsers");
    my @roleUserNodes = $roleUsersNodes[0]->getChildrenByTagName($user);
    if (@roleUserNodes)
    {
      push (@userRoleList, $roleNode->nodeName());
    }
  }
  return @userRoleList;
}

# ----------------------------------------------------------------------------
# $value = getRoleUserProperty($role, $user, $property)
# ----------------------------------------------------------------------------

# Get Role User Property
sub getRoleUserProperty
{
  my ($class, $role, $user, $property) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @rolesNodes = $_doc->getElementsByTagName("Roles");
  my @roleNodes = $rolesNodes[0]->getChildrenByTagName($role);
  if (@roleNodes)
  {
    my @roleUsersNodes = $roleNodes[0]->getChildrenByTagName("RoleUsers");
    my @roleUserNodes = $roleUsersNodes[0]->getChildrenByTagName($user);
    if (@roleUserNodes)
    {
      return $roleUserNodes[0]->getAttribute($property);
    }
  }
  return;
}

# ----------------------------------------------------------------------------
# $boolean = passwordExists($password)
# ----------------------------------------------------------------------------

# Check if Password Exists
sub passwordExists
{
  my ($class, $password) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @passwordsNodes = $_doc->getElementsByTagName("Passwords");
  return $passwordsNodes[0]->getChildrenByTagName($password) ? 1 : 0;
}

# ----------------------------------------------------------------------------
# @passwords = listPasswords()
# ----------------------------------------------------------------------------

# List Passwords
sub listPasswords
{
  my ($class) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @passwordList = ();
  my @passwordsNodes = $_doc->getElementsByTagName("Passwords");
  foreach my $passwordNode ($passwordsNodes[0]->childNodes())
  {
    push (@passwordList, $passwordNode->nodeName());
  }
  return @passwordList;
}

# ----------------------------------------------------------------------------
# $value = getPasswordProperty($password, $property)
# ----------------------------------------------------------------------------

# Get Password Property
sub getPasswordProperty
{
  my ($class, $password, $property) = @_;

  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my @passwordsNodes = $_doc->getElementsByTagName("Passwords");
  my @passwordNodes = $passwordsNodes[0]->getChildrenByTagName($password);
  if (@passwordNodes)
  {
    return $passwordNodes[0]->getAttribute($property);
  }
  return;
}

1;
