#! /usr/bin/perl -wT
################################################################################
#
# Gold Custom Bank Class
#
# File   :  Bank.pm
# History:  30 JUL 2004 [Scott Jackson] perl alpha
#           1 NOV 2004 [Scott Jackson] beta mods
#
################################################################################
#                                                                              #
#                              Copyright (c) 2004                              #
#                         Battelle Memorial Institute.                         #
#                             All rights reserved.                             #
#                                                                              #
################################################################################
#                                                                              #
#     Redistribution and use in source and binary forms, with or without       #
#     modification, are permitted provided that the following conditions       #
#     are met:                                                                 #
#                                                                              #
#     - Redistributions of source code must retain the above copyright         #
#     notice, this list of conditions and the following disclaimer.            #
#                                                                              #
#     - Redistributions in binary form must reproduce the above copyright      #
#     notice, this list of conditions and the following disclaimer in the      #
#     documentation and/or other materials provided with the distribution.     #
#                                                                              #
#     - Neither the name of Battelle nor the names of its contributors         #
#     may be used to endorse or promote products derived from this software    #
#     without specific prior written permission.                               #
#                                                                              #
#     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS      #
#     "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT        #
#     LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS        #
#     FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE           #
#     U.S. GOVERNMENT OR THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR     #
#     ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL   #
#     DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS  #
#     OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)    #
#     HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,      #
#     STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING    #
#     IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE       #
#     POSSIBILITY OF SUCH DAMAGE.                                              #
#                                                                              #
################################################################################
use strict;

=head1 NAME

Gold::Bank - implements custom bank actions

=head1 DESCRIPTION

The B<Gold::Bank> module handles custom bank actions through class methods such as balance, transfer, withdraw, deposit, refund, reserve, charge, quote, and overriding base methods.

=head1 METHODS

=over 4

=item $response = Gold::Bank->execute($proxy);

=item $response = Gold::Bank->balance($request, $requestId);

=item $response = Gold::Bank->charge($request, $requestId);

=item $response = Gold::Bank->create($request, $requestId);

=item $response = Gold::Bank->delete($request, $requestId);

=item $response = Gold::Bank->deposit($request, $requestId);

=item $response = Gold::Bank->modify($request, $requestId);

=item $response = Gold::Bank->quote($request, $requestId);

=item $response = Gold::Bank->query($request, $requestId);

=item $response = Gold::Bank->refund($request, $requestId);

=item $response = Gold::Bank->refresh($request, $requestId);

=item $response = Gold::Bank->reserve($request, $requestId);

=item $response = Gold::Bank->transfer($request, $requestId);

=item $response = Gold::Bank->withdraw($request, $requestId);

=item $response = Gold::Bank->undelete($request, $requestId);

=item $response = Gold::Bank->usage($request, $requestId);

=item $response = Gold::Bank->logTransaction(database => $database, object => $object, action => $action, actor => $actor, assignments => \@assignments, conditions => \@conditions, options => \@options, data => \@data, count => $count, account => $account, delta => $delta, allocation => $allocation, requestId => $requestId, txnId => $txnId);

=back

=head1 EXAMPLES

use Gold::Base;

my $response = Gold::Bank->balance($request, $requestId);

=head1 REQUIRES

Perl 5.6.1

=head1 AUTHOR

Scott Jackson, Scott.Jackson@pnl.gov

=cut

##############################################################################


package Gold::Bank;

use vars qw($log);
use DBI qw( :sql_types );
use XML::LibXML;
use Gold::Cache;
use Gold::Global;
use Gold::Request;
use Gold::Response;


# ----------------------------------------------------------------------------
# $response = execute($proxy); 
# ----------------------------------------------------------------------------

# Performs a custom bank action
sub execute
{
  my ($class, $proxy) = @_;
    
  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  } 

  my $request = $proxy->getRequest();
  my $action = $request->getAction();
  my $requestId = $proxy->getRequestId();
  my $lastResponse = $proxy->getResponse();
  my $response;

  # Provide usage if help flag specified
  my $showUsage = $request->getOptionValue("ShowUsage");
  if (defined $showUsage && $showUsage eq "True")
  {
    # Call the usage for the custom bank action
    $response = Gold::Bank->usage($request, $requestId);
  }

  # Otherwise try to perform the custom action

  # Balance
  elsif ($action eq "Balance")
  {
    $response = Gold::Bank->balance($request, $requestId);
  }

  # Charge
  elsif ($action eq "Charge")
  {
    $response = Gold::Bank->charge($request, $requestId);
  }

  # Create
  elsif ($action eq "Create")
  {
    $response = Gold::Bank->create($request, $requestId);
  }

  # Delete
  elsif ($action eq "Delete")
  {
    $response = Gold::Bank->delete($request, $requestId);
  }

  # Deposit
  elsif ($action eq "Deposit")
  {
    $response = Gold::Bank->deposit($request, $requestId);
  }

  # Modify
  elsif ($action eq "Modify")
  {
    $response = Gold::Bank->modify($request, $requestId);
  }

  # Quote
  elsif ($action eq "Quote")
  {
    $response = Gold::Bank->quote($request, $requestId);
  }

  # Query
  elsif ($action eq "Query")
  {
    $response = Gold::Bank->query($request, $requestId);
  }

  # Refund
  elsif ($action eq "Refund")
  {
    $response = Gold::Bank->refund($request, $requestId);
  }

  # Refresh
  elsif ($action eq "Refresh")
  {
    $response = Gold::Bank->refresh($request, $requestId);
  }

  # Reserve
  elsif ($action eq "Reserve")
  {
    $response = Gold::Bank->reserve($request, $requestId);
  }

  # Transfer
  elsif ($action eq "Transfer")
  {
    $response = Gold::Bank->transfer($request, $requestId);
  }

  # Withdraw
  elsif ($action eq "Withdraw")
  {
    $response = Gold::Bank->withdraw($request, $requestId);
  }

  # Undelete
  elsif ($action eq "Undelete")
  {
    $response = Gold::Bank->undelete($request, $requestId);
  }

  else
  {
    $log->error("Unsupported action: ($action)");
    $response = new Gold::Response()->failure("313", "Unsupported bank action: ($action)");
  }

  return $response;
}


# ----------------------------------------------------------------------------
# $response = balance($request, $requestId);
# ----------------------------------------------------------------------------

# Balance (Account)
sub balance
{
  my ($class, $request, $requestId) = @_;

  if ($log->is_debug())
  {
    $log->debug("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my $object = $request->getObject();
  my $actor = $request->getActor();
  my $database = $request->getDatabase();
  my $project = $request->getOptionValue("Project");
  my $user = $request->getOptionValue("User");
  my $machine = $request->getOptionValue("Machine");
  my $type = $request->getOptionValue("CallType") || "Normal";
  my @options = $request->getOptions();
  my $ignoreReservations = $request->getOptionValue("IgnoreReservations");
  my $ignoreAncestors = $request->getOptionValue("IgnoreAncestors");
  my $showAvailableCredit = $request->getOptionValue("ShowAvailableCredit");
  my $balance = 0;
  my %accounts = ();
  my %checkBoth = ();
  my %checkUser = ();
  my %checkMach = ();
  my @ids = ();
  my $now = time;

  if ($object ne "Account")
  {
    return new Gold::Response()->failure("315", "The Bank class does not implement $object Balance");
  }

  # Override Authorization
  my $authorized = 1;
  if ($request->getOverride())
  {
    $authorized = 0;
  }
  if (! $authorized && defined $project)
  {
    # See if actor is project admin
    # SELECT Admin FROM ProjectUser WHERE Project=$project AND Name=$actor AND Admin=True
    my $subResults = $database->select(object => "ProjectUser", selections => [ new Gold::Selection(name => "Admin") ], conditions => [ new Gold::Condition(name => "Project", value => $project), new Gold::Condition(name => "Name", value => $actor), new Gold::Condition(name => "Admin", value => "True") ]);
    if (@{$subResults->{data}})
    {
      $authorized = 1;
    }
  }
  if (! $authorized && defined $user)
  {
    if ($user eq $actor)
    {
      $authorized = 1;
    }
  }
  #if (! $authorized && defined $machine)
  #{
  #  # See if actor is machine admin
  #  # SELECT Admin FROM MachineUser WHERE Machine=$machine AND Name=$actor AND Admin=True
  #  my $subResults = $database->select(object => "MachineUser", selections => [ new Gold::Selection(name => "Admin") ], conditions => [ new Gold::Condition(name => "Machine", value => $machine), new Gold::Condition(name => "Name", value => $actor), new Gold::Condition(name => "Admin", value => "True") ]);
  #  if (@{$subResults->{data}})
  #  {
  #    $authorized = 1;
  #  }
  #}
  if (! $authorized)
  {
    return new Gold::Response()->failure("444", "$actor is not authorized to obtain the Account Balance");
  }
  
  # Prescreen Project
  if (defined $project)
  {
    # Lookup project
    # SELECT Active,Special FROM Project WHERE Name=$project
    my $subResults = $database->select(object => "Project", selections => [ new Gold::Selection(name => "Active"), new Gold::Selection(name => "Special") ], conditions => [ new Gold::Condition(name => "Name", value => $project) ]);
    if (@{$subResults->{data}})
    {
      my $active = ${$subResults->{data}}[0]->[0];
      my $special = ${$subResults->{data}}[0]->[1];
      if (defined $special && $special ne "True" && defined $active && $active ne "True")
      {
        return new Gold::Response()->failure("740", "Project $project is not active");
      }
    }
    else
    {
      return new Gold::Response()->failure("740", "Project $project does not exist");
    }
  }

  # Prescreen User
  if (defined $user)
  {
    # Lookup user
    # SELECT Active,Special FROM User WHERE Name=$user
    my $subResults = $database->select(object => "User", selections => [ new Gold::Selection(name => "Active"), new Gold::Selection(name => "Special") ], conditions => [ new Gold::Condition(name => "Name", value => $user) ]);
    if (@{$subResults->{data}})
    {
      my $active = ${$subResults->{data}}[0]->[0];
      my $special = ${$subResults->{data}}[0]->[1];
      if (defined $special && $special ne "True" && defined $active && $active ne "True")
      {
        return new Gold::Response()->failure("740", "User $user is not active");
      }
    }
    else
    {
      return new Gold::Response()->failure("740", "User $user does not exist");
    }
  }
  
  # Prescreen Machine
  if (defined $machine)
  {
    # Lookup machine
    # SELECT Active,Special FROM Machine WHERE Name=$machine
    my $subResults = $database->select(object => "Machine", selections => [ new Gold::Selection(name => "Active"), new Gold::Selection(name => "Special") ], conditions => [ new Gold::Condition(name => "Name", value => $machine) ]);
    if (@{$subResults->{data}})
    {
      my $active = ${$subResults->{data}}[0]->[0];
      my $special = ${$subResults->{data}}[0]->[1];
      if (defined $special && $special ne "True" && defined $active && $active ne "True")
      {
        return new Gold::Response()->failure("740", "Machine $machine is not active");
      }
    }
    else
    {
      return new Gold::Response()->failure("740", "Machine $machine does not exist");
    }
  }
  
  # Iterate over the options building account id lists
  foreach my $option (@options)
  {
    my $name = $option->getName();

    if ($name eq "Id")
    {
      push @ids, $option->getValue();
    }
  }

  # Refresh Allocations
  my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Refresh");
  my $subResponse = Gold::Bank->refresh($subRequest, $requestId);
  if ($subResponse->getStatus() eq "Failure")
  {
    return new Gold::Response()->failure($subResponse->getCode(), "Failed while refreshing allocations: " . $subResponse->getMessage());
  }
  
  # Construct list of viable accounts
  {
    # SELECT Account.Id,AccountProject.Name,AccountUser.Name,AccountMachine.Name FROM Account,AccountUser,AccountProject,AccountMachine,Allocation WHERE Allocation.StartTime<=$now AND Allocation.EndTime>$now AND Allocation.CallType=$type AND AccountProject.Account=Account.Id AND AccountUser.Account=Account.Id AND AccountMachine.Account=Account.Id AND Allocation.Account=Account.Id
  
    my @objects =
    (
      new Gold::Object(name => "Account"),
      new Gold::Object(name => "AccountUser"),
      new Gold::Object(name => "AccountProject"),
      new Gold::Object(name => "AccountMachine"),
      new Gold::Object(name => "Allocation"),
    );
  
    my @selections =
    (
      new Gold::Selection(object => "Account", name => "Id"),
      new Gold::Selection(object => "AccountProject", name => "Name"),
      new Gold::Selection(object => "AccountUser", name => "Name"),
      new Gold::Selection(object => "AccountMachine", name => "Name")
    );
  
    my @conditions =
    (
      new Gold::Condition(object => "Allocation", name => "Account", subject => "Account", value => "Id"),
      new Gold::Condition(object => "Allocation", name => "StartTime", value => $now, op => "LE"),
      new Gold::Condition(object => "Allocation", name => "EndTime", value => $now, op => "GT"),
      new Gold::Condition(object => "Allocation", name => "CallType", value => $type),
      new Gold::Condition(object => "AccountProject", name => "Account", subject => "Account", value => "Id"),
      new Gold::Condition(object => "AccountUser", name => "Account", subject => "Account", value => "Id"),
      new Gold::Condition(object => "AccountMachine", name => "Account", subject => "Account", value => "Id")
    );
  
    # Add project conditions
  
    # This is a wildcard. Look for any true entities
    if (! defined $project)
    {
      push @conditions, new Gold::Condition(object => "AccountProject", name => "Name", value => "NONE", op => "NE", conj => "And", group => "+2");
      push @conditions, new Gold::Condition(object => "AccountProject", name => "Access", value => "True", conj => "And", group => "-1");
    }
  
    # Not a wildcard. Process normally
    else
    {
      push @conditions, new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+3");
      push @conditions, new Gold::Condition(object => "AccountProject", name => "Access", value => "True", conj => "And", group => "-1");
      push @conditions, new Gold::Condition(object => "AccountProject", name => "Name", value => $project, conj => "Or", group => "+1");
      push @conditions, new Gold::Condition(object => "AccountProject", name => "Access", value => "True", conj => "And", group => "-2");
    }
  
    # Add user conditions
  
    # This is a wildcard. Look for any true entities
    if (! defined $user)
    {
      push @conditions, new Gold::Condition(object => "AccountUser", name => "Name", value => "NONE", op => "NE", conj => "And", group => "+1");
      push @conditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-1");
    }
  
    # Not a wildcard. Process normally
    else
    {
      push @conditions, new Gold::Condition(object => "AccountUser", name => "Name", value => "ANY", conj => "And", group => "+2");
      push @conditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-1");
      push @conditions, new Gold::Condition(object => "AccountUser", name => "Name", value => $user, conj => "Or", group => "+1");
      push @conditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-1");
      push @conditions, new Gold::Condition(object => "AccountUser", name => "Name", value => "MEMBERS", conj => "Or", group => "+1");
      push @conditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-2");
    }
  
    # Add machine conditions
  
    # This is a wildcard. Look for any true entities
    if (! defined $machine)
    {
      push @conditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => "NONE", op => "NE", conj => "And", group => "+1");
      push @conditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-2");
    }
  
    # Not a wildcard. Process normally
    else
    {
      push @conditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => "ANY", conj => "And", group => "+2");
      push @conditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-1");
      push @conditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => $machine, conj => "Or", group => "+1");
      push @conditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-1");
      push @conditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => "MEMBERS", conj => "Or", group => "+1");
      push @conditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-3");
    }
  
    # Add id conditions
    my $firstTime = 1;
    my $counter = 0;
    foreach my $id (@ids)
    {
      $counter++;
      my $lastTime = ($counter == scalar @ids) ? 1 : 0;

      if ($firstTime && $lastTime)
      {
        push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "And", group => "0");
      }
      elsif ($firstTime)
      {
        $firstTime = 0;
        push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "And", group => "+1");
      }
      elsif ($lastTime)
      {
        push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "Or", group => "-1");
      }
      else
      {
        push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "Or", group => "0");
      }
    }

    my $results = $database->select(objects => \@objects, selections => \@selections, conditions => \@conditions);
    foreach my $row (@{$results->{data}})
    {
      my $accountId = $row->[0];
      my $accountProject = $row->[1];
      my $accountUser = $row->[2];
      my $accountMachine = $row->[3];
      
      # Check membership
      if ($accountUser eq "MEMBERS" && $accountMachine eq "MEMBERS")
      {
        $checkBoth{$accountId} = 1;
      }
      elsif ($accountUser eq "MEMBERS")
      {
        $checkUser{$accountId} = 1;
      }
      elsif ($accountMachine eq "MEMBERS")
      {
        $checkMach{$accountId} = 1;
      }
      else
      {
        $accounts{$accountId} = 1;
      }
    }

    # Check Both Membership
    if (%checkBoth)
    {
      my @subObjects = ( new Gold::Object(name => "AccountProject"), new Gold::Object(name => "ProjectUser"), new Gold::Object(name => "ProjectMachine"));
      my @subSelections = ( new Gold::Selection(object => "AccountProject", name => "Account") );
      my @subConditions = ();
      push @subConditions, new Gold::Condition(object => "ProjectUser", name => "Active", value => "True");
      push @subConditions, new Gold::Condition(object => "ProjectMachine", name => "Active", value => "True");
      if (defined $user)
      {
        push @subConditions, new Gold::Condition(object => "ProjectUser", name => "Name", value => $user);
      }
      if (defined $machine)
      {
        push @subConditions, new Gold::Condition(object => "ProjectMachine", name => "Name", value => $machine);
      }
      push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+2");
      push @subConditions, new Gold::Condition(object => "ProjectUser", name => "Project", subject => "ProjectMachine", value => "Project", conj => "And", group => "-1");
      push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", subject => "ProjectUser", value => "Project", conj => "Or", group => "+1");
      push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", subject => "ProjectMachine", value => "Project", conj => "And", group => "-2");

      # Add id conditions
      my $firstTime = 1;
      my $counter = 0;
      foreach my $id (keys %checkBoth)
      {
        $counter++;
        my $lastTime = ($counter == scalar keys %checkBoth) ? 1 : 0;
  
        if ($firstTime && $lastTime)
        {
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "And", group => "0");
        }
        elsif ($firstTime)
        {
          $firstTime = 0;
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "And", group => "+1");
        }
        elsif ($lastTime)
        {
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "Or", group => "-1");
        }
        else
        {
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "Or", group => "0");
        }
      }

      my $subResults = $database->select(objects => \@subObjects, selections => \@subSelections, conditions => \@subConditions);
      foreach my $row (@{$subResults->{data}})
      {
        my $accountId = $row->[0];
        $accounts{$accountId} = 1;
      }
    }
        
    # Check User Membership
    if (%checkUser)
    {
      my @subObjects = ( new Gold::Object(name => "AccountProject"), new Gold::Object(name => "ProjectUser"));
      my @subSelections = ( new Gold::Selection(object => "AccountProject", name => "Account") );
      my @subConditions = ();
      push @subConditions, new Gold::Condition(object => "ProjectUser", name => "Active", value => "True");
      if (defined $user)
      {
        push @subConditions, new Gold::Condition(object => "ProjectUser", name => "Name", value => $user);
      }
      push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+1");
      push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", subject => "ProjectUser", value => "Project", conj => "Or", group => "-1");

      # Add id conditions
      my $firstTime = 1;
      my $counter = 0;
      foreach my $id (keys %checkUser)
      {
        $counter++;
        my $lastTime = ($counter == scalar keys %checkUser) ? 1 : 0;
  
        if ($firstTime && $lastTime)
        {
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "And", group => "0");
        }
        elsif ($firstTime)
        {
          $firstTime = 0;
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "And", group => "+1");
        }
        elsif ($lastTime)
        {
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "Or", group => "-1");
        }
        else
        {
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "Or", group => "0");
        }
      }

      my $subResults = $database->select(objects => \@subObjects, selections => \@subSelections, conditions => \@subConditions);
      foreach my $row (@{$subResults->{data}})
      {
        my $accountId = $row->[0];
        $accounts{$accountId} = 1;
      }
    }
        
    # Check Machine Membership
    if (%checkMach)
    {
      my @subObjects = ( new Gold::Object(name => "AccountProject"), new Gold::Object(name => "ProjectMachine"));
      my @subSelections = ( new Gold::Selection(object => "AccountProject", name => "Account") );
      my @subConditions = ();
      push @subConditions, new Gold::Condition(object => "ProjectMachine", name => "Active", value => "True");
      if (defined $machine)
      {
        push @subConditions, new Gold::Condition(object => "ProjectMachine", name => "Name", value => $machine);
      }
      push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+1");
      push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", subject => "ProjectMachine", value => "Project", conj => "Or", group => "-1");

      # Add id conditions
      my $firstTime = 1;
      my $counter = 0;
      foreach my $id (keys %checkMach)
      {
        $counter++;
        my $lastTime = ($counter == scalar keys %checkMach) ? 1 : 0;
  
        if ($firstTime && $lastTime)
        {
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "And", group => "0");
        }
        elsif ($firstTime)
        {
          $firstTime = 0;
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "And", group => "+1");
        }
        elsif ($lastTime)
        {
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "Or", group => "-1");
        }
        else
        {
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "Or", group => "0");
        }
      }

      my $subResults = $database->select(objects => \@subObjects, selections => \@subSelections, conditions => \@subConditions);
      foreach my $row (@{$subResults->{data}})
      {
        my $accountId = $row->[0];
        $accounts{$accountId} = 1;
      }
    }
        
    if ($log->is_debug())
    {
      $log->debug("Initial accepted account list is: " . join ',', keys %accounts);
    }
  }

  # Only screen these accounts if there are some to do so to
  if (scalar keys %accounts)
  {
    # Check to make sure these accounts are not rejected
    # SELECT DISTINCT Account.Id FROM Account,AccountUser,AccountProject,AccountMachine WHERE AccountProject.Account=Account.Id AND AccountUser.Account=Account.Id AND AccountMachine.Account=Account.Id AND <Id IN AccountList>

    my @objects =
    (
      new Gold::Object(name => "Account"),
      new Gold::Object(name => "AccountUser"),
      new Gold::Object(name => "AccountProject"),
      new Gold::Object(name => "AccountMachine")
    );
  
    my @selections = ( new Gold::Selection(object => "Account", name => "Id") );
  
    my @conditions =
    (
      new Gold::Condition(object => "AccountProject", name => "Account", subject => "Account", value => "Id"),
      new Gold::Condition(object => "AccountUser", name => "Account", subject => "Account", value => "Id"),
      new Gold::Condition(object => "AccountMachine", name => "Account", subject => "Account", value => "Id")
    );
  
    my @options = ( new Gold::Option(name => "Unique", value => "True") );

    # Constrain to list of accepted ids
    my $firstTime = 1;
    my $counter = 0;
    foreach my $id (keys %accounts)
    {
      $counter++;
      my $lastTime = ($counter == scalar keys %accounts) ? 1 : 0;

      if ($firstTime && $lastTime)
      {
        push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "And", group => "0");
      }
      elsif ($firstTime)
      {
        $firstTime = 0;
        push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "And", group => "+1");
      }
      elsif ($lastTime)
      {
        push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "Or", group => "-1");
      }
      else
      {
        push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "Or", group => "0");
      }
    }

    # Add project conditions
  
    # Wildcarding ignores all restrictions
    if (! defined $project)
    {
      push @conditions, new Gold::Condition(object => "AccountProject", name => "Name", subject => "AccountProject", value => "Name", op => "NE", conj => "And", group => "+1");
    }
  
    # Not a wildcard. Process normally
    else
    {
      push @conditions, new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+3");
      push @conditions, new Gold::Condition(object => "AccountProject", name => "Access", value => "False", conj => "And", group => "-1");
      push @conditions, new Gold::Condition(object => "AccountProject", name => "Name", value => $project, conj => "Or", group => "+1");
      push @conditions, new Gold::Condition(object => "AccountProject", name => "Access", value => "False", conj => "And", group => "-2");
    }
  
    # Add user conditions
  
    # Wildcarding ignores all restrictions
    if (! defined $user)
    {
      push @conditions, new Gold::Condition(object => "AccountUser", name => "Name", subject => "AccountUser", value => "Name", op => "NE", conj => "Or", group => "0");
    }
  
    # Not a wildcard. Process normally
    else
    {
      push @conditions, new Gold::Condition(object => "AccountUser", name => "Name", value => "ANY", conj => "Or", group => "+2");
      push @conditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "False", conj => "And", group => "-1");
      push @conditions, new Gold::Condition(object => "AccountUser", name => "Name", value => $user, conj => "Or", group => "+1");
      push @conditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "False", conj => "And", group => "-1");
      push @conditions, new Gold::Condition(object => "AccountUser", name => "Name", value => "MEMBERS", conj => "Or", group => "+1");
      push @conditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "False", conj => "And", group => "-2");
    }
  
    # Add machine conditions
  
    # Wildcarding ignores all restrictions
    if (! defined $machine)
    {
      push @conditions, new Gold::Condition(object => "AccountMachine", name => "Name", subject => "AccountMachine", value => "Name", op => "NE", conj => "Or", group => "-1");
    }
  
    # Not a wildcard. Process normally
    else
    {
      push @conditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => "ANY", conj => "Or", group => "+2");
      push @conditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "False", conj => "And", group => "-1");
      push @conditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => $machine, conj => "Or", group => "+1");
      push @conditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "False", conj => "And", group => "-1");
      push @conditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => "MEMBERS", conj => "Or", group => "+1");
      push @conditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "False", conj => "And", group => "-3");
    }
  
    my $results = $database->select(objects => \@objects, selections => \@selections, conditions => \@conditions, options => \@options);
    foreach my $row (@{$results->{data}})
    {
      my $accountId = $row->[0];

      # Remove from accounts
      delete $accounts{$accountId};
    }

    if ($log->is_debug())
    {
      $log->debug("Post rejection account list is: " . join ',', keys %accounts);
    }

    # Factor in ancestor accounts if ignoreAncestors is unspecified or not set to true
    if (! defined $ignoreAncestors || $ignoreAncestors eq "False")
    {
      my %ancestors = ();
      # SELECT Account,Id FROM AccountAccount WHERE Overflow=True
      my @selections = ( new Gold::Selection(name => "Account"), new Gold::Selection(name => "Id") );
      my @conditions = ( new Gold::Condition(name => "Overflow", value => "True") );
      my $results = $database->select(object => "AccountAccount", selections => \@selections, conditions => \@conditions);
      foreach my $row (@{$results->{data}})
      {
        my $parent = $row->[0];
        my $child = $row->[1];
  
        $ancestors{$child}{$parent} = 1;
      }
        
      # Add ancestors a generation at a time until there is no more growth
      while (1)
      {
        my $count = scalar keys %accounts;
        foreach my $account (keys %accounts)
        {
          foreach my $parent (keys %{$ancestors{$account}})
          {
            $accounts{$parent} = 1 unless exists $accounts{$parent};
          }
        }
        last if $count == scalar keys %accounts;
      }

      if ($log->is_debug())
      {
        $log->debug("Post ancestral account list is: " . join ',', keys %accounts);
      }
    }
  }

  # Lookup sum of active account amounts from account list if any
  if (scalar keys %accounts)
  {
    # SELECT SUM(Amount),SUM(CreditLimit) FROM Allocation WHERE StartTime<=$now AND EndTime>$now AND CallType=$type AND (Account=<Id> ...)

    my @selections =
    (
      new Gold::Selection(name => "Amount", op => "Sum"),
      new Gold::Selection(name => "CreditLimit", op => "Sum"),
    );

    my @conditions =
    (
      new Gold::Condition(name => "StartTime", value => $now, op => "LE"),
      new Gold::Condition(name => "EndTime", value => $now, op => "GT"),
      new Gold::Condition(name => "CallType", value => $type),
    );

    # Constrain to list of accepted ids
    my $firstTime = 1;
    my $counter = 0;
    foreach my $id (keys %accounts)
    {
      $counter++;
      my $lastTime = ($counter == scalar keys %accounts) ? 1 : 0;

      if ($firstTime && $lastTime)
      {
        push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "And", group => "0");
      }
      elsif ($firstTime)
      {
        $firstTime = 0;
        push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "And", group => "+1");
      }
      elsif ($lastTime)
      {
        push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "Or", group => "-1");
      }
      else
      {
        push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "Or", group => "0");
      }
    }

    my $results = $database->select(object => "Allocation", selections => \@selections, conditions => \@conditions);
    foreach my $row (@{$results->{data}})
    {
      my $amountSum = $row->[0];
      my $creditLimitSum = $row->[1];

      $balance += $amountSum;
      if (defined $showAvailableCredit && $showAvailableCredit eq "True")
      {
        $balance += $creditLimitSum;
      }
    }

    # Factor in reservations if ignoreReservations is unspecified or not set to true
    if (! defined $ignoreReservations || $ignoreReservations ne "True")
    {
      # Lookup sum of active reservation amounts against these accounts
      # SELECT SUM(ReservationAllocation.Amount) FROM Reservation,ReservationAllocation WHERE Reservation.Id=ReservationAllocation.Reservation AND Reservation.StartTime<=$now AND Reservation.EndTime > $now AND (ReservationAllocation.Account=<Id> ...)
      my @objects = ( new Gold::Object(name => "Reservation"), new Gold::Object(name => "ReservationAllocation"));
      @selections = ( new Gold::Selection(object => "ReservationAllocation", name => "Amount", op => "Sum") );
      @conditions =
        (
          new Gold::Condition(object => "Reservation", name => "Id", subject => "ReservationAllocation", value => "Reservation"),
          new Gold::Condition(object => "Reservation", name => "StartTime", value => $now, op => "LE"),
          new Gold::Condition(object => "Reservation", name => "EndTime", value => $now, op => "GT"),
        );

      # Constrain to list of accepted ids
      $firstTime = 1;
      $counter = 0;
      foreach my $id (keys %accounts)
      {
        $counter++;
        my $lastTime = ($counter == scalar keys %accounts) ? 1 : 0;
  
        if ($firstTime && $lastTime)
        {
          push @conditions, new Gold::Condition(object => "ReservationAllocation", name => "Account", value => $id, conj => "And", group => "0");
        }
        elsif ($firstTime)
        {
          $firstTime = 0;
          push @conditions, new Gold::Condition(object => "ReservationAllocation", name => "Account", value => $id, conj => "And", group => "+1");
        }
        elsif ($lastTime)
        {
          push @conditions, new Gold::Condition(object => "ReservationAllocation", name => "Account", value => $id, conj => "Or", group => "-1");
        }
        else
        {
          push @conditions, new Gold::Condition(object => "ReservationAllocation", name => "Account", value => $id, conj => "Or", group => "0");
        }
      }

      $results = $database->select(objects => \@objects, selections => \@selections, conditions => \@conditions);
      if (defined ${$results->{data}}[0]->[0])
      {
        $balance -= ${$results->{data}}[0]->[0];
      }
    }
  }

  my $time_division = defined $request->getOptionValue("ShowHours") ? 3600 : 1;
  my $currency_precision = $config->get_property("currency.precision", 0);
  if ($time_division == 3600) { $currency_precision = 2; }
  $balance = sprintf("%.${currency_precision}f", $balance / $time_division);
  my @data = ();
  my $datum = new Gold::Datum("Account");
  $datum->setValue("Balance", $balance);
  push @data, $datum;

  return new Gold::Response()->success($balance, \@data, "The account balance is $balance credits");
}
  

# ----------------------------------------------------------------------------
# $response = charge($request, $requestId);
# ----------------------------------------------------------------------------

# Charge (Job)
sub charge
{
  my ($class, $request, $requestId) = @_;

  if ($log->is_debug())
  {
    $log->debug("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my $object = $request->getObject();
  my $actor = $request->getActor();
  my $database = $request->getDatabase();
  my $quoteMessage = "";
  my $reserveMessage = "";
  my $chargeMessage = "";
  my $backMessage = "";
  my $forwardMessage = "";
  my $now = time;
  my $startTime = 0; # -infinity
  my $endTime = $now;
  my $callType = $request->getOptionValue("CallType") || "Normal";
  if ($callType ne "Normal" && $callType ne "Back" && $callType ne "Forward")
  {
    $callType = "Normal";
  }
  my $backProject = $request->getOptionValue("BackProject");
  my $backUser = $request->getOptionValue("BackUser");
  my $backMachine = $request->getOptionValue("BackMachine");
  my $forwardProject = $request->getOptionValue("ForwardProject");
  my $forwardUser = $request->getOptionValue("ForwardUser");
  my $forwardMachine = $request->getOptionValue("ForwardMachine");
  my %charges = ();

  if ($object ne "Job")
  {
    return new Gold::Response()->failure("315", "The Bank class does not implement $object Charge");
  }

  # Data must be present
  my $doc = XML::LibXML::Document->new();
  my $data = $request->getDataElement();
  $doc->setDocumentElement($data);
  unless (defined $data)
  {
    return new Gold::Response()->failure("314", "Job data is required");
  }

  # Return failure if we detect a job object property we do not support
  foreach my $property (qw(JobGroup JobDefaults TaskGroup TaskGroupDefaults Requested Delivered Resource Extension))
  {
    if ($data->findnodes("//$property"))
    {
      return new Gold::Response()->failure("710", "The $property element is not supported");
    }
  }

  # We currently only support a solitary job
  my @jobs = $data->findnodes("/Data/Job");
  if (@jobs == 0)
  {
    return new Gold::Response()->failure("314", "At least one job must be specified");
  }
  elsif (@jobs > 1)
  {
    return new Gold::Response()->failure("314", "Only one job may be specified");
  }

  my $job = $jobs[0];

  # Build up a list of job attributes and assignments
  my %attributes = ();
  my @assignments = ();
  my $results = $database->select(object => "Attribute", selections => [ new Gold::Selection(name => "Name") ], conditions => [ new Gold::Condition(name => "Object", value => "Job"), new Gold::Condition(name => "Hidden", value => "False") ]);
  foreach my $row (@{$results->{data}})
  {
    my $name = $row->[0];
    $attributes{$name} = 1;
  }

  # JobId
  my $jobId = $job->findvalue("//JobId");
  if ($jobId ne "")
  {
    if (exists $attributes{JobId})
    {
      delete $attributes{JobId};
      push @assignments, new Gold::Assignment(name => "JobId", value => $jobId);
    }
  }
  else
  {
    return new Gold::Response()->failure("314", "A job id must be specified for the charge");
  }

  # User
  my $user = $job->findvalue("//UserId");
  if ($callType eq "Back" && defined $backUser) { $user = $backUser; }
  if ($callType eq "Forward" && defined $forwardUser) { $user = $forwardUser; }
  if ($user eq "")
  {
    # Look for a system default project
    $user = $config->get_property("user.default", $USER_DEFAULT);
    if ($user eq "NONE" || $user eq "")
    {
      return new Gold::Response()->failure("314", "A user must be specified for the charge");
    }
  }

  # Verify user
  # SELECT Active,Special FROM User WHERE Name=$user
  my $subResults = $database->select(object => "User", selections => [ new Gold::Selection(name => "Active"), new Gold::Selection(name => "Special") ], conditions => [ new Gold::Condition(name => "Name", value => $user) ]);
  if (@{$subResults->{data}})
  {
    my $active = ${$subResults->{data}}[0]->[0];
    my $special = ${$subResults->{data}}[0]->[1];
    if (defined $active && $active ne "True")
    {
      return new Gold::Response()->failure("740", "User $user is not active");
    }
    if (defined $special && $special eq "True")
    {
      return new Gold::Response()->failure("740", "User $user is special");
    }
  }
  else
  {
    if ($config->get_property("user.autogen", $USER_AUTOGEN) =~ /true/i)
    {
      # Create the user
      my $subRequest = new Gold::Request(database => $database, object => "User", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Name", value => $user), new Gold::Assignment(name => "Description", value => "Auto-Generated") ]);
      my $subResponse = Gold::Base->create($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to create user: " . $subResponse->getMessage());
      }
    }
    else
    {
      return new Gold::Response()->failure("740", "User $user does not exist");
    }
  }
    
  if (exists $attributes{User})
  {
    push @assignments, new Gold::Assignment(name => "User", value => $user);
    delete $attributes{User};
  }

  # Project
  my $project = $job->findvalue("//ProjectId");
  if ($callType eq "Back" && defined $backProject) { $project = $backProject; }
  if ($callType eq "Forward" && defined $forwardProject) { $project = $forwardProject; }
  if ($project eq "")
  {
    # Look for a user default project
    # SELECT DefaultProject FROM User WHERE Name=$user
    my $subResults = $database->select(object => "User", selections => [ new Gold::Selection(name => "DefaultProject") ], conditions => [ new Gold::Condition(name => "Name", value => $user) ]);
    if (@{$subResults->{data}})
    {
      my $defaultProject = ${$subResults->{data}}[0]->[0];
      if (defined $defaultProject)
      {
        $project = $defaultProject;
      }
    }
    # Look for a system default project
    else
    {
      $project = $config->get_property("project.default", $PROJECT_DEFAULT);
      if ($project eq "NONE" || $project eq "")
      {
        return new Gold::Response()->failure("314", "A project must be specified for the charge\nor a default project must exist for the user");
      }
    }
  }

  # Verify project
  # SELECT Active,Special FROM Project WHERE Name=$project
  $subResults = $database->select(object => "Project", selections => [ new Gold::Selection(name => "Active"), new Gold::Selection(name => "Special") ], conditions => [ new Gold::Condition(name => "Name", value => $project) ]);
  if (@{$subResults->{data}})
  {
    my $active = ${$subResults->{data}}[0]->[0];
    my $special = ${$subResults->{data}}[0]->[1];
    if (defined $active && $active ne "True")
    {
      return new Gold::Response()->failure("740", "Project $project is not active");
    }
    if (defined $special && $special eq "True")
    {
      return new Gold::Response()->failure("740", "Project $project is special");
    }
  }
  else
  {
    if ($config->get_property("project.autogen", $PROJECT_AUTOGEN) =~ /true/i)
    {
      # Create the project
      my $subRequest = new Gold::Request(database => $database, object => "Project", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Name", value => $project), new Gold::Assignment(name => "Description", value => "Auto-Generated") ]);
      my $subResponse = Gold::Base->create($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to create project: " . $subResponse->getMessage());
      }
    }
    else
    {
      return new Gold::Response()->failure("740", "Project $project does not exist");
    }
  }

  if (exists $attributes{Project})
  {
    delete $attributes{Project};
    push @assignments, new Gold::Assignment(name => "Project", value => $project);
  }

  # Machine
  my $machine = $job->findvalue("//MachineName");
  if ($callType eq "Back" && defined $backMachine) { $machine = $backMachine; }
  if ($callType eq "Forward" && defined $forwardMachine) { $machine = $forwardMachine; }
  if ($machine eq "")
  {
    # Look for a system default machine
    $machine = $config->get_property("machine.default", $MACHINE_DEFAULT);
    if ($machine eq "NONE" || $machine eq "")
    {
      return new Gold::Response()->failure("314", "A machine must be specified for the charge");
    }
  }

  # Verify machine
  # SELECT Active,Special FROM Machine WHERE Name=$machine
  $subResults = $database->select(object => "Machine", selections => [ new Gold::Selection(name => "Active"), new Gold::Selection(name => "Special") ], conditions => [ new Gold::Condition(name => "Name", value => $machine) ]);
  if (@{$subResults->{data}})
  {
    my $active = ${$subResults->{data}}[0]->[0];
    my $special = ${$subResults->{data}}[0]->[1];
    if (defined $active && $active ne "True")
    {
      return new Gold::Response()->failure("740", "Machine $machine is not active");
    }
    if (defined $special && $special eq "True")
    {
      return new Gold::Response()->failure("740", "Machine $machine is special");
    }
  }
  else
  {
    if ($config->get_property("machine.autogen", $MACHINE_AUTOGEN) =~ /true/i)
    {
      # Create the machine
      my $subRequest = new Gold::Request(database => $database, object => "Machine", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Name", value => $machine), new Gold::Assignment(name => "Description", value => "Auto-Generated") ]);
      my $subResponse = Gold::Base->create($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to create machine: " . $subResponse->getMessage());
      }
    }
    else
    {
      return new Gold::Response()->failure("740", "Machine $machine does not exist");
    }
  }

  if (exists $attributes{Machine})
  {
    delete $attributes{Machine};
    push @assignments, new Gold::Assignment(name => "Machine", value => $machine);
  }

  # Wall Duration
  my $wallDuration = $job->findvalue("//WallDuration");
  if ($wallDuration ne "")
  {
    delete $attributes{WallDuration};
    push @assignments, new Gold::Assignment(name => "WallDuration", value => $wallDuration);
    $startTime = $now - $wallDuration;
  }
  else
  {
    return new Gold::Response()->failure("314", "A wall duration must be specified for the charge");
  }
  if ($wallDuration !~ /^\d+$/)
  {
    return new Gold::Response()->failure("314", "The wall duration must be an integer number of seconds");
  }

  # Start Time
  my $start = $job->findvalue("//StartTime");
  if ($start ne "")
  {
    delete $attributes{StartTime};
    push @assignments, new Gold::Assignment(name => "StartTime", value => $start);
    $startTime = $start;
  }

  # End Time
  my $end = $job->findvalue("//EndTime");
  if ($end ne "")
  {
    delete $attributes{EndTime};
    push @assignments, new Gold::Assignment(name => "EndTime", value => $end);
    $endTime = $end;
  }

  # Look for Charge
  my $charge = $job->findvalue("//Charge");
  my $itemizedCharges;

  # Quote Id
  my $quoteId = $job->findvalue("//QuoteId");
  my $id = "";
  if ($quoteId ne "")
  {
    # Check to see if the quote exists and is not expired or used up
    # SELECT Job FROM Quotation WHERE Id=$quoteId AND Uses>0 AND StartTime<=$endTime AND EndTime>$endTime
    my $subResults = $database->select(object => "Quotation", selections => [ new Gold::Selection(name => "Job") ], conditions => [ new Gold::Condition(name => "Id", value => $quoteId), new Gold::Condition(name => "Uses", value => "0", op => "GT"), new Gold::Condition(name => "StartTime", value => $endTime, op => "LE"), new Gold::Condition(name => "EndTime", value => $endTime, op => "GT") ]);
    if (@{$subResults->{data}})
    {
      $id = ${$subResults->{data}}[0]->[0];

      # Decrement the quotation uses field
      my $subRequest = new Gold::Request(database => $database, object => "Quotation", action => "Modify", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Uses", value => 1, op => "Dec") ], conditions => [  new Gold::Condition(name => "Id", value => $quoteId) ]);
      my $subResponse = Gold::Base->modify($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to modify quotation: " . $subResponse->getMessage());
      }

      if (exists $attributes{QuoteId})
      {
        delete $attributes{'QuoteId'};
        push @assignments, new Gold::Assignment(name => "QuoteId", value => $quoteId);
      }
    }
    else
    {
      # Nullify the quoteId if absent, expired or used
      $quoteMessage .= "\nWarning: Quote ($quoteId) is invalid and cannot be used";
      $quoteId = "";
    }
  }

  # Look for reservations for this job to obtain the list of reserved
  # allocations and its job id
  # This has to happen here to obtain its jobid
  # SELECT ReservationAllocation.Id,ReservationAllocation.Account,ReservationAllocation.Amount,Reservation.Job,Allocation.StartTime,Allocation.EndTime FROM Reservation,ReservationAllocation,Allocation WHERE Reservation.Id=ReservationAllocation.Reservation AND Reservation.Name=$jobId AND ReservationAllocation.Id=Allocation.Id
  my %allocations = ();
  $results = $database->select(objects => [ new Gold::Object(name => "Reservation"), new Gold::Object(name => "ReservationAllocation"), new Gold::Object(name => "Allocation") ], selections => [ new Gold::Selection(object => "ReservationAllocation", name => "Id"), new Gold::Selection(object => "ReservationAllocation", name => "Account"), new Gold::Selection(object => "ReservationAllocation", name => "Amount"), new Gold::Selection(object => "Reservation", name => "Job"), new Gold::Selection(object => "Allocation", name => "StartTime"), new Gold::Selection(object => "Allocation", name => "EndTime") ], conditions => [ new Gold::Condition(object => "Reservation", name => "Id", subject => "ReservationAllocation", value => "Reservation"), new Gold::Condition(object => "ReservationAllocation", name => "Id", subject => "Allocation", value => "Id"), new Gold::Condition(object => "Reservation", name => "Name", value => $jobId) ]);
  foreach my $row (@{$results->{data}})
  {
    my $allocationId = $row->[0];
    my $accountId = $row->[1];
    my $amount = $row->[2];
    my $job = $row->[3];
    my $startTime = $row->[4];
    my $endTime = $row->[5];

    $allocations{$allocationId}{balance} += $amount;
    $allocations{$allocationId}{account} = $accountId;
    $allocations{$allocationId}{startTime} = $startTime;
    $allocations{$allocationId}{endTime} = $endTime;
    $allocations{$allocationId}{weight} = 1000000 * $endTime;
    $id = $job;
  }

  # Create a new job if one does not already exist
  if ($id eq "")
  {
    # Create a new job record
    my $subRequest = new Gold::Request(database => $database, object => "Job", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Charge", value => 0) ], options => [ new Gold::Option(name => "JobId", value => $jobId) ]);
    my $subResponse = Gold::Base->create($subRequest, $requestId);
    if ($subResponse->getStatus() eq "Failure")
    {
      return new Gold::Response()->failure($subResponse->getCode(), "Unable to create job record: " . $subResponse->getMessage());
    }

    # Figure out the id of the job we just created
    $id = $subResponse->getDatumValue("Id");
  }

  # Calculate charge if not already specified
  if ($charge eq "")
  {
    $charge = 0;
	  # Look up the current charge rates
	  # SELECT Type,Name,Rate FROM ChargeRate
	  my %chargeRate = ();
	  $results = $database->select(object => "ChargeRate", selections => [ new Gold::Selection(name => "Type"), new Gold::Selection(name => "Name"), new Gold::Selection(name => "Rate") ]);
	  foreach my $row (@{$results->{data}})
	  {
	    my $type = $row->[0];
	    my $name = $row->[1];
	    my $rate = $row->[2];
	
	    $chargeRate{$type}{$name} = $rate;
	  }
	
	  # Override with quoted charge rates
	  if ($quoteId ne "")
	  {
	    # Look up the quoted charge rates
	    # SELECT Type,Name,Rate FROM QuotationChargeRate WHERE Quotation=$quoteId
	    my $results = $database->select(object => "QuotationChargeRate", selections => [ new Gold::Selection(name => "Type"), new Gold::Selection(name => "Name"), new Gold::Selection(name => "Rate") ], conditions => [ new Gold::Condition(name => "Quotation", value => $quoteId) ]);
	    foreach my $row (@{$results->{data}})
	    {
	      my $type = $row->[0];
	      my $name = $row->[1];
	      my $rate = $row->[2];
	
	      $chargeRate{$type}{$name} = $rate;
	    }
	  }
	    
	  # Iterate over the charge multipliers
	  my $multiplier = 1;
	  my @multiplierCharges = ( "$wallDuration [WallDuration]" );
	  foreach my $type (keys %chargeRate)
	  {
	    next if $type eq "Resource";
	
	    # Look for this charge type in the job properties
	    my $name = $job->findvalue("//$type");
	    if ($name ne "")
	    {
	      if (exists $chargeRate{$type}{$name})
	      {
	        $multiplier *= $chargeRate{$type}{$name};
	        push @multiplierCharges, "$chargeRate{$type}{$name} [ChargeRate{$type}{$name}]";
	      }
	      else
	      {
	        $chargeMessage .= "\nWarning: ChargeRate for $type $name is not defined";
	      }
	
	      if (exists $attributes{$type})
	      {
	        delete $attributes{$type};
	        push @assignments, new Gold::Assignment(name => "$type", value => $name);
	      }
	    }
	  }
	
	  # Iterate over the consumable resources
	  my @resourceCharges = ();
	  foreach my $name (keys %{$chargeRate{Resource}})
	  {
	    # Look for this resource in the job properties
	    my $amount = $job->findvalue("//$name");
	    if ($amount ne "")
	    {
	      # Calculate charge
	      my $rate = $chargeRate{Resource}{$name};
	      my $subCharge = $amount * $rate * $wallDuration * $multiplier;
	      $charge = $charge + $subCharge;
	      push @resourceCharges, "( $amount [$name] * $rate [ChargeRate{Resource}{$name}] )";
	  
	      if (exists $attributes{$name})
	      {
	        delete $attributes{$name};
	        push @assignments, new Gold::Assignment(name => "$name", value => $amount);
	      }
	    }
	  }
	
	  $itemizedCharges = "( " . join(' + ', @resourceCharges) . " ) * " . join(' * ', @multiplierCharges) . " = $charge";
  }

  # If Charge is not included in job properties,
  # look for itemized charges in an option
  else
  {
    $itemizedCharges = $request->getOptionValue("ItemizedCharges");
    if (! defined $itemizedCharges)
    {
      $itemizedCharges = "$charge [externally calculated] = $charge";
    }
  }
  
  # Process the remaining job attributes
  foreach my $name (keys %attributes)
  {
    my $value = $job->findvalue("//$name");
    if ($value ne "")
    {
      delete $attributes{$name};
      push @assignments, new Gold::Assignment(name => "$name", value => $value);
    }
  }

  # Charge the account(s)
  if ($charge > 0)
  {
    my $remaining = $charge;
    my %accounts = ();

    # Refresh Allocations
    my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Refresh");
    my $subResponse = Gold::Bank->refresh($subRequest, $requestId);
    if ($subResponse->getStatus() eq "Failure")
    {
      return new Gold::Response()->failure($subResponse->getCode(), "Failed while refreshing allocations: " . $subResponse->getMessage());
    }
    
    # Construct list of viable accounts
    {
      # SELECT Account.Id,AccountProject.Name,AccountUser.Name,AccountMachine.Name FROM Account,AccountUser,AccountProject,AccountMachine,Allocation WHERE Allocation.StartTime<=$endTime AND Allocation.EndTime>$endTime AND Allocation.CallType=$callType AND AccountProject.Account=Account.Id AND AccountUser.Account=Account.Id AND AccountMachine.Account=Account.Id AND Allocation.Account=Account.Id
    
      my @objects =
      (
        new Gold::Object(name => "Account"),
        new Gold::Object(name => "AccountUser"),
        new Gold::Object(name => "AccountProject"),
        new Gold::Object(name => "AccountMachine"),
        new Gold::Object(name => "Allocation"),
      );
    
      my @selections =
      (
        new Gold::Selection(object => "Account", name => "Id"),
        new Gold::Selection(object => "AccountProject", name => "Name"),
        new Gold::Selection(object => "AccountUser", name => "Name"),
        new Gold::Selection(object => "AccountMachine", name => "Name")
      );
    
      my @conditions =
      (
        new Gold::Condition(object => "Allocation", name => "Account", subject => "Account", value => "Id"),
        new Gold::Condition(object => "AccountProject", name => "Account", subject => "Account", value => "Id"),
        new Gold::Condition(object => "AccountUser", name => "Account", subject => "Account", value => "Id"),
        new Gold::Condition(object => "AccountMachine", name => "Account", subject => "Account", value => "Id"),

        # Allocation conditions
        new Gold::Condition(object => "Allocation", name => "CallType", value => $callType),
      	new Gold::Condition(object => "Allocation", name => "StartTime", value => $now, op => "LE"),
      	new Gold::Condition(object => "Allocation", name => "EndTime", value => $now, op => "GT"),
        
        # Project conditions
        new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+3"),
        new Gold::Condition(object => "AccountProject", name => "Access", value => "True", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountProject", name => "Name", value => $project, conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountProject", name => "Access", value => "True", conj => "And", group => "-2"),

        # User conditions
        new Gold::Condition(object => "AccountUser", name => "Name", value => "ANY", conj => "And", group => "+2"),
        new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountUser", name => "Name", value => $user, conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountUser", name => "Name", value => "MEMBERS", conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-2"),

        # Machine conditions
        new Gold::Condition(object => "AccountMachine", name => "Name", value => "ANY", conj => "And", group => "+2"),
        new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountMachine", name => "Name", value => $machine, conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountMachine", name => "Name", value => "MEMBERS", conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-3"),
      );
    
      my $results = $database->select(objects => \@objects, selections => \@selections, conditions => \@conditions);
      foreach my $row (@{$results->{data}})
      {
        my $accountId = $row->[0];
        my $accountProject = $row->[1];
        my $accountUser = $row->[2];
        my $accountMachine = $row->[3];
        
        # Check membership
        if ($accountUser eq "MEMBERS" || $accountMachine eq "MEMBERS")
        {
          my @selections = ();
          my @conditions = ();
          my @objects = ();
          
          if ($accountUser eq "MEMBERS")
          {
            push @selections, new Gold::Selection(object => "ProjectUser", name => "Project");
            push @objects, new Gold::Object(name => "ProjectUser");
            if (defined $user)
            {
              push @conditions, new Gold::Condition(object => "ProjectUser", name => "Name", value => $user);
            }
            push @conditions, new Gold::Condition(object => "ProjectUser", name => "Active", value => "True");
            if ($accountProject ne "ANY")
            {
              push @conditions, new Gold::Condition(object => "ProjectUser", name => "Project", value => $accountProject);
            }
          }
    
          if ($accountMachine eq "MEMBERS")
          {
            push @selections, new Gold::Selection(object => "ProjectMachine", name => "Project");
            push @objects, new Gold::Object(name => "ProjectMachine");
            if (defined $machine)
            {
              push @conditions, new Gold::Condition(object => "ProjectMachine", name => "Name", value => $machine);
            }
            push @conditions, new Gold::Condition(object => "ProjectMachine", name => "Active", value => "True");
            if ($accountProject ne "ANY")
            {
              push @conditions, new Gold::Condition(object => "ProjectMachine", name => "Project", value => $accountProject);
            }
          }
    
          if ($accountUser eq "MEMBERS" && $accountMachine eq "MEMBERS")
          {
            push @conditions, new Gold::Condition(object => "ProjectUser", name => "Project", subject => "ProjectMachine", value => "Project");
          }
    
          # If there is a matching member found, add the account
          my $subResults = $database->select(objects => \@objects, selections => \@selections, conditions => \@conditions);
          if (@{$subResults->{data}})
          {
            # We need to rank accounts by how specific they are
            my $weight = 100 * generality($accountProject) + 10 * generality($accountUser) + generality($accountMachine);
            if (! exists $accounts{$accountId} || $weight < $accounts{$accountId})
            {
              $accounts{$accountId} = $weight;
            }
          }
        }
        
        # Otherwise just add the account
        else 
        {
          # We need to rank accounts by how specific they are
          my $weight = 100 * generality($accountProject) + 10 * generality($accountUser) + generality($accountMachine);
          if (! exists $accounts{$accountId} || $weight < $accounts{$accountId})
          {
            $accounts{$accountId} = $weight;
          }
        }
      }
    
      if ($log->is_debug())
      {
        $log->debug("Initial accepted charge account list is: " . join ',', keys %accounts);
      }
    }
  
    # Only screen these accounts if there are some to do so to
    if (scalar keys %accounts)
    {
      # Check to make sure these accounts are not rejected
      # SELECT DISTINCT Account.Id FROM Account,AccountUser,AccountProject,AccountMachine WHERE AccountProject.Account=Account.Id AND AccountUser.Account=Account.Id AND AccountMachine.Account=Account.Id AND <Id IN AccountList>
  
      my @objects =
      (
        new Gold::Object(name => "Account"),
        new Gold::Object(name => "AccountUser"),
        new Gold::Object(name => "AccountProject"),
        new Gold::Object(name => "AccountMachine")
      );
    
      my @selections = ( new Gold::Selection(object => "Account", name => "Id") );
    
      my @conditions =
      (
        new Gold::Condition(object => "AccountProject", name => "Account", subject => "Account", value => "Id"),
        new Gold::Condition(object => "AccountUser", name => "Account", subject => "Account", value => "Id"),
        new Gold::Condition(object => "AccountMachine", name => "Account", subject => "Account", value => "Id"),

        # Project conditions
        new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+3"),
        new Gold::Condition(object => "AccountProject", name => "Access", value => "False", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountProject", name => "Name", value => $project, conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountProject", name => "Access", value => "False", conj => "And", group => "-2"),
    
        # User conditions
        new Gold::Condition(object => "AccountUser", name => "Name", value => "ANY", conj => "Or", group => "+2"),
        new Gold::Condition(object => "AccountUser", name => "Access", value => "False", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountUser", name => "Name", value => $user, conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountUser", name => "Access", value => "False", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountUser", name => "Name", value => "MEMBERS", conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountUser", name => "Access", value => "False", conj => "And", group => "-2"),

        # Machine conditions
        new Gold::Condition(object => "AccountMachine", name => "Name", value => "ANY", conj => "Or", group => "+2"),
        new Gold::Condition(object => "AccountMachine", name => "Access", value => "False", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountMachine", name => "Name", value => $machine, conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountMachine", name => "Access", value => "False", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountMachine", name => "Name", value => "MEMBERS", conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountMachine", name => "Access", value => "False", conj => "And", group => "-3"),
      );
    
      my @options = ( new Gold::Option(name => "Unique", value => "True") );
  
      # Constrain to list of accepted ids
      my $firstTime = 1;
      my $counter = 0;
      foreach my $id (keys %accounts)
      {
        $counter++;
        my $lastTime = ($counter == scalar keys %accounts) ? 1 : 0;
  
        if ($firstTime && $lastTime)
        {
          push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "And", group => "0");
        }
        elsif ($firstTime)
        {
          $firstTime = 0;
          push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "And", group => "+1");
        }
        elsif ($lastTime)
        {
          push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "Or", group => "-1");
        }
        else
        {
          push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "Or", group => "0");
        }
      }
  
      my $results = $database->select(objects => \@objects, selections => \@selections, conditions => \@conditions, options => \@options);
      foreach my $row (@{$results->{data}})
      {
        my $accountId = $row->[0];
  
        # Remove from accounts
        delete $accounts{$accountId};
      }
  
      if ($log->is_debug())
      {
        $log->debug("Post rejection charge account list is: " . join ',', keys %accounts);
      }
    }
  
    # Add ancestor accounts
    # Build up account linkages
    my %ancestors = ();
    # SELECT Account,Id FROM AccountAccount WHERE Overflow=True
  
    my @selections =
    (
      new Gold::Selection(name => "Account"),
      new Gold::Selection(name => "Id"),
    );
  
    my @conditions =
    (
      new Gold::Condition(name => "Overflow", value => "True")
    );
  
    my $results = $database->select(object => "AccountAccount", selections => \@selections, conditions => \@conditions);
    foreach my $row (@{$results->{data}})
    {
      my $parent = $row->[0];
      my $child = $row->[1];
  
      $ancestors{$child}{$parent} = 1;
    }
  
    # Add ancestors a generation at a time until there is no more growth
    my $distance = 100;
    while (1)
    {
      $distance *= 10;
      my $count = scalar keys %accounts;
      foreach my $account (keys %accounts)
      {
        foreach my $parent (keys %{$ancestors{$account}})
        {
          $accounts{$parent} = $distance unless exists $accounts{$parent};
        }
      }
      last if $count == scalar keys %accounts;
    }
  
    if ($log->is_debug())
    {
      $log->debug("Post ancestral account list is: " . join ',', keys %accounts);
    }
  
    if (scalar keys %accounts)
    {
      # Lookup active allocations from account list
      # SELECT Id,Account,Amount,CreditLimit,StartTime,EndTime FROM Allocation WHERE StartTime<=$now AND EndTime>$now AND CallType=$callType AND (Account=<Id> ...)
    
      @selections =
      (
        new Gold::Selection(name => "Id"),
        new Gold::Selection(name => "Account"),
        new Gold::Selection(name => "Amount"),
        new Gold::Selection(name => "CreditLimit"),
        new Gold::Selection(name => "StartTime"),
        new Gold::Selection(name => "EndTime"),
      );
    
      @conditions =
      (
        new Gold::Condition(name => "CallType", value => $callType),
        new Gold::Condition(name => "StartTime", value => $now, op => "LE"),
        new Gold::Condition(name => "EndTime", value => $now, op => "GT")
      );
    
      # Constrain to list of accepted ids
      my $firstTime = 1;
      my $counter = 0;
      foreach my $id (keys %accounts)
      {
        $counter++;
        my $lastTime = ($counter == scalar keys %accounts) ? 1 : 0;
    
        if ($firstTime && $lastTime)
        {
          push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "And", group => "0");
        }
        elsif ($firstTime)
        {
          $firstTime = 0;
          push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "And", group => "+1");
        }
        elsif ($lastTime)
        {
          push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "Or", group => "-1");
        }
        else
        {
          push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "Or", group => "0");
        }
      }
  
      $results = $database->select(object => "Allocation", selections => \@selections, conditions => \@conditions);
      foreach my $row (@{$results->{data}})
      {
        my $allocationId = $row->[0];
        my $accountId = $row->[1];
        my $allocationAmount = $row->[2];
        my $allocationCreditLimit = $row->[3];
        my $allocationStartTime = $row->[4];
        my $allocationEndTime = $row->[5];
        
        $allocations{$allocationId}{account} = $accountId;
        $allocations{$allocationId}{endTime} = $allocationEndTime;
        $allocations{$allocationId}{startTime} = $allocationStartTime;
        $allocations{$allocationId}{weight} ||= $distance * $allocationEndTime + $accounts{$accountId};
        $allocations{$allocationId}{balance} += $allocationAmount + $allocationCreditLimit;
      }
    
      # Subtract reservations from allocation balances (including my own)
      # Lookup reservation amounts against these allocations
      # SELECT ReservationAllocation.Id,ReservationAllocation.Amount FROM Reservation,ReservationAllocation WHERE Reservation.Id=ReservationAllocation.Reservation AND Reservation.StartTime<=$now AND Reservation.EndTime>$now AND (Account=<Id> ...)
    
      my @objects =
      (
        new Gold::Object(name => "Reservation"),
        new Gold::Object(name => "ReservationAllocation"),
      );
  
      @selections =
      (
        new Gold::Selection(object => "ReservationAllocation", name => "Id"),
        new Gold::Selection(object => "ReservationAllocation", name => "Amount"),
      );
    
      @conditions =
      (
        new Gold::Condition(object => "Reservation", name => "Id", subject => "ReservationAllocation", value => "Reservation"),
        new Gold::Condition(object => "Reservation", name => "StartTime", value => $now, op => "LE"),
        new Gold::Condition(object => "Reservation", name => "EndTime", value => $now, op => "GT"),
      );
    
      # Constrain to list of accepted allocation ids
      $firstTime = 1;
      $counter = 0;
      foreach my $id (keys %allocations)
      {
        $counter++;
        my $lastTime = ($counter == scalar keys %allocations) ? 1 : 0;
    
        if ($firstTime && $lastTime)
        {
          push @conditions, new Gold::Condition(object => "ReservationAllocation", name => "Id", value => $id, conj => "And", group => "0");
        }
        elsif ($firstTime)
        {
          $firstTime = 0;
          push @conditions, new Gold::Condition(object => "ReservationAllocation", name => "Id", value => $id, conj => "And", group => "+1");
        }
        elsif ($lastTime)
        {
          push @conditions, new Gold::Condition(object => "ReservationAllocation", name => "Id", value => $id, conj => "Or", group => "-1");
        }
        else
        {
          push @conditions, new Gold::Condition(object => "ReservationAllocation", name => "Id", value => $id, conj => "Or", group => "0");
        }
      }
    
      $results = $database->select(objects => \@objects, selections => \@selections, conditions => \@conditions);
      foreach my $row (@{$results->{data}})
      {
        my $allocationId = $row->[0];
        my $reservationAmount = $row->[1];
        
        if (exists $allocations{$allocationId})
        {
          $allocations{$allocationId}{balance} -= $reservationAmount;
        }
      }
    }
  
    # Fail if there are no allocations to withdraw from
    if (! scalar keys %allocations)
    {
      return new Gold::Response()->failure("782", "Insufficient funds: There are no valid allocations against which to issue the charge");
    }

    # Sort the allocations by weight
    my @allocations = sort { $allocations{$a}{weight} <=> $allocations{$b}{weight} } keys %allocations;
  
    # Iterate through the allocation list
    foreach my $allocationId (@allocations)
    {
      # Break out if we are done
      last if $remaining <= 0;

      # The amount I subtract from this allocation should be the minimum of:
      # 1. $remaining (the amount left to withdraw)
      # 2. $allocations{$allocationId}{balance} (the amount available within this allocation (considering reservations and credit))
      my $accountId = $allocations{$allocationId}{account};
      my $debitAmount = min($remaining, $allocations{$allocationId}{balance});
      next unless $debitAmount > 0;
  
      # Debit the allocation
      my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Modify", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Amount", value => $debitAmount, op => "Dec") ], conditions => [ new Gold::Condition(name => "Id", value => $allocationId) ]);
      my $subResponse = Gold::Base->modify($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to debit allocation: " . $subResponse->getMessage());
      }
  
      # Log the transaction
      my $delta = 0;
      if ($allocations{$allocationId}{startTime} <= $now && $allocations{$allocationId}{endTime} > $now)
      {
        $delta = 0 - $debitAmount;
      }
      Gold::Bank->logTransaction(database => $database, requestId => $requestId, txnId => $database->nextId("Transaction"), object => "Job", action => "Charge", actor => $actor, options => [ new Gold::Option(name => "Amount", value => $debitAmount), new Gold::Option(name => "Id", value => $id), new Gold::Option(name => "Child", value => $jobId), new Gold::Option(name => "ItemizedCharges", value => $itemizedCharges) ], assignments => \@assignments, count => 1, account => $accountId, delta => $delta, allocation => $allocationId);
      $remaining -= $debitAmount;
      $charges{$accountId} += $debitAmount;
    }
  
    # Allow first allocation to go negative if charges remaining
    if ($remaining > 0)
    {
      my $allocationId = $allocations[0];
      my $accountId = $allocations{$allocationId}{account};
      my $debitAmount = $remaining;

      # Debit the allocation
      my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Modify", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Amount", value => $debitAmount, op => "Dec") ], conditions => [ new Gold::Condition(name => "Id", value => $allocationId) ]);
      my $subResponse = Gold::Base->modify($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to debit allocation: " . $subResponse->getMessage());
      }

      # Log the transaction
      my $delta = 0;
      if ($allocations{$allocationId}{startTime} <= $now && $allocations{$allocationId}{endTime} > $now)
      {
        $delta = 0 - $debitAmount;
      }
      Gold::Bank->logTransaction(database => $database, requestId => $requestId, txnId => $database->nextId("Transaction"), object => "Job", action => "Charge", actor => $actor, options => [ new Gold::Option(name => "Amount", value => $debitAmount), new Gold::Option(name => "Id", value => $id), new Gold::Option(name => "Child", value => $jobId), new Gold::Option(name => "ItemizedCharges", value => $itemizedCharges) ], assignments => \@assignments, count => 1, account => $accountId, delta => $delta, allocation => $allocationId);
      $remaining -= $debitAmount;
      $charges{$accountId} += $debitAmount;
    }
  }

  # Log the transaction for the case where charge is zero
  else
  {
    Gold::Bank->logTransaction(database => $database, requestId => $requestId, txnId => $database->nextId("Transaction"), object => "Job", action => "Charge", options => [ new Gold::Option(name => "Amount", value => 0), new Gold::Option(name => "Id", value => $id), new Gold::Option(name => "Child", value => $jobId) ], assignments => \@assignments, actor => $actor, count => 1, delta => 0);
  }

  # Remove the reservations -- this should also remove ReservationAllocations
  # DELETE FROM Reservation WHERE JobId=$jobId AND CallType=$callType
  my $subRequest = new Gold::Request(database => $database, object => "Reservation", action => "Delete", actor => $config->get_property("super.user", $SUPER_USER), conditions => [ new Gold::Condition(name => "Name", value => $jobId), new Gold::Condition(name => "CallType", value => $callType) ]);
  my $subResponse = Gold::Base->delete($subRequest, $requestId);
  if ($subResponse->getStatus() eq "Failure")
  {
    return new Gold::Response()->failure($subResponse->getCode(), "Unable to delete reservations: " . $subResponse->getMessage());
  }
  my $count = $subResponse->getCount();
  if ($count)
  {
    $reserveMessage .= "\n$count reservations were removed";
  }
  
  # Modify the job record with charge and other attributes
  push @assignments, new Gold::Assignment(name => "Stage", value => "Charge");
  push @assignments, new Gold::Assignment(name => "Charge", value => $charge, op => "Inc");
  push @assignments, new Gold::Assignment(name => "CallType", value => $callType);
  $subRequest = new Gold::Request(database => $database, object => "Job", action => "Modify", actor => $config->get_property("super.user", $SUPER_USER), conditions => [ new Gold::Condition(name => "Id", value => $id) ], options => [ new Gold::Option(name => "JobId", value => $jobId) ], assignments => \@assignments);
  $subResponse = Gold::Base->modify($subRequest, $requestId);
  if ($subResponse->getStatus() eq "Failure")
  {
    return new Gold::Response()->failure($subResponse->getCode(), "Unable to modify job record: " . $subResponse->getMessage());
  }

  my $time_division = defined $request->getOptionValue("ShowHours") ? 3600 : 1;
  my $currency_precision = $config->get_property("currency.precision", 0);
  $charge = sprintf("%.${currency_precision}f", $charge / $time_division);

  # Charge Back if BackHost option is specified and CallType is Normal
  my $backHost = $request->getOptionValue("BackHost");
  if (defined $backHost && $callType eq "Normal")
  {
    my $backPort = $request->getOptionValue("BackPort") || 7112;

    # Update the (cloned) job data with the charge (for charge back)
    my $dataClone = $data->cloneNode(1);
    my @jobClones = $dataClone->getChildrenByTagName("Job");
    my $chargeElement = new XML::LibXML::Element("Charge");
    $chargeElement->appendText($charge);
    $jobClones[0]->appendChild($chargeElement);

    # Build Back Charge Request
    my $backRequest = new Gold::Request(object => "Job", action => "Charge");
    $backRequest->setDataElement($dataClone);
    $backRequest->setOption("CallType", "Back");
    $backRequest->setOption("BackProject", $backProject) if defined $backProject;
    $backRequest->setOption("BackUser", $backUser) if defined $backUser;
    $backRequest->setOption("BackMachine", $backMachine) if defined $backMachine;
    $backRequest->setOption("ItemizedCharges", $itemizedCharges);

    # Use long form of message send in order to specify alternate host and port
    my $messageChunk = new Gold::Chunk()->setRequest($backRequest);
    my $message = new Gold::Message();
    $message->sendChunk($messageChunk, $backHost, $backPort);
    my $reply = $message->getReply();
    my $replyChunk = $reply->receiveChunk(); 
    my $backResponse = $replyChunk->getResponse();
    $backMessage = "\nBack Charge: " . $backResponse->getMessage();
  }

  # Charge Forward if this is a forwarding account
  foreach my $accountId (keys %charges)
  {
    my $results = $database->select(objects => [ new Gold::Object(name => "AccountOrganization"), new Gold::Object(name => "Organization") ], selections => [ new Gold::Selection(object => "AccountOrganization", name => "Name"), new Gold::Selection(object => "AccountOrganization", name => "User"), new Gold::Selection(object => "AccountOrganization", name => "Project"), new Gold::Selection(object => "AccountOrganization", name => "Machine"), new Gold::Selection(object => "Organization", name => "Host"), new Gold::Selection(object => "Organization", name => "Port") ], conditions => [ new Gold::Condition(name => "Account", value => $accountId), new Gold::Condition(object => "AccountOrganization", name => "Name", subject => "Organization", value => "Name") ]);
    foreach my $row (@{$results->{data}})
    {
      my $organization = $row->[0];
      my $forwardUser = $row->[1];
      my $forwardProject = $row->[2];
      my $forwardMachine = $row->[3];
      my $forwardHost = $row->[4];
      my $forwardPort = $row->[5] || 7112;

      # Update the (cloned) job data with the charge (for charge forward)
      my $dataClone = $data->cloneNode(1);
      my @jobClones = $dataClone->getChildrenByTagName("Job");
      my $chargeElement = new XML::LibXML::Element("Charge");
      $chargeElement->appendText($charges{$accountId});
      $jobClones[0]->appendChild($chargeElement);

      # Build Forward Charge Request
      my $forwardRequest = new Gold::Request(object => "Job", action => "Charge");
      $forwardRequest->setDataElement($dataClone);
      $forwardRequest->setOption("CallType", "Forward");
      $forwardRequest->setOption("ForwardProject", $forwardProject) if defined $forwardProject;
      $forwardRequest->setOption("ForwardUser", $forwardUser) if defined $forwardUser;
      $forwardRequest->setOption("ForwardMachine", $forwardMachine) if defined $forwardMachine;
      $forwardRequest->setOption("ItemizedCharges", $itemizedCharges);
  
      # Use long form of message send in order to specify alternate host and port
      my $messageChunk = new Gold::Chunk()->setRequest($forwardRequest);
      my $message = new Gold::Message();
      $message->sendChunk($messageChunk, $forwardHost, $forwardPort);
      my $reply = $message->getReply();
      my $replyChunk = $reply->receiveChunk(); 
      my $forwardResponse = $replyChunk->getResponse();
      $forwardMessage .= "\nForward Charge ($organization): " . $forwardResponse->getMessage();
    }
  }

  my $message = "Successfully charged job $jobId for $charge credits" . $quoteMessage . $reserveMessage . $chargeMessage . $backMessage . $forwardMessage;
  my $response =  new Gold::Response()->success($charge, $message);

  # Add data to response
  my $datum = new Gold::Datum("Charge");
  $datum->setValue("Amount", $charge);
  $datum->setValue("Job", $id);
  $response->setDatum($datum);

  return $response;
}
  

# ----------------------------------------------------------------------------
# $response = create($request, $requestId);
# ----------------------------------------------------------------------------

# Create (AccountAccount, Allocation, Project)
sub create
{
  my ($class, $request, $requestId) = @_;

  if ($log->is_debug())
  {
    $log->debug("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my $object = $request->getObject();
  my $database = $request->getDatabase();
  my $now = time;

  # AccountAccount
  if ($object eq "AccountAccount")
  {
    my $depositShare = $request->getAssignmentValue("DepositShare");

    if (defined $depositShare)
    {
      # Make sure deposit shares do not exceed 100 for a given account
      my $account = $request->getAssignmentValue("Account");
      my $depositShareTotal = $depositShare;

      my $results = $database->select(object => "AccountAccount", selections => [ new Gold::Selection(name => "DepositShare", op => "Sum") ], conditions => [ new Gold::Condition(name => "Account", value => $account) ]);
      my $depositShareSum = ${$results->{data}}[0]->[0];
      if (defined $depositShareSum) 
      {
        $depositShareTotal += $depositShareSum;
      }
      if ($depositShareTotal > 100)
      {
        return new Gold::Response()->failure("740", "Total deposit shares for an account cannot exceed 100% ($depositShareTotal)");
      }
    }

    # Invoke base AccountAccount Create
    my $baseResponse = Gold::Base->create($request, $requestId);

    return $baseResponse;
  }

  # Allocation
  elsif ($object eq "Allocation")
  {
    # Allocations should only be created via Account Deposit
    return new Gold::Response()->failure("740", "Invoking Allocation Create directly is not allowed because it bypasses accounting. Use Account Deposit instead.");
  }

  # Project
  elsif ($object eq "Project")
  {
    my $createAccount = 0;
    my $createAccountOption = $request->getOptionValue("CreateAccount");

    # Invoke base Project Create
    my $baseResponse = Gold::Base->create($request, $requestId);
    my $baseMessage = $baseResponse->getMessage();

    # Determine if we should create a default account
    if ($baseResponse->getStatus() eq "Success")
    {
      if ($config->get_property("account.autogen", $ACCOUNT_AUTOGEN) =~ /true/i)
      {
        if (! defined $createAccountOption || $createAccountOption !~ /^False$/i)
        {
          # Autogen and CreateAccount is not False
          $createAccount = 1;
        }
      }
      else
      {
        if (defined $createAccountOption && $createAccountOption =~ /^True$/i)
        {
          # No autogen but CreateAccount is True
          $createAccount = 1;
        }
      }
    }
      
    # Create a default account if we resolved to do so
    if ($createAccount)
    {
      my $project = $request->getAssignmentValue("Name");

      # Create the account
      my $subRequest = new Gold::Request
      (
        database => $database, object => "Account",
        action => "Create",
        actor => $config->get_property("super.user", $SUPER_USER),
        assignments =>
        [
          new Gold::Assignment(name => "Name", value => $project),
          new Gold::Assignment(name => "Description", value => "Auto-generated")
        ]
      );
      my $subResponse = Gold::Base->create($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to create account: " . $subResponse->getMessage());
      }

      # Figure out the id of the account we just created
      my $account = $subResponse->getDatumValue("Id");

      if ($subResponse->getStatus() eq "Success")
      {
        $baseMessage .= "\nAuto-generated Account $account";

        # Add AccountProject
        $subRequest = new Gold::Request
        (
          database => $database, object => "AccountProject",
          action => "Create",
          actor => $config->get_property("super.user", $SUPER_USER),
          assignments =>
          [
            new Gold::Assignment(name => "Account", value => $account),
            new Gold::Assignment(name => "Name", value => $project)
          ]
        );
        $subResponse = Gold::Base->create($subRequest, $requestId);
        if ($subResponse->getStatus() eq "Failure")
        {
          return new Gold::Response()->failure($subResponse->getCode(), "Unable to create account project: " . $subResponse->getMessage());
        }

        # Add AccountUser
        $subRequest = new Gold::Request
        (
          database => $database, object => "AccountUser",
          action => "Create",
          actor => $config->get_property("super.user", $SUPER_USER),
          assignments =>
          [
            new Gold::Assignment(name => "Account", value => $account),
            new Gold::Assignment(name => "Name", value => "MEMBERS")
          ]
        );
        $subResponse = Gold::Base->create($subRequest, $requestId);
        if ($subResponse->getStatus() eq "Failure")
        {
          return new Gold::Response()->failure($subResponse->getCode(), "Unable to create account user: " . $subResponse->getMessage());
        }

        # Add AccountMachine
        $subRequest = new Gold::Request
        (
          database => $database, object => "AccountMachine",
          action => "Create",
          actor => $config->get_property("super.user", $SUPER_USER),
          assignments =>
          [
            new Gold::Assignment(name => "Account", value => $account),
            new Gold::Assignment(name => "Name", value => "ANY")
          ]
        );
        $subResponse = Gold::Base->create($subRequest, $requestId);
        if ($subResponse->getStatus() eq "Failure")
        {
          return new Gold::Response()->failure($subResponse->getCode(), "Unable to create account machine: " . $subResponse->getMessage());
        }
      }
      else
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to create account: " . $subResponse->getMessage());
      }
    }

    return $baseResponse->setMessage($baseMessage);
  }

  else
  {
    return new Gold::Response()->failure("315", "The Bank class does not implement $object Create");
  }
}


# ----------------------------------------------------------------------------
# $response = delete($request, $requestId);
# ----------------------------------------------------------------------------

# Delete (Account, Allocation)
sub delete
{
  my ($class, $request, $requestId) = @_;

  if ($log->is_debug())
  {
    $log->debug("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my $object = $request->getObject();
  my $actor = $request->getActor();
  my $database = $request->getDatabase();
  my @conditions = $request->getConditions();
  my @options = $request->getOptions();
  my $now = time;

  if ($object eq "Account")
  {
    # Get a list of accounts to be deleted
    # SELECT Id FROM Account WHERE <Conditions>
    my $results = $database->select(object => "Account", selections => [ new Gold::Selection(name => "Id") ], conditions => \@conditions);
    foreach my $row (@{$results->{data}})
    {
      my $id = $row->[0];

      # Delete all allocations associated with this account
      # DELETE FROM Allocation WHERE Account=$id
      my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Delete", actor => $config->get_property("super.user", $SUPER_USER), conditions => [ new Gold::Condition(name => "Account", value => $id) ]);
      my $subResponse = Gold::Bank->delete($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to delete allocation: " . $subResponse->getMessage());
      }
    }

    # Delete accounts by calling base Account Delete
    my $baseResponse = Gold::Base->delete($request, $requestId);
  
    return $baseResponse;
  }

  elsif ($object eq "Allocation")
  {
    # Refresh Allocations
    my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Refresh");
    my $subResponse = Gold::Bank->refresh($subRequest, $requestId);
    if ($subResponse->getStatus() eq "Failure")
    {
      return new Gold::Response()->failure($subResponse->getCode(), "Failed while refreshing allocations: " . $subResponse->getMessage());
    }
  
    # Get a list of allocations to be deleted
    # SELECT Id,Account,Amount,StartTime,EndTime FROM Allocation WHERE <Conditions>
    my $results = $database->select(object => "Allocation", selections => [ new Gold::Selection(name => "Id"), new Gold::Selection(name => "Account"), new Gold::Selection(name => "Amount"), new Gold::Selection(name => "StartTime"), new Gold::Selection(name => "EndTime") ], conditions => \@conditions);
    foreach my $row (@{$results->{data}})
    {
      my $id = $row->[0];
      my $account = $row->[1];
      my $amount = $row->[2];
      my $startTime = $row->[3];
      my $endTime = $row->[4];
  
      if ($startTime <= $now && $endTime > $now)
      {
        # Log the transaction (includes the new account id and delta)
        Gold::Bank->logTransaction(database => $database, requestId => $requestId, txnId => $database->nextId("Transaction"), object => "Allocation", action => "Delete", actor => $actor, conditions => [ new Gold::Condition(name => "Id", value => $id), new Gold::Condition(name => "Description", value => "Redundant entry includes account and delta") ], options => \@options, count => 1, account => $account, delta => 0 - $amount, allocation => $id);
      }
    }
    
    # Delete allocations by calling base Allocation Delete
    my $baseResponse = Gold::Base->delete($request, $requestId);
  
    return $baseResponse;
  }

  else
  {
    return new Gold::Response()->failure("315", "The Bank class does not implement $object Delete");
  }
}


# ----------------------------------------------------------------------------
# $response = deposit($request, $requestId);
# ----------------------------------------------------------------------------

# Deposit (Account)
sub deposit
{
  my ($class, $request, $requestId) = @_;

  if ($log->is_debug())
  {
    $log->debug("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my $object = $request->getObject();
  my $actor = $request->getActor();
  my $database = $request->getDatabase();
  my $dbh = $database->{_handle};
  my $amount = $request->getOptionValue("Amount");
  my $id = $request->getOptionValue("Id");
  my $allocation = $request->getOptionValue("Allocation");
  my $creditLimit = $request->getOptionValue("CreditLimit") || 0;
  my $startTime = $request->getOptionValue("StartTime") || 0; # -infinity
  my $endTime = $request->getOptionValue("EndTime") || 2147483647; # infinity
  my $type = $request->getOptionValue("CallType") || "Normal";
  my $ancestors = $request->getOptionValue("Ancestors") || "";
  my @options = $request->getOptions();
  my $depositSum = 0;
  my $now = time;

  if ($object ne "Account")
  {
    return new Gold::Response()->failure("315", "The Bank class does not implement $object Deposit");
  }

  # Amount must be non-negative
  if (! defined $amount)
  {
    $amount = 0;
  }
  if ($amount !~ /^(\d+\.|\.\d+|\d+)\d*$/)
  {
    return new Gold::Response()->failure("740", "The deposit amount must be a number");
  }
  if ($amount < 0)
  {
    return new Gold::Response()->failure("740", "The deposit amount cannot be negative");
  }
  
  # CreditLimit must be non-negative
  if ($creditLimit !~ /^(\d+\.|\.\d+|\d+)\d*$/)
  {
    return new Gold::Response()->failure("740", "The credit limit must be a number");
  }
  if ($creditLimit < 0)
  {
    return new Gold::Response()->failure("740", "The credit limit cannot be negative");
  }
  
  # Credit Limit and Allocation may not both be specified
  if ($creditLimit && $allocation)
  {
    return new Gold::Response()->failure("740", "A credit limit cannot be specifed when an allocation is also specified");
  }

  # Id must be specified
  if (! defined $id)
  {
    return new Gold::Response()->failure("740", "Account id must be specified");
  }

  # Account id must already exist
  # SELECT Id FROM Account WHERE Id=$id
  my $results = $database->select(object => "Account", selections => [ new Gold::Selection(name => "Id") ], conditions => [ new Gold::Condition(name => "Id", value => $id) ]);
  unless (@{$results->{data}})
  {
    return new Gold::Response()->failure("740", "The specified account id ($id) does not exist.");
  }

  # Prevent cyclic recursive deposits
  if ($ancestors =~ /:${id}:/)
  {
    return new Gold::Response()->failure("740", "Cycle detected. The account for this deposit ($id) has already been involved in an upstream deposit. Aborting deposit.");
  }

  my $remaining = $amount; 

  # Look for deposit shares
  if (! $allocation && ! $creditLimit)
  {
    # SELECT Id,DepositShare FROM AccountAccount WHERE Account=$id AND DepositShare>0
    $results = $database->select(object => "AccountAccount", selections => [ new Gold::Selection(name => "Id"), new Gold::Selection(name => "DepositShare") ], conditions => [ new Gold::Condition(name => "Account", value => $id), new Gold::Condition(name => "DepositShare", value => 0, op => "GT") ]);
  
    # Deposit shares were found -- break up the deposit
    if (@{$results->{data}})
    {
      my %depositShare = ();
      my $shareTotal = 0;
      foreach my $row (@{$results->{data}})
      {
        my $shareId = $row->[0];
        my $share = $row->[1];
  
        $depositShare{$shareId} = $share;
        $shareTotal += $share;
      }
  
      # Treat the shares as a percentage
      # Fail if the sum of the percentage exceeds 100
      if ($shareTotal > 100)
      {
        return new Gold::Response()->failure("740", "Deposit shares cannot exceed 100% ($shareTotal)");
      }
  
      my $shareSum = 0;
      foreach my $shareId (keys %depositShare)
      {
        $shareSum += $depositShare{$shareId};
        my $shareAmount = $shareSum == 100 ? $remaining : int($amount * $depositShare{$shareId} / 100);
  
        # Make a descendant deposit
        my $subRequest = new Gold::Request(database => $database, object => "Account", action => "Deposit", options => [ new Gold::Option(name => "Id", value => $shareId), new Gold::Option(name => "Amount", value => $shareAmount), new Gold::Option(name => "StartTime", value => $startTime), new Gold::Option(name => "EndTime", value => $endTime), new Gold::Option(name => "Ancestors", value => $ancestors . ":$id:") ]);
        my $subResponse = Gold::Bank->deposit($subRequest, $requestId);
        if ($subResponse->getStatus() eq "Failure")
        {
          return new Gold::Response()->failure($subResponse->getCode(), "Failed while making a descendant deposit: " . $subResponse->getMessage());
        }
        my $count = $subResponse->getCount();
        $depositSum += $count;
        $remaining -= $count;
      }
    }
  }

  # Deposit the remainder into this account
  if ($remaining > 0 || $amount == 0)
  {
    # Look to see if the Allocation already exists
    # SELECT Id FROM Allocation WHERE Account=$id AND StartTime=$startTime AND EndTime=$endTime AND CallType=$type

    my @selections = ( new Gold::Selection(name => "Id") );
  
    my @conditions =
    (
      new Gold::Condition(name => "Account", value => $id),
      new Gold::Condition(name => "CallType", value => $type),
    );

    if ($allocation)
    {
      push @conditions, new Gold::Condition(name => "Id", value => $allocation);
    }
    else
    {
      push @conditions, new Gold::Condition(name => "StartTime", value => $startTime);
      push @conditions, new Gold::Condition(name => "EndTime", value => $endTime);
    }

    my $results = $database->select(object => "Allocation", selections => \@selections, conditions => \@conditions);

    # An Allocation already exists
    my $allocationId = 0;
    if (@{$results->{data}} && ! $creditLimit)
    {
      $allocationId = ${$results->{data}}[0]->[0];

      # Credit the allocation
      my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Modify", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Amount", value => $remaining, op => "Inc"), new Gold::Assignment(name => "Deposited", value => $remaining, op => "Inc") ], conditions => [ new Gold::Condition(name => "Account", value => $id), new Gold::Condition(name => "Id", value => $allocationId) ]);
      my $subResponse = Gold::Base->modify($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to credit allocation: " . $subResponse->getMessage());
      }
    }

    # An Allocation does not exist (or a credit limit was specified)
    else
    {
      if ($allocation)
      {
        return new Gold::Response()->failure("740", "The specified allocation is not valid");
      }

      # Create a new allocation
      my $activeness;
      if ($startTime <= $now && $endTime > $now) { $activeness = "True"; } else { $activeness = "False"; }
      my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Account", value => $id), new Gold::Assignment(name => "StartTime", value => $startTime), new Gold::Assignment(name => "EndTime", value => $endTime), new Gold::Assignment(name => "CallType", value => $type), new Gold::Assignment(name => "Amount", value => $remaining), new Gold::Assignment(name => "Deposited", value => $remaining), new Gold::Assignment(name => "CreditLimit", value => $creditLimit), new Gold::Assignment(name => "Active", value => $activeness) ]);
      my $subResponse = Gold::Base->create($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to create allocation: " . $subResponse->getMessage());
      }

      # Figure out the id of the allocation we just created
      $allocationId = $subResponse->getDatumValue("Id");
    }

    # Log the transaction
    if ($startTime <= $now && $endTime > $now)
    {
      Gold::Bank->logTransaction(database => $database, requestId => $requestId, txnId => $database->nextId("Transaction"), object => "Account", action => "Deposit", actor => $actor, options => \@options, count => 1, account => $id, delta => $remaining, allocation => $allocationId);
    }
    else
    {
      Gold::Bank->logTransaction(database => $database, requestId => $requestId, txnId => $database->nextId("Transaction"), object => "Account", action => "Deposit", actor => $actor, options => \@options, count => 1, account => $id, allocation => $allocationId);
    }
    $depositSum += $remaining;
  }
  
  my $time_division = defined $request->getOptionValue("ShowHours") ? 3600 : 1;
  my $currency_precision = $config->get_property("currency.precision", 0);
  $depositSum = sprintf("%.${currency_precision}f", $depositSum / $time_division);
  return new Gold::Response()->success($depositSum, "Successfully deposited $depositSum credits into account $id");
}

  
# ----------------------------------------------------------------------------
# $response = modify($request, $requestId);
# ----------------------------------------------------------------------------

# Modify (AccountAccount, Allocation)
sub modify
{
  my ($class, $request, $requestId) = @_;

  if ($log->is_debug())
  {
    $log->debug("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my $object = $request->getObject();
  my $actor = $request->getActor();
  my $database = $request->getDatabase();
  my @options = $request->getOptions();

  if ($object eq "Allocation")
  {
    # The Amount property cannot be modified directly
    if (defined $request->getAssignmentValue("Amount"))
    {
      return new Gold::Response()->failure("740", "The Amount cannot be modified directly because it bypasses accounting. Use Account Deposit or Account Withdraw instead.");
    }

    # The Active property cannot be modified directly
    if (defined $request->getAssignmentValue("Active"))
    {
      return new Gold::Response()->failure("740", "The Active property cannot be modified directly. Modify the StartTime and/or EndTime instead.");
    }

    # Invoke base Allocation Modify
    my $baseResponse = Gold::Base->modify($request, $requestId);

    # Refresh Allocations
    my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Refresh");
    my $subResponse = Gold::Bank->refresh($subRequest, $requestId);
    if ($subResponse->getStatus() eq "Failure")
    {
      return new Gold::Response()->failure($subResponse->getCode(), "Failed while refreshing allocations: " . $subResponse->getMessage());
    }
    
    return $baseResponse;
  }

  elsif ($object eq "AccountAccount")
  {
    my $depositShare = $request->getAssignmentValue("DepositShare");

    if (defined $depositShare)
    {
      # Make sure deposit shares do not exceed 100 for a given account
      my $account = $request->getConditionValue("Account");
      my $id = $request->getConditionValue("Id");
      unless (defined $account && defined $id)
      {
        return new Gold::Response()->failure("740", "Deposit shares cannot be modified for multiple subaccounts simultaneously");
      }
      my $depositShareTotal = $depositShare;

      my $results = $database->select(object => "AccountAccount", selections => [ new Gold::Selection(name => "DepositShare", op => "Sum") ], conditions => [ new Gold::Condition(name => "Account", value => $account), new Gold::Condition(name => "Id", value => $id, op => "NE") ]);
      my $depositShareSum = ${$results->{data}}[0]->[0];
      if (defined $depositShareSum) 
      {
        $depositShareTotal += $depositShareSum;
      }
      if ($depositShareTotal > 100)
      {
        return new Gold::Response()->failure("740", "Total deposit shares for an account cannot exceed 100% ($depositShareTotal)");
      }
    }
    
    # Modify account accounts by calling base AccountAccount Modify
    my $baseResponse = Gold::Base->modify($request, $requestId);
  
    return $baseResponse;
  }

  else
  {
    return new Gold::Response()->failure("315", "The Bank class does not implement $object Modify");
  }
}


# ----------------------------------------------------------------------------
# $response = query($request, $requestId);
# ----------------------------------------------------------------------------

# Query (Account, Reservation, Job, Transaction)
sub query
{
  my ($class, $request, $requestId) = @_;

  if ($log->is_debug())
  {
    $log->debug("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my $object = $request->getObject();
  my $actor = $request->getActor();
  my $database = $request->getDatabase();
  my $now = time;

  if ($object eq "Account")
  {
    my $project = $request->getOptionValue("Project");
    my $user = $request->getOptionValue("User");
    my $machine = $request->getOptionValue("Machine");
    my $active = $request->getOptionValue("Active");
    my @selections = $request->getSelections();
    my @conditions = $request->getConditions();
    my @options = $request->getOptions();
    my $useRulesOption = $request->getOptionValue("UseRules");
    my $includeAncestors = $request->getOptionValue("IncludeAncestors");
    my %accounts = ();
    my %checkBoth = ();
    my %checkUser = ();
    my %checkMach = ();
    my @ids = ();

    # Override Authorization
    my $authorized = 1;
    if ($request->getOverride())
    {
      $authorized = 0;
    }
    if (! $authorized && defined $project)
    {
      # See if actor is project admin
      # SELECT Admin FROM ProjectUser WHERE Project=$project AND Name=$actor AND Admin=True
      my $subResults = $database->select(object => "ProjectUser", selections => [ new Gold::Selection(name => "Admin") ], conditions => [ new Gold::Condition(name => "Project", value => $project), new Gold::Condition(name => "Name", value => $actor), new Gold::Condition(name => "Admin", value => "True") ]);
      if (@{$subResults->{data}})
      {
        $authorized = 1;
      }
    }
    if (! $authorized && defined $user)
    {
      if ($user eq $actor)
      {
        $authorized = 1;
      }
    }
    #if (! $authorized && defined $machine)
    #{
    #  # See if actor is machine admin
    #  # SELECT Admin FROM MachineUser WHERE Machine=$machine AND Name=$actor AND Admin=True
    #  my $subResults = $database->select(object => "MachineUser", selections => [ new Gold::Selection(name => "Admin") ], conditions => [ new Gold::Condition(name => "Machine", value => $machine), new Gold::Condition(name => "Name", value => $actor), new Gold::Condition(name => "Admin", value => "True") ]);
    #  if (@{$subResults->{data}})
    #  {
    #    $authorized = 1;
    #  }
    #}
    if (! $authorized)
    {
      return new Gold::Response()->failure("444", "$actor is not authorized to Query the Accounts");
    }
    
    # Set useRules variable according to option value
    my $useRules = 0;
    if (defined $useRulesOption && $useRulesOption eq "True")
    {
      $useRules = 1;
    }
  
    # Prescreen Project
    if (defined $project)
    {
      # Lookup project
      # SELECT Active,Special FROM Project WHERE Name=$project
      my $subResults = $database->select(object => "Project", selections => [ new Gold::Selection(name => "Active"), new Gold::Selection(name => "Special") ], conditions => [ new Gold::Condition(name => "Name", value => $project) ]);
      if (@{$subResults->{data}})
      {
        my $active = ${$subResults->{data}}[0]->[0];
        my $special = ${$subResults->{data}}[0]->[1];
        if ($useRules && $special && $special eq "False" && defined $active && $active eq "False")
        {
          return new Gold::Response()->failure("740", "Project $project is not active");
        }
      }
      else
      {
        return new Gold::Response()->failure("740", "Project $project does not exist");
      }
    }
  
    # Prescreen User
    if (defined $user)
    {
      # Lookup user
      # SELECT Active,Special FROM User WHERE Name=$user
      my $subResults = $database->select(object => "User", selections => [ new Gold::Selection(name => "Active"), new Gold::Selection(name => "Special") ], conditions => [ new Gold::Condition(name => "Name", value => $user) ]);
      if (@{$subResults->{data}})
      {
        my $active = ${$subResults->{data}}[0]->[0];
        my $special = ${$subResults->{data}}[0]->[1];
        if ($useRules && $special && $special eq "False" && defined $active && $active eq "False")
        {
          return new Gold::Response()->failure("740", "User $user is not active");
        }
      }
      else
      {
        return new Gold::Response()->failure("740", "User $user does not exist");
      }
    }
    
    # Prescreen Machine
    if (defined $machine)
    {
      # Lookup machine
      # SELECT Active,Special FROM Machine WHERE Name=$machine
      my $subResults = $database->select(object => "Machine", selections => [ new Gold::Selection(name => "Active"), new Gold::Selection(name => "Special") ], conditions => [ new Gold::Condition(name => "Name", value => $machine) ]);
      if (@{$subResults->{data}})
      {
        my $active = ${$subResults->{data}}[0]->[0];
        my $special = ${$subResults->{data}}[0]->[1];
        if ($useRules && $special && $special eq "False" && defined $active && $active eq "False")
        {
          return new Gold::Response()->failure("740", "Machine $machine is not active");
        }
      }
      else
      {
        return new Gold::Response()->failure("740", "Machine $machine does not exist");
      }
    }
    
    # Iterate over the conditions building account id lists
    foreach my $condition (@conditions)
    {
      my $name = $condition->getName();
                                                                                
      if ($name eq "Id")
      {
        push @ids, $condition->getValue();
      }
    }
  
    # Refresh Allocations
    my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Refresh");
    my $subResponse = Gold::Bank->refresh($subRequest, $requestId);
    if ($subResponse->getStatus() eq "Failure")
    {
      return new Gold::Response()->failure($subResponse->getCode(), "Failed while refreshing allocations: " . $subResponse->getMessage());
    }
    
    # Quick access to base Account Query if No options are specified
    if (! @options)
    {
      # Invoke base Account Query
      my $baseResponse = Gold::Base->query($request);
  
      return $baseResponse;
    }
  
    # Construct list of viable accounts
    {
      # SELECT Account.Id,AccountProject.Name,AccountUser.Name,AccountMachine.Name FROM Account,AccountUser,AccountProject,AccountMachine,Allocation WHERE Allocation.StartTime<=$now AND Allocation.EndTime>$now AND AccountProject.Account=Account.Id AND AccountUser.Account=Account.Id AND AccountMachine.Account=Account.Id AND Allocation.Account=Account.Id AND <Conditions>
    
      my @subObjects = ( new Gold::Object(name => "Account"));
      my @subSelections = ( new Gold::Selection(object => "Account", name => "Id"));
      my @subConditions = @conditions;
      foreach my $condition (@subConditions)
      {
        $condition->setObject("Account");
      }
    
      # Add AccountProject if project is specified or useRules
      if (defined $project || $useRules)
      {
        push @subObjects, new Gold::Object(name => "AccountProject");
        push @subSelections, new Gold::Selection(object => "AccountProject", name => "Name");
        push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", subject => "Account", value => "Id");
      }
      else
      {
        push @subSelections, new Gold::Selection(name => "'ANY'");
      }
  
      # Add AccountUser if user is specified or useRules
      if (defined $user || $useRules)
      {
        push @subObjects, new Gold::Object(name => "AccountUser");
        push @subSelections, new Gold::Selection(object => "AccountUser", name => "Name");
        push @subConditions, new Gold::Condition(object => "AccountUser", name => "Account", subject => "Account", value => "Id");
      }
      else
      {
        push @subSelections, new Gold::Selection(name => "'ANY'");
      }
  
      # Add AccountMachine if machine is specified or useRules
      if (defined $machine || $useRules)
      {
        push @subObjects, new Gold::Object(name => "AccountMachine");
        push @subSelections, new Gold::Selection(object => "AccountMachine", name => "Name");
        push @subConditions, new Gold::Condition(object => "AccountMachine", name => "Account", subject => "Account", value => "Id");
      }
      else
      {
        push @subSelections, new Gold::Selection(name => "'ANY'");
      }
  
      # Add Allocation if active is specified
      if (defined $active)
      {
        push @subObjects, new Gold::Object(name => "Allocation");
        push @subConditions, new Gold::Condition(object => "Allocation", name => "Account", subject => "Account", value => "Id");
        if ($active eq "True")
        {
          push @subConditions, new Gold::Condition(object => "Allocation", name => "StartTime", value => $now, op => "LE");
          push @subConditions, new Gold::Condition(object => "Allocation", name => "EndTime", value => $now, op => "GT");
        }
        else
        {
          push @subConditions, new Gold::Condition(object => "Allocation", name => "StartTime", value => $now, op => "GT", group => "+1");
          push @subConditions, new Gold::Condition(object => "Allocation", name => "EndTime", value => $now, op => "LE", conj => "Or", group => "-1");
        }
      }
  
      # Open the parentheses with a harmless anded truism
      # This way nothing needs to be in an entity section
      push @subConditions, new Gold::Condition(object => "Account", name => "Id", value => "0", op => "NE", conj => "And", group => "+1");
  
      # Add project conditions
    
      # Project is specified
      if (defined $project)
      {
        if ($useRules)
        {
          # Apply ruleset
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+2");
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Access", value => "True", conj => "And", group => "-1");
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", value => $project, conj => "Or", group => "+1");
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Access", value => "True", conj => "And", group => "-2");
        }
        else
        {
          # Only look for exact name
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", value => $project);
        }
      }
  
      # Project is not specified
      else
      {
        if ($useRules)
        {
          # Check for any true except for NONE
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", value => "NONE", op => "NE", conj => "And", group => "+1");
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Access", value => "True", conj => "And", group => "-1");
        }
      }
    
      # Add user conditions
    
      # User is specified
      if (defined $user)
      {
        if ($useRules)
        {
          # Apply ruleset
          push @subConditions, new Gold::Condition(object => "AccountUser", name => "Name", value => "ANY", conj => "And", group => "+2");
          push @subConditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-1");
          push @subConditions, new Gold::Condition(object => "AccountUser", name => "Name", value => $user, conj => "Or", group => "+1");
          push @subConditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-1");
          push @subConditions, new Gold::Condition(object => "AccountUser", name => "Name", value => "MEMBERS", conj => "Or", group => "+1");
          push @subConditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-2");
        }
        else
        {
          # Only look for exact name
          push @subConditions, new Gold::Condition(object => "AccountUser", name => "Name", value => $user);
        }
      }
    
      # User is not specified
      else
      {
        if ($useRules)
        {
          # Check for any true except for NONE
          push @subConditions, new Gold::Condition(object => "AccountUser", name => "Name", value => "NONE", op => "NE", conj => "And", group => "+1");
          push @subConditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-1");
        }
      }
    
      # Add machine conditions
    
      # Machine is specified
      if (defined $machine)
      {
        if ($useRules)
        {
          # Apply ruleset
          push @subConditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => "ANY", conj => "And", group => "+2");
          push @subConditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-1");
          push @subConditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => $machine, conj => "Or", group => "+1");
          push @subConditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-1");
          push @subConditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => "MEMBERS", conj => "Or", group => "+1");
          push @subConditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-2");
        }
      }
    
      # Machine is not specified
      else
      {
        if ($useRules)
        {
          # Check for any true except for NONE
          push @subConditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => "NONE", op => "NE", conj => "And", group => "+1");
          push @subConditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-1");
        }
      }
  
      # Close the parentheses with a harmless anded truism
      # This way nothing needs to be in an entity section
      push @subConditions, new Gold::Condition(object => "Account", name => "Id", value => "0", op => "NE", conj => "And", group => "-1");
    
      # Add id conditions
      my $firstTime = 1;
      my $counter = 0;
      foreach my $id (@ids)
      {
        $counter++;
        my $lastTime = ($counter == scalar @ids) ? 1 : 0;
  
        if ($firstTime && $lastTime)
        {
          push @subConditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "And", group => "0");
        }
        elsif ($firstTime)
        {
          $firstTime = 0;
          push @subConditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "And", group => "+1");
        }
        elsif ($lastTime)
        {
          push @subConditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "Or", group => "-1");
        }
        else
        {
          push @subConditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "Or", group => "0");
        }
      }
  
      my $results = $database->select(objects => \@subObjects, selections => \@subSelections, conditions => \@subConditions);
      foreach my $row (@{$results->{data}})
      {
        my $accountId = $row->[0];
        my $accountProject = $row->[1];
        my $accountUser = $row->[2];
        my $accountMachine = $row->[3];
        
        # Check membership
        if ($accountUser eq "MEMBERS" && $accountMachine eq "MEMBERS")
        {
          $checkBoth{$accountId} = 1;
        }
        elsif ($accountUser eq "MEMBERS")
        {
          $checkUser{$accountId} = 1;
        }
        elsif ($accountMachine eq "MEMBERS")
        {
          $checkMach{$accountId} = 1;
        }
        else
        {
          $accounts{$accountId} = 1;
        }
      }

      # Check Both Membership
      if (%checkBoth)
      {
        my @subObjects = ( new Gold::Object(name => "AccountProject"), new Gold::Object(name => "ProjectUser"), new Gold::Object(name => "ProjectMachine"));
        my @subSelections = ( new Gold::Selection(object => "AccountProject", name => "Account") );
        my @subConditions = ();
        push @subConditions, new Gold::Condition(object => "ProjectUser", name => "Active", value => "True");
        push @subConditions, new Gold::Condition(object => "ProjectMachine", name => "Active", value => "True");
        if (defined $user)
        {
          push @subConditions, new Gold::Condition(object => "ProjectUser", name => "Name", value => $user);
        }
        if (defined $machine)
        {
          push @subConditions, new Gold::Condition(object => "ProjectMachine", name => "Name", value => $machine);
        }
        push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+2");
        push @subConditions, new Gold::Condition(object => "ProjectUser", name => "Project", subject => "ProjectMachine", value => "Project", conj => "And", group => "-1");
        push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", subject => "ProjectUser", value => "Project", conj => "Or", group => "+1");
        push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", subject => "ProjectMachine", value => "Project", conj => "And", group => "-2");

        # Add id conditions
        my $firstTime = 1;
        my $counter = 0;
        foreach my $id (keys %checkBoth)
        {
          $counter++;
          my $lastTime = ($counter == scalar keys %checkBoth) ? 1 : 0;
    
          if ($firstTime && $lastTime)
          {
            push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "And", group => "0");
          }
          elsif ($firstTime)
          {
            $firstTime = 0;
            push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "And", group => "+1");
          }
          elsif ($lastTime)
          {
            push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "Or", group => "-1");
          }
          else
          {
            push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "Or", group => "0");
          }
        }
  
        my $subResults = $database->select(objects => \@subObjects, selections => \@subSelections, conditions => \@subConditions);
        foreach my $row (@{$subResults->{data}})
        {
          my $accountId = $row->[0];
          $accounts{$accountId} = 1;
        }
      }
          
      # Check User Membership
      if (%checkUser)
      {
        my @subObjects = ( new Gold::Object(name => "AccountProject"), new Gold::Object(name => "ProjectUser"));
        my @subSelections = ( new Gold::Selection(object => "AccountProject", name => "Account") );
        my @subConditions = ();
        push @subConditions, new Gold::Condition(object => "ProjectUser", name => "Active", value => "True");
        if (defined $user)
        {
          push @subConditions, new Gold::Condition(object => "ProjectUser", name => "Name", value => $user);
        }
        push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+1");
        push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", subject => "ProjectUser", value => "Project", conj => "Or", group => "-1");

        # Add id conditions
        my $firstTime = 1;
        my $counter = 0;
        foreach my $id (keys %checkUser)
        {
          $counter++;
          my $lastTime = ($counter == scalar keys %checkUser) ? 1 : 0;
    
          if ($firstTime && $lastTime)
          {
            push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "And", group => "0");
          }
          elsif ($firstTime)
          {
            $firstTime = 0;
            push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "And", group => "+1");
          }
          elsif ($lastTime)
          {
            push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "Or", group => "-1");
          }
          else
          {
            push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "Or", group => "0");
          }
        }
  
        my $subResults = $database->select(objects => \@subObjects, selections => \@subSelections, conditions => \@subConditions);
        foreach my $row (@{$subResults->{data}})
        {
          my $accountId = $row->[0];
          $accounts{$accountId} = 1;
        }
      }
          
      # Check Machine Membership
      if (%checkMach)
      {
        my @subObjects = ( new Gold::Object(name => "AccountProject"), new Gold::Object(name => "ProjectMachine"));
        my @subSelections = ( new Gold::Selection(object => "AccountProject", name => "Account") );
        my @subConditions = ();
        push @subConditions, new Gold::Condition(object => "ProjectMachine", name => "Active", value => "True");
        if (defined $machine)
        {
          push @subConditions, new Gold::Condition(object => "ProjectMachine", name => "Name", value => $machine);
        }
        push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+1");
        push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", subject => "ProjectMachine", value => "Project", conj => "Or", group => "-1");

        # Add id conditions
        my $firstTime = 1;
        my $counter = 0;
        foreach my $id (keys %checkMach)
        {
          $counter++;
          my $lastTime = ($counter == scalar keys %checkMach) ? 1 : 0;
    
          if ($firstTime && $lastTime)
          {
            push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "And", group => "0");
          }
          elsif ($firstTime)
          {
            $firstTime = 0;
            push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "And", group => "+1");
          }
          elsif ($lastTime)
          {
            push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "Or", group => "-1");
          }
          else
          {
            push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "Or", group => "0");
          }
        }
  
        my $subResults = $database->select(objects => \@subObjects, selections => \@subSelections, conditions => \@subConditions);
        foreach my $row (@{$subResults->{data}})
        {
          my $accountId = $row->[0];
          $accounts{$accountId} = 1;
        }
      }
          
      if ($log->is_debug())
      {
        $log->debug("Initial accepted account list is: " . join ',', keys %accounts);
      }
    }
  
    # Return immediately if there are no matching accounts
    if (! scalar keys %accounts)
    {
      return new Gold::Response()->success(0, []);
    }
  
    # Check to make sure these accounts are not rejected
    # SELECT DISTINCT Account.Id FROM Account,AccountUser,AccountProject,AccountMachine WHERE AccountProject.Account=Account.Id AND AccountUser.Account=Account.Id AND AccountMachine.Account=Account.Id AND <Id IN AccountList>
  
    my @subObjects = ( new Gold::Object(name => "Account"));
    my @subSelections = ( new Gold::Selection(object => "Account", name => "Id") );
    my @subConditions = @conditions;
    foreach my $condition (@subConditions)
    {
      $condition->setObject("Account");
    }
    my @subOptions = ( new Gold::Option(name => "Unique", value => "True") );
  
    # Add AccountProject if project is specified or useRules
    if (defined $project || $useRules)
    {
      push @subObjects, new Gold::Object(name => "AccountProject");
      push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", subject => "Account", value => "Id");
    }
  
    # Add AccountUser if user is specified or useRules
    if (defined $user || $useRules)
    {
      push @subObjects, new Gold::Object(name => "AccountUser");
      push @subConditions, new Gold::Condition(object => "AccountUser", name => "Account", subject => "Account", value => "Id");
    }
  
    # Add AccountMachine if machine is specified or useRules
    if (defined $machine || $useRules)
    {
      push @subObjects, new Gold::Object(name => "AccountMachine");
      push @subConditions, new Gold::Condition(object => "AccountMachine", name => "Account", subject => "Account", value => "Id");
    }
  
    # Constrain to list of accepted ids
    my $firstTime = 1;
    my $counter = 0;
    foreach my $id (keys %accounts)
    {
      $counter++;
      my $lastTime = ($counter == scalar keys %accounts) ? 1 : 0;
  
      if ($firstTime && $lastTime)
      {
        push @subConditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "And", group => "0");
      }
      elsif ($firstTime)
      {
        $firstTime = 0;
        push @subConditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "And", group => "+1");
      }
      elsif ($lastTime)
      {
        push @subConditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "Or", group => "-1");
      }
      else
      {
        push @subConditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "Or", group => "0");
      }
    }
  
    # Open the parentheses with a harmless ored falsism
    # This way nothing needs to be in an entity section
    push @subConditions, new Gold::Condition(object => "Account", name => "Id", value => "0", op => "EQ", conj => "And", group => "+1");
  
    # Add project conditions
    
    # Project is specified
    if (defined $project)
    {
      if ($useRules)
      {
        # Apply ruleset
        push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "Or", group => "+2");
        push @subConditions, new Gold::Condition(object => "AccountProject", name => "Access", value => "False", conj => "And", group => "-1");
        push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", value => $project, conj => "Or", group => "+1");
        push @subConditions, new Gold::Condition(object => "AccountProject", name => "Access", value => "False", conj => "And", group => "-2");
      }
    }
  
    # Project is not specified
    else
    {
      if ($useRules)
      {
        # Check for ANY false
        push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", op => "EQ", conj => "Or", group => "+1");
        push @subConditions, new Gold::Condition(object => "AccountProject", name => "Access", value => "False", conj => "And", group => "-1");
      }
    }
    
    # Add user conditions
  
    # User is specified
    if (defined $user)
    {
      if ($useRules)
      {
        # Apply ruleset
        push @subConditions, new Gold::Condition(object => "AccountUser", name => "Name", value => "ANY", conj => "Or", group => "+2");
        push @subConditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "False", conj => "And", group => "-1");
        push @subConditions, new Gold::Condition(object => "AccountUser", name => "Name", value => $user, conj => "Or", group => "+1");
        push @subConditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "False", conj => "And", group => "-1");
        push @subConditions, new Gold::Condition(object => "AccountUser", name => "Name", value => "MEMBERS", conj => "Or", group => "+1");
        push @subConditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "False", conj => "And", group => "-2");
      }
    }
  
    # User is not specified
    else
    {
      if ($useRules)
      {
        # Check for ANY false
        push @subConditions, new Gold::Condition(object => "AccountUser", name => "Name", value => "ANY", op => "EQ", conj => "Or", group => "+1");
        push @subConditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "False", conj => "And", group => "-1");
      }
    }
  
    # Add machine conditions
  
    # Machine is specified
    if (defined $machine)
    {
      if ($useRules)
      {
        # Apply ruleset
        push @subConditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => "ANY", conj => "Or", group => "+2");
        push @subConditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "False", conj => "And", group => "-1");
        push @subConditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => $machine, conj => "Or", group => "+1");
        push @subConditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "False", conj => "And", group => "-1");
        push @subConditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => "MEMBERS", conj => "Or", group => "+1");
        push @subConditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "False", conj => "And", group => "-2");
      }
    }
    
    # Machine is not specified
    else
    {
      if ($useRules)
      {
        # Check for ANY false
        push @subConditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => "ANY", op => "EQ", conj => "Or", group => "+1");
        push @subConditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "False", conj => "And", group => "-1");
      }
    }
  
    # Close the parentheses with a harmless ored falsism
    # This way nothing needs to be in an entity section
    push @subConditions, new Gold::Condition(object => "Account", name => "Id", value => "0", op => "EQ", conj => "Or", group => "-1");
  
    # Perform the query
    my $results = $database->select(objects => \@subObjects, selections => \@subSelections, conditions => \@subConditions, options => \@subOptions);
    foreach my $row (@{$results->{data}})
    {
      my $accountId = $row->[0];
  
      # Remove from accounts
      delete $accounts{$accountId};
    }
  
    if ($log->is_debug())
    {
      $log->debug("Post rejection account list is: " . join ',', keys %accounts);
    }
  
    # Return immediately if there are no matching accounts
    if (! scalar keys %accounts)
    {
      return new Gold::Response()->success(0, []);
    }
  
    # Factor in ancestor accounts if includeAncestors option is true
    if (defined $includeAncestors && $includeAncestors eq "True")
    {
      my %ancestors = ();
      # SELECT Account,Id FROM AccountAccount WHERE Overflow=True
      my @selections = ( new Gold::Selection(name => "Account"), new Gold::Selection(name => "Id") );
      my @conditions = ( new Gold::Condition(name => "Overflow", value => "True") );
      my $results = $database->select(object => "AccountAccount", selections => \@selections, conditions => \@conditions);
      foreach my $row (@{$results->{data}})
      {
        my $parent = $row->[0];
        my $child = $row->[1];
  
        $ancestors{$child}{$parent} = 1;
      }
          
      # Add ancestors a generation at a time until there is no more growth
      while (1)
      {
        my $count = scalar keys %accounts;
        foreach my $account (keys %accounts)
        {
          foreach my $parent (keys %{$ancestors{$account}})
          {
            $accounts{$parent} = 1 unless exists $accounts{$parent};
          }
        }
        last if $count == scalar keys %accounts;
      }
  
      if ($log->is_debug())
      {
        $log->debug("Post ancestral account list is: " . join ',', keys %accounts);
      }
    }
  
    # Perform selected query over list of accounts
    # SELECT <selections> FROM Account WHERE (Id=<Id> ...)
  
    # Constrain to list of accepted ids
    @subConditions = ();
    $firstTime = 1;
    $counter = 0;
    foreach my $id (keys %accounts)
    {
      $counter++;
      my $lastTime = ($counter == scalar keys %accounts) ? 1 : 0;
  
      if ($firstTime && $lastTime)
      {
        push @subConditions, new Gold::Condition(name => "Id", value => $id, conj => "And", group => "0");
      }
      elsif ($firstTime)
      {
        $firstTime = 0;
        push @subConditions, new Gold::Condition(name => "Id", value => $id, conj => "And", group => "+1");
      }
      elsif ($lastTime)
      {
        push @subConditions, new Gold::Condition(name => "Id", value => $id, conj => "Or", group => "-1");
      }
      else
      {
        push @subConditions, new Gold::Condition(name => "Id", value => $id, conj => "Or", group => "0");
      }
    }

    push @subConditions, new Gold::Condition(name => "Deleted", value => "True", conj => "And", group => "+1");
    push @subConditions, new Gold::Condition(name => "Deleted", value => "False", conj => "Or", group => "-1");
  
    $results = $database->select(object => "Account", selections => \@selections, conditions => \@subConditions, options => \@options);
    my $count = 0;
    my @data = ();
    my $data = $results->{data};
    my $cols = $results->{cols};
    my $names = $results->{names};
  
    # Populate Data
    foreach my $row (@{$data})
    {
      $count++;
      my $datum = new Gold::Datum($object);
      for (my $i = 0; $i <$cols; $i++)
      {
        my $name = $names->[$i];
        my $value = $row->[$i]; # Null comes in as undef
        $datum->setValue($name, $value);
      }
      push @data, $datum;
    }
  
    my $response = new Gold::Response()->success($count, \@data);
  
    return $response;
  }

  elsif ($object eq "Reservation")
  {
    my $useRules = $request->getOptionValue("UseRules");
    my $project = $request->getConditionValue("Project");
    my $user = $request->getConditionValue("User");
    my $machine = $request->getConditionValue("Machine");

    # Override Authorization
    my $authorized = 1;
    if ($request->getOverride())
    {
      $authorized = 0;
    }
    if (! $authorized && defined $project)
    {
      # See if actor is project admin
      # SELECT Admin FROM ProjectUser WHERE Project=$project AND Name=$actor AND Admin=True
      my $subResults = $database->select(object => "ProjectUser", selections => [ new Gold::Selection(name => "Admin") ], conditions => [ new Gold::Condition(name => "Project", value => $project), new Gold::Condition(name => "Name", value => $actor), new Gold::Condition(name => "Admin", value => "True") ]);
      if (@{$subResults->{data}})
      {
        $authorized = 1;
      }
    }
    if (! $authorized && defined $user)
    {
      if ($user eq $actor)
      {
        $authorized = 1;
      }
    }
    #if (! $authorized && defined $machine)
    #{
    #  # See if actor is machine admin
    #  # SELECT Admin FROM MachineUser WHERE Machine=$machine AND Name=$actor AND Admin=True
    #  my $subResults = $database->select(object => "MachineUser", selections => [ new Gold::Selection(name => "Admin") ], conditions => [ new Gold::Condition(name => "Machine", value => $machine), new Gold::Condition(name => "Name", value => $actor), new Gold::Condition(name => "Admin", value => "True") ]);
    #  if (@{$subResults->{data}})
    #  {
    #    $authorized = 1;
    #  }
    #}
    if (! $authorized)
    {
      return new Gold::Response()->failure("444", "$actor is not authorized to list the reservations");
    }

    # We need to display all reservations that impinge on the entities' balance
    if (defined $useRules && $useRules eq "True")
    {
      my $ignoreAncestors = $request->getOptionValue("IgnoreAncestors");
      my %accounts = ();
      my %reservations = ();
      my %checkBoth = ();
      my %checkUser = ();
      my %checkMach = ();
      my @ids = ();
    
      # Prescreen Project
      if (defined $project)
      {
        # Lookup project
        # SELECT Active,Special FROM Project WHERE Name=$project
        my $subResults = $database->select(object => "Project", selections => [ new Gold::Selection(name => "Active"), new Gold::Selection(name => "Special") ], conditions => [ new Gold::Condition(name => "Name", value => $project) ]);
        if (@{$subResults->{data}})
        {
          my $active = ${$subResults->{data}}[0]->[0];
          my $special = ${$subResults->{data}}[0]->[1];
          if (defined $special && $special ne "True" && defined $active && $active ne "True")
          {
            return new Gold::Response()->failure("740", "Project $project is not active");
          }
        }
        else
        {
          return new Gold::Response()->failure("740", "Project $project does not exist");
        }
      }
    
      # Prescreen User
      if (defined $user)
      {
        # Lookup user
        # SELECT Active,Special FROM User WHERE Name=$user
        my $subResults = $database->select(object => "User", selections => [ new Gold::Selection(name => "Active"), new Gold::Selection(name => "Special") ], conditions => [ new Gold::Condition(name => "Name", value => $user) ]);
        if (@{$subResults->{data}})
        {
          my $active = ${$subResults->{data}}[0]->[0];
          my $special = ${$subResults->{data}}[0]->[1];
          if (defined $special && $special ne "True" && defined $active && $active ne "True")
          {
            return new Gold::Response()->failure("740", "User $user is not active");
          }
        }
        else
        {
          return new Gold::Response()->failure("740", "User $user does not exist");
        }
      }
      
      # Prescreen Machine
      if (defined $machine)
      {
        # Lookup machine
        # SELECT Active,Special FROM Machine WHERE Name=$machine
        my $subResults = $database->select(object => "Machine", selections => [ new Gold::Selection(name => "Active"), new Gold::Selection(name => "Special") ], conditions => [ new Gold::Condition(name => "Name", value => $machine) ]);
        if (@{$subResults->{data}})
        {
          my $active = ${$subResults->{data}}[0]->[0];
          my $special = ${$subResults->{data}}[0]->[1];
          if (defined $special && $special ne "True" && defined $active && $active ne "True")
          {
            return new Gold::Response()->failure("740", "Machine $machine is not active");
          }
        }
        else
        {
          return new Gold::Response()->failure("740", "Machine $machine does not exist");
        }
      }
      
      # Iterate over the conditions building account id lists
      foreach my $condition ($request->getConditions())
      {
        my $name = $condition->getName();
    
        if ($name eq "Id")
        {
          push @ids, $condition->getValue();
        }
      }
    
      # Refresh Allocations
      my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Refresh");
      my $subResponse = Gold::Bank->refresh($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Failed while refreshing allocations: " . $subResponse->getMessage());
      }
      
      # Construct list of viable accounts
      {
        # SELECT Account.Id,AccountProject.Name,AccountUser.Name,AccountMachine.Name FROM Account,AccountUser,AccountProject,AccountMachine,Allocation WHERE Allocation.StartTime<=$now AND Allocation.EndTime>$now AND CallType='Normal' AND AccountProject.Account=Account.Id AND AccountUser.Account=Account.Id AND AccountMachine.Account=Account.Id AND Allocation.Account=Account.Id
      
        my @objects =
        (
          new Gold::Object(name => "Account"),
          new Gold::Object(name => "AccountUser"),
          new Gold::Object(name => "AccountProject"),
          new Gold::Object(name => "AccountMachine"),
          new Gold::Object(name => "Allocation"),
        );
      
        my @selections =
        (
          new Gold::Selection(object => "Account", name => "Id"),
          new Gold::Selection(object => "AccountProject", name => "Name"),
          new Gold::Selection(object => "AccountUser", name => "Name"),
          new Gold::Selection(object => "AccountMachine", name => "Name")
        );
      
        my @conditions =
        (
          new Gold::Condition(object => "Allocation", name => "Account", subject => "Account", value => "Id"),
          new Gold::Condition(object => "Allocation", name => "StartTime", value => $now, op => "LE"),
          new Gold::Condition(object => "Allocation", name => "EndTime", value => $now, op => "GT"),
          new Gold::Condition(object => "Allocation", name => "CallType", value => "Normal"),
          new Gold::Condition(object => "AccountProject", name => "Account", subject => "Account", value => "Id"),
          new Gold::Condition(object => "AccountUser", name => "Account", subject => "Account", value => "Id"),
          new Gold::Condition(object => "AccountMachine", name => "Account", subject => "Account", value => "Id")
        );
      
        # Add project conditions
      
        # This is a wildcard. Look for any true entities
        if (! defined $project)
        {
          push @conditions, new Gold::Condition(object => "AccountProject", name => "Name", value => "NONE", op => "NE", conj => "And", group => "+2");
          push @conditions, new Gold::Condition(object => "AccountProject", name => "Access", value => "True", conj => "And", group => "-1");
        }
      
        # Not a wildcard. Process normally
        else
        {
          push @conditions, new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+3");
          push @conditions, new Gold::Condition(object => "AccountProject", name => "Access", value => "True", conj => "And", group => "-1");
          push @conditions, new Gold::Condition(object => "AccountProject", name => "Name", value => $project, conj => "Or", group => "+1");
          push @conditions, new Gold::Condition(object => "AccountProject", name => "Access", value => "True", conj => "And", group => "-2");
        }
      
        # Add user conditions
      
        # This is a wildcard. Look for any true entities
        if (! defined $user)
        {
          push @conditions, new Gold::Condition(object => "AccountUser", name => "Name", value => "NONE", op => "NE", conj => "And", group => "+1");
          push @conditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-1");
        }
      
        # Not a wildcard. Process normally
        else
        {
          push @conditions, new Gold::Condition(object => "AccountUser", name => "Name", value => "ANY", conj => "And", group => "+2");
          push @conditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-1");
          push @conditions, new Gold::Condition(object => "AccountUser", name => "Name", value => $user, conj => "Or", group => "+1");
          push @conditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-1");
          push @conditions, new Gold::Condition(object => "AccountUser", name => "Name", value => "MEMBERS", conj => "Or", group => "+1");
          push @conditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-2");
        }
      
        # Add machine conditions
      
        # This is a wildcard. Look for any true entities
        if (! defined $machine)
        {
          push @conditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => "NONE", op => "NE", conj => "And", group => "+1");
          push @conditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-2");
        }
      
        # Not a wildcard. Process normally
        else
        {
          push @conditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => "ANY", conj => "And", group => "+2");
          push @conditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-1");
          push @conditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => $machine, conj => "Or", group => "+1");
          push @conditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-1");
          push @conditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => "MEMBERS", conj => "Or", group => "+1");
          push @conditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-3");
        }
      
        # Add id conditions
        my $firstTime = 1;
        my $counter = 0;
        foreach my $id (@ids)
        {
          $counter++;
          my $lastTime = ($counter == scalar @ids) ? 1 : 0;
    
          if ($firstTime && $lastTime)
          {
            push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "And", group => "0");
          }
          elsif ($firstTime)
          {
            $firstTime = 0;
            push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "And", group => "+1");
          }
          elsif ($lastTime)
          {
            push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "Or", group => "-1");
          }
          else
          {
            push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "Or", group => "0");
          }
        }
    
        my $results = $database->select(objects => \@objects, selections => \@selections, conditions => \@conditions);
        foreach my $row (@{$results->{data}})
        {
          my $accountId = $row->[0];
          my $accountProject = $row->[1];
          my $accountUser = $row->[2];
          my $accountMachine = $row->[3];
          
          # Check membership
          if ($accountUser eq "MEMBERS" && $accountMachine eq "MEMBERS")
          {
            $checkBoth{$accountId} = 1;
          }
          elsif ($accountUser eq "MEMBERS")
          {
            $checkUser{$accountId} = 1;
          }
          elsif ($accountMachine eq "MEMBERS")
          {
            $checkMach{$accountId} = 1;
          }
          else
          {
            $accounts{$accountId} = 1;
          }
        }
  
        # Check Both Membership
        if (%checkBoth)
        {
          my @subObjects = ( new Gold::Object(name => "AccountProject"), new Gold::Object(name => "ProjectUser"), new Gold::Object(name => "ProjectMachine"));
          my @subSelections = ( new Gold::Selection(object => "AccountProject", name => "Account") );
          my @subConditions = ();
          push @subConditions, new Gold::Condition(object => "ProjectUser", name => "Active", value => "True");
          push @subConditions, new Gold::Condition(object => "ProjectMachine", name => "Active", value => "True");
          if (defined $user)
          {
            push @subConditions, new Gold::Condition(object => "ProjectUser", name => "Name", value => $user);
          }
          if (defined $machine)
          {
            push @subConditions, new Gold::Condition(object => "ProjectMachine", name => "Name", value => $machine);
          }
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+2");
          push @subConditions, new Gold::Condition(object => "ProjectUser", name => "Project", subject => "ProjectMachine", value => "Project", conj => "And", group => "-1");
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", subject => "ProjectUser", value => "Project", conj => "Or", group => "+1");
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", subject => "ProjectMachine", value => "Project", conj => "And", group => "-2");
  
          # Add id conditions
          my $firstTime = 1;
          my $counter = 0;
          foreach my $id (keys %checkBoth)
          {
            $counter++;
            my $lastTime = ($counter == scalar keys %checkBoth) ? 1 : 0;
      
            if ($firstTime && $lastTime)
            {
              push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "And", group => "0");
            }
            elsif ($firstTime)
            {
              $firstTime = 0;
              push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "And", group => "+1");
            }
            elsif ($lastTime)
            {
              push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "Or", group => "-1");
            }
            else
            {
              push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "Or", group => "0");
            }
          }
    
          my $subResults = $database->select(objects => \@subObjects, selections => \@subSelections, conditions => \@subConditions);
          foreach my $row (@{$subResults->{data}})
          {
            my $accountId = $row->[0];
            $accounts{$accountId} = 1;
          }
        }
            
        # Check User Membership
        if (%checkUser)
        {
          my @subObjects = ( new Gold::Object(name => "AccountProject"), new Gold::Object(name => "ProjectUser"));
          my @subSelections = ( new Gold::Selection(object => "AccountProject", name => "Account") );
          my @subConditions = ();
          push @subConditions, new Gold::Condition(object => "ProjectUser", name => "Active", value => "True");
          if (defined $user)
          {
            push @subConditions, new Gold::Condition(object => "ProjectUser", name => "Name", value => $user);
          }
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+1");
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", subject => "ProjectUser", value => "Project", conj => "Or", group => "-1");
  
          # Add id conditions
          my $firstTime = 1;
          my $counter = 0;
          foreach my $id (keys %checkUser)
          {
            $counter++;
            my $lastTime = ($counter == scalar keys %checkUser) ? 1 : 0;
      
            if ($firstTime && $lastTime)
            {
              push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "And", group => "0");
            }
            elsif ($firstTime)
            {
              $firstTime = 0;
              push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "And", group => "+1");
            }
            elsif ($lastTime)
            {
              push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "Or", group => "-1");
            }
            else
            {
              push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "Or", group => "0");
            }
          }
    
          my $subResults = $database->select(objects => \@subObjects, selections => \@subSelections, conditions => \@subConditions);
          foreach my $row (@{$subResults->{data}})
          {
            my $accountId = $row->[0];
            $accounts{$accountId} = 1;
          }
        }
            
        # Check Machine Membership
        if (%checkMach)
        {
          my @subObjects = ( new Gold::Object(name => "AccountProject"), new Gold::Object(name => "ProjectMachine"));
          my @subSelections = ( new Gold::Selection(object => "AccountProject", name => "Account") );
          my @subConditions = ();
          push @subConditions, new Gold::Condition(object => "ProjectMachine", name => "Active", value => "True");
          if (defined $machine)
          {
            push @subConditions, new Gold::Condition(object => "ProjectMachine", name => "Name", value => $machine);
          }
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+1");
          push @subConditions, new Gold::Condition(object => "AccountProject", name => "Name", subject => "ProjectMachine", value => "Project", conj => "Or", group => "-1");
  
          # Add id conditions
          my $firstTime = 1;
          my $counter = 0;
          foreach my $id (keys %checkMach)
          {
            $counter++;
            my $lastTime = ($counter == scalar keys %checkMach) ? 1 : 0;
      
            if ($firstTime && $lastTime)
            {
              push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "And", group => "0");
            }
            elsif ($firstTime)
            {
              $firstTime = 0;
              push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "And", group => "+1");
            }
            elsif ($lastTime)
            {
              push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "Or", group => "-1");
            }
            else
            {
              push @subConditions, new Gold::Condition(object => "AccountProject", name => "Account", value => $id, conj => "Or", group => "0");
            }
          }
    
          my $subResults = $database->select(objects => \@subObjects, selections => \@subSelections, conditions => \@subConditions);
          foreach my $row (@{$subResults->{data}})
          {
            my $accountId = $row->[0];
            $accounts{$accountId} = 1;
          }
        }
            
        if ($log->is_debug())
        {
          $log->debug("Initial accepted account list is: " . join ',', keys %accounts);
        }
      }
    
      # Only screen these accounts if there are some to do so to
      if (scalar keys %accounts)
      {
        # Check to make sure these accounts are not rejected
        # SELECT DISTINCT Account.Id FROM Account,AccountUser,AccountProject,AccountMachine WHERE AccountProject.Account=Account.Id AND AccountUser.Account=Account.Id AND AccountMachine.Account=Account.Id AND <Id IN AccountList>
    
        my @objects =
        (
          new Gold::Object(name => "Account"),
          new Gold::Object(name => "AccountUser"),
          new Gold::Object(name => "AccountProject"),
          new Gold::Object(name => "AccountMachine")
        );
      
        my @selections = ( new Gold::Selection(object => "Account", name => "Id") );
      
        my @conditions =
        (
          new Gold::Condition(object => "AccountProject", name => "Account", subject => "Account", value => "Id"),
          new Gold::Condition(object => "AccountUser", name => "Account", subject => "Account", value => "Id"),
          new Gold::Condition(object => "AccountMachine", name => "Account", subject => "Account", value => "Id")
        );
      
        my @options = $request->getOptions();
        push @options, new Gold::Option(name => "Unique", value => "True");
    
        # Constrain to list of accepted ids
        my $firstTime = 1;
        my $counter = 0;
        foreach my $id (keys %accounts)
        {
          $counter++;
          my $lastTime = ($counter == scalar keys %accounts) ? 1 : 0;
    
          if ($firstTime && $lastTime)
          {
            push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "And", group => "0");
          }
          elsif ($firstTime)
          {
            $firstTime = 0;
            push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "And", group => "+1");
          }
          elsif ($lastTime)
          {
            push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "Or", group => "-1");
          }
          else
          {
            push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "Or", group => "0");
          }
        }
    
        # Add project conditions
      
        # Wildcarding ignores all restrictions
        if (! defined $project)
        {
          push @conditions, new Gold::Condition(object => "AccountProject", name => "Name", subject => "AccountProject", value => "Name", op => "NE", conj => "And", group => "+1");
        }
      
        # Not a wildcard. Process normally
        else
        {
          push @conditions, new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+3");
          push @conditions, new Gold::Condition(object => "AccountProject", name => "Access", value => "False", conj => "And", group => "-1");
          push @conditions, new Gold::Condition(object => "AccountProject", name => "Name", value => $project, conj => "Or", group => "+1");
          push @conditions, new Gold::Condition(object => "AccountProject", name => "Access", value => "False", conj => "And", group => "-2");
        }
      
        # Add user conditions
      
        # Wildcarding ignores all restrictions
        if (! defined $user)
        {
          push @conditions, new Gold::Condition(object => "AccountUser", name => "Name", subject => "AccountUser", value => "Name", op => "NE", conj => "Or", group => "0");
        }
      
        # Not a wildcard. Process normally
        else
        {
          push @conditions, new Gold::Condition(object => "AccountUser", name => "Name", value => "ANY", conj => "Or", group => "+2");
          push @conditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "False", conj => "And", group => "-1");
          push @conditions, new Gold::Condition(object => "AccountUser", name => "Name", value => $user, conj => "Or", group => "+1");
          push @conditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "False", conj => "And", group => "-1");
          push @conditions, new Gold::Condition(object => "AccountUser", name => "Name", value => "MEMBERS", conj => "Or", group => "+1");
          push @conditions, new Gold::Condition(object => "AccountUser", name => "Access", value => "False", conj => "And", group => "-2");
        }
      
        # Add machine conditions
      
        # Wildcarding ignores all restrictions
        if (! defined $machine)
        {
          push @conditions, new Gold::Condition(object => "AccountMachine", name => "Name", subject => "AccountMachine", value => "Name", op => "NE", conj => "Or", group => "-1");
        }
      
        # Not a wildcard. Process normally
        else
        {
          push @conditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => "ANY", conj => "Or", group => "+2");
          push @conditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "False", conj => "And", group => "-1");
          push @conditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => $machine, conj => "Or", group => "+1");
          push @conditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "False", conj => "And", group => "-1");
          push @conditions, new Gold::Condition(object => "AccountMachine", name => "Name", value => "MEMBERS", conj => "Or", group => "+1");
          push @conditions, new Gold::Condition(object => "AccountMachine", name => "Access", value => "False", conj => "And", group => "-3");
        }
      
        my $results = $database->select(objects => \@objects, selections => \@selections, conditions => \@conditions, options => \@options);
        foreach my $row (@{$results->{data}})
        {
          my $accountId = $row->[0];
    
          # Remove from accounts
          delete $accounts{$accountId};
        }
    
        if ($log->is_debug())
        {
          $log->debug("Post rejection account list is: " . join ',', keys %accounts);
        }
    
        # Factor in ancestor accounts if ignoreAncestors is unspecified or not set to true
        if (! defined $ignoreAncestors || $ignoreAncestors eq "False")
        {
          my %ancestors = ();
          # SELECT Account,Id FROM AccountAccount WHERE Overflow=True
          my @selections = ( new Gold::Selection(name => "Account"), new Gold::Selection(name => "Id") );
          my @conditions = ( new Gold::Condition(name => "Overflow", value => "True") );
          my $results = $database->select(object => "AccountAccount", selections => \@selections, conditions => \@conditions);
          foreach my $row (@{$results->{data}})
          {
            my $parent = $row->[0];
            my $child = $row->[1];
      
            $ancestors{$child}{$parent} = 1;
          }
            
          # Add ancestors a generation at a time until there is no more growth
          while (1)
          {
            my $count = scalar keys %accounts;
            foreach my $account (keys %accounts)
            {
              foreach my $parent (keys %{$ancestors{$account}})
              {
                $accounts{$parent} = 1 unless exists $accounts{$parent};
              }
            }
            last if $count == scalar keys %accounts;
          }
    
          if ($log->is_debug())
          {
            $log->debug("Post ancestral account list is: " . join ',', keys %accounts);
          }
        }
      }
    
      # Return immediately if there are no matching accounts
      if (! scalar keys %accounts)
      {
        return new Gold::Response()->success(0, []);
      }
  
      # Obtain a list of reservations based on the matching accounts
      # SELECT DISTINCT Reservation FROM ReservationAllocation WHERE (Account=<Id> ...)
    
      my @selections =
      (
        new Gold::Selection(name => "Reservation"),
      );
    
      my @conditions = ();
      my @options = ( new Gold::Option(name => "Unique", value => "True") );
    
      # Constrain to list of accepted ids
      my $firstTime = 1;
      my $counter = 0;
      foreach my $id (keys %accounts)
      {
        $counter++;
        my $lastTime = ($counter == scalar keys %accounts) ? 1 : 0;
    
        if ($firstTime && $lastTime)
        {
          push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "And", group => "0");
        }
        elsif ($firstTime)
        {
          $firstTime = 0;
          push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "And", group => "+1");
        }
        elsif ($lastTime)
        {
          push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "Or", group => "-1");
        }
        else
        {
          push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "Or", group => "0");
        }
      }
    
      my $results = $database->select(object => "ReservationAllocation", selections => \@selections, conditions => \@conditions, options => \@options);
      foreach my $row (@{$results->{data}})
      {
        my $reservationId = $row->[0];
        
        $reservations{$reservationId} = 1;
      }

      # Build a new reservation query based on list of reservation ids
      my @newConditions = ();
    
      # Constrain to list of accepted ids
      $firstTime = 1;
      $counter = 0;
      foreach my $id (keys %reservations)
      {
        $counter++;
        my $lastTime = ($counter == scalar keys %reservations) ? 1 : 0;
 
        if ($firstTime && $lastTime)
        {
          push @newConditions, new Gold::Condition(name => "Id", value => $id, conj => "And", group => "0");
        }
        elsif ($firstTime)
        {
          $firstTime = 0;
          push @newConditions, new Gold::Condition(name => "Id", value => $id, conj => "And", group => "+1");
        }
        elsif ($lastTime)
        {
          push @newConditions, new Gold::Condition(name => "Id", value => $id, conj => "Or", group => "-1");
        }
        else
        {
          push @newConditions, new Gold::Condition(name => "Id", value => $id, conj => "Or", group => "0");
        }
      }
    
      # Recast the conditions to eliminate entities and add new reservation conditions
      foreach my $condition ($request->getConditions())
      {
        my $name = $condition->getName();

        if ($name ne "User" && $name ne "Project" && $name ne "Machine")
        {
          push @newConditions, $condition;
        }
      }
      $request->setConditions(\@newConditions);
    }

    # Invoke base Reservation Query
    return Gold::Base->query($request);
  }

  elsif ($object eq "Job")
  {
    my $project = $request->getConditionValue("Project");
    my $user = $request->getConditionValue("User");
    my $machine = $request->getConditionValue("Machine");

    # Override Authorization
    my $authorized = 1;
    if ($request->getOverride())
    {
      $authorized = 0;
    }
    if (! $authorized && defined $project)
    {
      # See if actor is project admin
      # SELECT Admin FROM ProjectUser WHERE Project=$project AND Name=$actor AND Admin=True
      my $subResults = $database->select(object => "ProjectUser", selections => [ new Gold::Selection(name => "Admin") ], conditions => [ new Gold::Condition(name => "Project", value => $project), new Gold::Condition(name => "Name", value => $actor), new Gold::Condition(name => "Admin", value => "True") ]);
      if (@{$subResults->{data}})
      {
        $authorized = 1;
      }
    }
    if (! $authorized && defined $user)
    {
      if ($user eq $actor)
      {
        $authorized = 1;
      }
    }
    #if (! $authorized && defined $machine)
    #{
    #  # See if actor is machine admin
    #  # SELECT Admin FROM MachineUser WHERE Machine=$machine AND Name=$actor AND Admin=True
    #  my $subResults = $database->select(object => "MachineUser", selections => [ new Gold::Selection(name => "Admin") ], conditions => [ new Gold::Condition(name => "Machine", value => $machine), new Gold::Condition(name => "Name", value => $actor), new Gold::Condition(name => "Admin", value => "True") ]);
    #  if (@{$subResults->{data}})
    #  {
    #    $authorized = 1;
    #  }
    #}
    if (! $authorized)
    {
      return new Gold::Response()->failure("444", "$actor is not authorized to list the jobs");
    }

    # Invoke base Job Query
    return Gold::Base->query($request);
  }

  elsif ($object eq "Transaction")
  {
    my $project = $request->getConditionValue("Project");
    my $user = $request->getConditionValue("User");
    my $machine = $request->getConditionValue("Machine");
    my $actorCond = $request->getConditionValue("Actor");

    # Override Authorization
    my $authorized = 1;
    if ($request->getOverride())
    {
      $authorized = 0;
    }
    if (! $authorized && defined $actorCond)
    {
      if ($actor eq $actorCond)
      {
        $authorized = 1;
      }
    }
    if (! $authorized && defined $project)
    {
      # See if actor is project admin
      # SELECT Admin FROM ProjectUser WHERE Project=$project AND Name=$actor AND Admin=True
      my $subResults = $database->select(object => "ProjectUser", selections => [ new Gold::Selection(name => "Admin") ], conditions => [ new Gold::Condition(name => "Project", value => $project), new Gold::Condition(name => "Name", value => $actor), new Gold::Condition(name => "Admin", value => "True") ]);
      if (@{$subResults->{data}})
      {
        $authorized = 1;
      }
    }
    if (! $authorized && defined $user)
    {
      if ($user eq $actor)
      {
        $authorized = 1;
      }
    }
    #if (! $authorized && defined $machine)
    #{
    #  # See if actor is machine admin
    #  # SELECT Admin FROM MachineUser WHERE Machine=$machine AND Name=$actor AND Admin=True
    #  my $subResults = $database->select(object => "MachineUser", selections => [ new Gold::Selection(name => "Admin") ], conditions => [ new Gold::Condition(name => "Machine", value => $machine), new Gold::Condition(name => "Name", value => $actor), new Gold::Condition(name => "Admin", value => "True") ]);
    #  if (@{$subResults->{data}})
    #  {
    #    $authorized = 1;
    #  }
    #}
    if (! $authorized)
    {
      return new Gold::Response()->failure("444", "$actor is not authorized to list the transactions");
    }

    # Invoke base Transaction Query
    return Gold::Base->query($request);
  }

  else
  {
    return new Gold::Response()->failure("315", "The Bank class does not implement $object Query");
  }
}
  

# ----------------------------------------------------------------------------
# $response = quote($request, $requestId);
# ----------------------------------------------------------------------------

# Quote (Job)
sub quote
{
  my ($class, $request, $requestId) = @_;

  if ($log->is_debug())
  {
    $log->debug("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my $object = $request->getObject();
  my $actor = $request->getActor();
  my $database = $request->getDatabase();
  my @options = $request->getOptions();
  my $quoteMessage = "";
  my $backMessage = "";
  my $forwardMessage = "";
  my $quotationId = 0;
  my $id = 0;
  my $now = time;
  my $startTime = $now;
  my $endTime = 2147483647; # Infinity
  my $callType = $request->getOptionValue("CallType") || "Normal";
  if ($callType ne "Normal" && $callType ne "Back" && $callType ne "Forward")
  {
    $callType = "Normal";
  }
  my $backProject = $request->getOptionValue("BackProject");
  my $backUser = $request->getOptionValue("BackUser");
  my $backMachine = $request->getOptionValue("BackMachine");
  my $forwardProject = $request->getOptionValue("ForwardProject");
  my $forwardUser = $request->getOptionValue("ForwardUser");
  my $forwardMachine = $request->getOptionValue("ForwardMachine");
  my %quotes = ();

  if ($object ne "Job")
  {
    return new Gold::Response()->failure("315", "The Bank class does not implement $object Quote");
  }

  # Determine whether to create quotation and job records
  my $guarantee;
  my $guaranteeOption = $request->getOptionValue("Guarantee");
  if (defined $guaranteeOption && $guaranteeOption =~ /^True$/i)
  {
    $guarantee = 1;
  }
  else
  {
    $guarantee = 0;
  }

  # Data must be present
  my $doc = XML::LibXML::Document->new();
  my $data = $request->getDataElement();
  $doc->setDocumentElement($data);
  unless (defined $data)
  {
    return new Gold::Response()->failure("314", "Job data is required");
  }

  # Return failure if we detect a job object property we do not support
  foreach my $property (qw(JobGroup JobDefaults TaskGroup TaskGroupDefaults Requested Delivered Resource Extension))
  {
    if ($data->findnodes("//$property"))
    {
      return new Gold::Response()->failure("710", "The $property element is not supported");
    }
  }

  # We currently only support a solitary job
  my @jobs = $data->findnodes("/Data/Job");
  if (@jobs == 0)
  {
    return new Gold::Response()->failure("314", "At least one job must be specified");
  }
  elsif (@jobs > 1)
  {
    return new Gold::Response()->failure("314", "Only one job may be specified");
  }

  my $job = $jobs[0];

  # Build up a list of job attributes
  my %attributes = ();
  my $results = $database->select(object => "Attribute", selections => [ new Gold::Selection(name => "Name") ], conditions => [ new Gold::Condition(name => "Object", value => "Job"), new Gold::Condition(name => "Hidden", value => "False") ]);
  foreach my $row (@{$results->{data}})
  {
      my $name = $row->[0];
      $attributes{$name} = 1;
  }
  
  # There are some properties that we explicitly look for
  my @assignments = ();

  # JobId
  my $jobId = $job->findvalue("//JobId");
  if ($jobId ne "")
  {
    if (exists $attributes{JobId})
    {
      delete $attributes{JobId};
      push @assignments, new Gold::Assignment(name => "JobId", value => $jobId);
    }
  }

  # User
  my $user = $job->findvalue("//UserId");
  if ($callType eq "Back" && defined $backUser) { $user = $backUser; }
  if ($callType eq "Forward" && defined $forwardUser) { $user = $forwardUser; }
  if ($user eq "")
  {
    # Look for a system default project
    $user = $config->get_property("user.default", $USER_DEFAULT);
    if ($user eq "NONE" || $user eq "")
    {
      return new Gold::Response()->failure("314", "A user must be specified for the quote");
    }
  }

  # Verify user
  # SELECT Active,Special FROM User WHERE Name=$user
  my $subResults = $database->select(object => "User", selections => [ new Gold::Selection(name => "Active"), new Gold::Selection(name => "Special") ], conditions => [ new Gold::Condition(name => "Name", value => $user) ]);
  if (@{$subResults->{data}})
  {
    my $active = ${$subResults->{data}}[0]->[0];
    my $special = ${$subResults->{data}}[0]->[1];
    if (defined $active && $active ne "True")
    {
      return new Gold::Response()->failure("740", "User $user is not active");
    }
    if (defined $special && $special eq "True")
    {
      return new Gold::Response()->failure("740", "User $user is special");
    }
  }
  else
  {
    if ($config->get_property("user.autogen", $USER_AUTOGEN) =~ /true/i)
    {
      # Create the user
      my $subRequest = new Gold::Request(database => $database, object => "User", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Name", value => $user), new Gold::Assignment(name => "Description", value => "Auto-Generated") ]);
      my $subResponse = Gold::Base->create($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to create user: " . $subResponse->getMessage());
      }
    }
    else
    {
      return new Gold::Response()->failure("740", "User $user does not exist");
    }
  }
    
  if (exists $attributes{User})
  {
    push @assignments, new Gold::Assignment(name => "User", value => $user);
    delete $attributes{User};
  }

  # Project
  my $project = $job->findvalue("//ProjectId");
  if ($callType eq "Back" && defined $backProject) { $project = $backProject; }
  if ($callType eq "Forward" && defined $forwardProject) { $project = $forwardProject; }
  if ($project eq "")
  {
    # Look for a user default project
    # SELECT DefaultProject FROM User WHERE Name=$user
    my $subResults = $database->select(object => "User", selections => [ new Gold::Selection(name => "DefaultProject") ], conditions => [ new Gold::Condition(name => "Name", value => $user) ]);
    if (@{$subResults->{data}})
    {
      my $defaultProject = ${$subResults->{data}}[0]->[0];
      if (defined $defaultProject)
      {
        $project = $defaultProject;
      }
    }
    # Look for a system default project
    else
    {
      $project = $config->get_property("project.default", $PROJECT_DEFAULT);
      if ($project eq "NONE" || $project eq "")
      {
        return new Gold::Response()->failure("314", "A project must be specified for the quote\nor a default project must exist for the user");
      }
    }
  }

  # Verify project
  # SELECT Active,Special FROM Project WHERE Name=$project
  $subResults = $database->select(object => "Project", selections => [ new Gold::Selection(name => "Active"), new Gold::Selection(name => "Special") ], conditions => [ new Gold::Condition(name => "Name", value => $project) ]);
  if (@{$subResults->{data}})
  {
    my $active = ${$subResults->{data}}[0]->[0];
    my $special = ${$subResults->{data}}[0]->[1];
    if (defined $active && $active ne "True")
    {
      return new Gold::Response()->failure("740", "Project $project is not active");
    }
    if (defined $special && $special eq "True")
    {
      return new Gold::Response()->failure("740", "Project $project is special");
    }
  }
  else
  {
    if ($config->get_property("project.autogen", $PROJECT_AUTOGEN) =~ /true/i)
    {
      # Create the project
      my $subRequest = new Gold::Request(database => $database, object => "Project", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Name", value => $project), new Gold::Assignment(name => "Description", value => "Auto-Generated") ]);
      my $subResponse = Gold::Base->create($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to create project: " . $subResponse->getMessage());
      }
    }
    else
    {
      return new Gold::Response()->failure("740", "Project $project does not exist");
    }
  }

  if (exists $attributes{Project})
  {
    delete $attributes{Project};
    push @assignments, new Gold::Assignment(name => "Project", value => $project);
  }

  # Machine
  my $machine = $job->findvalue("//MachineName");
  if ($callType eq "Back" && defined $backMachine) { $machine = $backMachine; }
  if ($callType eq "Forward" && defined $forwardMachine) { $machine = $forwardMachine; }
  if ($machine eq "")
  {
    # Look for a system default machine
    $machine = $config->get_property("machine.default", $MACHINE_DEFAULT);
    if ($machine eq "NONE" || $machine eq "")
    {
      return new Gold::Response()->failure("314", "A machine must be specified for the quote");
    }
  }

  # Verify machine
  # SELECT Active,Special FROM Machine WHERE Name=$machine
  $subResults = $database->select(object => "Machine", selections => [ new Gold::Selection(name => "Active"), new Gold::Selection(name => "Special") ], conditions => [ new Gold::Condition(name => "Name", value => $machine) ]);
  if (@{$subResults->{data}})
  {
    my $active = ${$subResults->{data}}[0]->[0];
    my $special = ${$subResults->{data}}[0]->[1];
    if (defined $active && $active ne "True")
    {
      return new Gold::Response()->failure("740", "Machine $machine is not active");
    }
    if (defined $special && $special eq "True")
    {
      return new Gold::Response()->failure("740", "Machine $machine is special");
    }
  }
  else
  {
    if ($config->get_property("machine.autogen", $MACHINE_AUTOGEN) =~ /true/i)
    {
      # Create the machine
      my $subRequest = new Gold::Request(database => $database, object => "Machine", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Name", value => $machine), new Gold::Assignment(name => "Description", value => "Auto-Generated") ]);
      my $subResponse = Gold::Base->create($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to create machine: " . $subResponse->getMessage());
      }
    }
    else
    {
      return new Gold::Response()->failure("740", "Machine $machine does not exist");
    }
  }

  if (exists $attributes{Machine})
  {
    delete $attributes{Machine};
    push @assignments, new Gold::Assignment(name => "Machine", value => $machine);
  }

  # Wall Duration
  my $wallDuration = $job->findvalue("//WallDuration");
  if ($wallDuration ne "")
  {
    delete $attributes{WallDuration};
    push @assignments, new Gold::Assignment(name => "WallDuration", value => $wallDuration);
  }
  else
  {
    return new Gold::Response()->failure("314", "A wall duration must be specified for the reservation");
  }
  if ($wallDuration !~ /^\d+$/)
  {
    return new Gold::Response()->failure("314", "The wall duration must be an integer number of seconds");
  }
 
  # Look for Charge
  my $quote = $job->findvalue("//Charge");
  my $itemizedCharges;

  # Process the remaining job attributes
  foreach my $name (keys %attributes)
  {
    my $value = $job->findvalue("//$name");
    if ($value ne "")
    {
      delete $attributes{$name};
      push @assignments, new Gold::Assignment(name => "$name", value => $value);
    }
  }

  # Start Time
  my $start = $job->findvalue("//StartTime");
  if ($start ne "")
  {
    delete $attributes{StartTime};
    push @assignments, new Gold::Assignment(name => "StartTime", value => $start);
    $startTime = $start;
  }

  # End Time
  my $end = $job->findvalue("//EndTime");
  if ($end ne "")
  {
    delete $attributes{EndTime};
    push @assignments, new Gold::Assignment(name => "EndTime", value => $end);
    $endTime = $end;
  }
  else
  {
    $endTime = $startTime + $wallDuration + 604800; # A week plus length of the job
  }

  if ($guarantee)
  {
    # Create job record
    push @assignments, new Gold::Assignment(name => "Stage", value => "Quote");
    push @assignments, new Gold::Assignment(name => "Charge", value => 0);
    push @assignments, new Gold::Assignment(name => "CallType", value => $callType);
    my $subRequest = new Gold::Request(database => $database, object => "Job", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), options => [ new Gold::Option(name => "JobId", value => $jobId) ], assignments => \@assignments);
    my $subResponse = Gold::Base->create($subRequest, $requestId);
    if ($subResponse->getStatus() eq "Failure")
    {
      return new Gold::Response()->failure($subResponse->getCode(), "Unable to create job record: " . $subResponse->getMessage());
    }

    # Figure out the id of the job we just created
    $id = $subResponse->getDatumValue("Id");

    # Create the quotation
    $subRequest = new Gold::Request(database => $database, object => "Quotation", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "StartTime", value => $startTime), new Gold::Assignment(name => "EndTime", value => $endTime), new Gold::Assignment(name => "Job", value => $id), new Gold::Assignment(name => "User", value => $user), new Gold::Assignment(name => "Project", value => $project), new Gold::Assignment(name => "Machine", value => $machine), new Gold::Assignment(name => "WallDuration", value => $wallDuration), new Gold::Assignment(name => "CallType", value => $callType) ]);
    $subResponse = Gold::Base->create($subRequest, $requestId);
    if ($subResponse->getStatus() eq "Failure")
    {
      return new Gold::Response()->failure($subResponse->getCode(), "Unable to create quotation: " . $subResponse->getMessage());
    }
  
    # Figure out the id of the quotation we just created
    $quotationId = $subResponse->getDatumValue("Id");
  }

  # Calculate quote amount if not already specified
  if ($quote eq "")
  {
    $quote = 0;

	  # Look up the current charge rates
	  # SELECT Type,Name,Rate FROM ChargeRate
	  my %chargeRate = ();
	  $results = $database->select(object => "ChargeRate", selections => [ new Gold::Selection(name => "Type"), new Gold::Selection(name => "Name"), new Gold::Selection(name => "Rate") ]);
	  foreach my $row (@{$results->{data}})
	  {
	    my $type = $row->[0];
	    my $name = $row->[1];
	    my $rate = $row->[2];
	
	    $chargeRate{$type}{$name} = $rate;
	  }
	
	  # Iterate over the charge multipliers
	  my $multiplier = 1;
	  my @multiplierCharges = ( "$wallDuration [WallDuration]" );
	  foreach my $type (keys %chargeRate)
	  {
	    next if $type eq "Resource";
	
	    # Look for this charge type in the job properties
	    my $name = $job->findvalue("//$type");
	    if ($name ne "")
	    {
	      if (exists $chargeRate{$type}{$name})
	      {
	        $multiplier *= $chargeRate{$type}{$name};
	        push @multiplierCharges, "$chargeRate{$type}{$name} [ChargeRate{$type}{$name}]";
	      }
	      else
	      {
	        $quoteMessage .= "\nWarning: ChargeRate for $type $name is not defined";
	      }
	
	      if ($guarantee)
	      {
	        # Create a quotation charge rate
	        my $subRequest = new Gold::Request(database => $database, object => "QuotationChargeRate", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Quotation", value => $quotationId), new Gold::Assignment(name => "Type", value => $type), new Gold::Assignment(name => "Name", value => $name), new Gold::Assignment(name => "Rate", value => $chargeRate{$type}{$name}) ]);
	        my $subResponse = Gold::Base->create($subRequest, $requestId);
	        if ($subResponse->getStatus() eq "Failure")
	        {
	          return new Gold::Response()->failure($subResponse->getCode(), "Unable to create quotation charge rate: " . $subResponse->getMessage());
	        }
	      }
	    }
	  }
	
	  # Iterate over the consumable resources
	  my @resourceCharges = ();
	  foreach my $name (keys %{$chargeRate{Resource}})
	  {
	    # Look for this resource in the job properties
	    my $amount = $job->findvalue("//$name");
	    if ($amount ne "")
	    {
	      # Calculate quote amount
	      my $rate = $chargeRate{Resource}{$name};
	      my $subQuote = $amount * $rate * $wallDuration * $multiplier;
	      $quote = $quote + $subQuote;
	      push @resourceCharges, "( $amount [$name] * $rate [ChargeRate{Resource}{$name}] )";
	  
	      if ($guarantee)
	      {
	        # Create a quotation charge rate
	        my $subRequest = new Gold::Request(database => $database, object => "QuotationChargeRate", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Quotation", value => $quotationId), new Gold::Assignment(name => "Type", value => "Resource"), new Gold::Assignment(name => "Name", value => $name), new Gold::Assignment(name => "Rate", value => $chargeRate{Resource}{$name}) ]);
	        my $subResponse = Gold::Base->create($subRequest, $requestId);
	        if ($subResponse->getStatus() eq "Failure")
	        {
	          return new Gold::Response()->failure($subResponse->getCode(), "Unable to create quotation charge rate: " . $subResponse->getMessage());
	        }
	      }
	    }
	  }
	
	  $itemizedCharges = "( " . join(' + ', @resourceCharges), " ) * " . join(' * ', @multiplierCharges) . " = $quote";
  }

  # If Charge is not included in job properties,
  # look for itemized charges in an option
  else
  {
    $itemizedCharges = $request->getOptionValue("ItemizedCharges");
    if (! defined $itemizedCharges)
    {
      $itemizedCharges = "$quote [externally calculated] = $quote";
    }
  }

  if ($guarantee)
  {
    # Modify the amount
    my $subRequest = new Gold::Request(database => $database, object => "Quotation", action => "Modify", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Amount", value => $quote) ], conditions => [ new Gold::Condition(name => "Id", value => $quotationId) ]);
    my $subResponse = Gold::Base->modify($subRequest, $requestId);
    if ($subResponse->getStatus() eq "Failure")
    {
      return new Gold::Response()->failure($subResponse->getCode(), "Unable to modify quotation: " . $subResponse->getMessage());
    }
  }

  # Log the transaction
  Gold::Bank->logTransaction(database => $database, requestId => $requestId, txnId => $database->nextId("Transaction"), object => "Job", action => "Quote", actor => $actor, conditions => [ new Gold::Condition(name => "Amount", value => $quote) ], assignments => \@assignments, options => [ new Gold::Option(name => "ItemizedCharges", value => $itemizedCharges) ], count => 1);

  # Verify sufficient funds exist to satisfy the quote
  if ($quote >= 0) # I want to always check for active accounts even if quote is 0
  {
    my $remaining = $quote;
    my %accounts = ();
    my %allocations = ();

    # Refresh Allocations
    my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Refresh");
    my $subResponse = Gold::Bank->refresh($subRequest, $requestId);
    if ($subResponse->getStatus() eq "Failure")
    {
      return new Gold::Response()->failure($subResponse->getCode(), "Failed while refreshing allocations: " . $subResponse->getMessage());
    }
    
    # Construct list of viable accounts
    {
      # SELECT Account.Id,AccountProject.Name,AccountUser.Name,AccountMachine.Name FROM Account,AccountUser,AccountProject,AccountMachine,Allocation WHERE Allocation.StartTime<=$startTime AND Allocation.EndTime>$startTime AND Allocation.CallType='$callType' AND AccountProject.Account=Account.Id AND AccountUser.Account=Account.Id AND AccountMachine.Account=Account.Id AND Allocation.Account=Account.Id
    
      my @objects =
      (
        new Gold::Object(name => "Account"),
        new Gold::Object(name => "AccountUser"),
        new Gold::Object(name => "AccountProject"),
        new Gold::Object(name => "AccountMachine"),
        new Gold::Object(name => "Allocation"),
      );
    
      my @selections =
      (
        new Gold::Selection(object => "Account", name => "Id"),
        new Gold::Selection(object => "AccountProject", name => "Name"),
        new Gold::Selection(object => "AccountUser", name => "Name"),
        new Gold::Selection(object => "AccountMachine", name => "Name")
      );
    
      my @conditions =
      (
        new Gold::Condition(object => "Allocation", name => "Account", subject => "Account", value => "Id"),
        new Gold::Condition(object => "AccountProject", name => "Account", subject => "Account", value => "Id"),
        new Gold::Condition(object => "AccountUser", name => "Account", subject => "Account", value => "Id"),
        new Gold::Condition(object => "AccountMachine", name => "Account", subject => "Account", value => "Id"),

        # Allocation conditions
        new Gold::Condition(object => "Allocation", name => "StartTime", value => $startTime, op => "LE"),
        new Gold::Condition(object => "Allocation", name => "EndTime", value => $startTime, op => "GT"),
        new Gold::Condition(object => "Allocation", name => "CallType", value => $callType),
        
        # Project conditions
        new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+3"),
        new Gold::Condition(object => "AccountProject", name => "Access", value => "True", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountProject", name => "Name", value => $project, conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountProject", name => "Access", value => "True", conj => "And", group => "-2"),

        # User conditions
        new Gold::Condition(object => "AccountUser", name => "Name", value => "ANY", conj => "And", group => "+2"),
        new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountUser", name => "Name", value => $user, conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountUser", name => "Name", value => "MEMBERS", conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-2"),

        # Machine conditions
        new Gold::Condition(object => "AccountMachine", name => "Name", value => "ANY", conj => "And", group => "+2"),
        new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountMachine", name => "Name", value => $machine, conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountMachine", name => "Name", value => "MEMBERS", conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-3"),
      );
    
      my $results = $database->select(objects => \@objects, selections => \@selections, conditions => \@conditions);
      foreach my $row (@{$results->{data}})
      {
        my $accountId = $row->[0];
        my $accountProject = $row->[1];
        my $accountUser = $row->[2];
        my $accountMachine = $row->[3];
        
        # Check membership
        if ($accountUser eq "MEMBERS" || $accountMachine eq "MEMBERS")
        {
          my @selections = ();
          my @conditions = ();
          my @objects = ();
          
          if ($accountUser eq "MEMBERS")
          {
            push @selections, new Gold::Selection(object => "ProjectUser", name => "Project");
            push @objects, new Gold::Object(name => "ProjectUser");
            if (defined $user)
            {
              push @conditions, new Gold::Condition(object => "ProjectUser", name => "Name", value => $user);
            }
            push @conditions, new Gold::Condition(object => "ProjectUser", name => "Active", value => "True");
            if ($accountProject ne "ANY")
            {
              push @conditions, new Gold::Condition(object => "ProjectUser", name => "Project", value => $accountProject);
            }
          }
    
          if ($accountMachine eq "MEMBERS")
          {
            push @selections, new Gold::Selection(object => "ProjectMachine", name => "Project");
            push @objects, new Gold::Object(name => "ProjectMachine");
            if (defined $machine)
            {
              push @conditions, new Gold::Condition(object => "ProjectMachine", name => "Name", value => $machine);
            }
            push @conditions, new Gold::Condition(object => "ProjectMachine", name => "Active", value => "True");
            if ($accountProject ne "ANY")
            {
              push @conditions, new Gold::Condition(object => "ProjectMachine", name => "Project", value => $accountProject);
            }
          }
    
          if ($accountUser eq "MEMBERS" && $accountMachine eq "MEMBERS")
          {
            push @conditions, new Gold::Condition(object => "ProjectUser", name => "Project", subject => "ProjectMachine", value => "Project");
          }
    
          # If there is a matching member found, add the account
          my $subResults = $database->select(objects => \@objects, selections => \@selections, conditions => \@conditions);
          if (@{$subResults->{data}})
          {
            # We need to rank accounts by how specific they are
            my $weight = 100 * generality($accountProject) + 10 * generality($accountUser) + generality($accountMachine);
            if (! exists $accounts{$accountId} || $weight < $accounts{$accountId})
            {
              $accounts{$accountId} = $weight;
            }
          }
        }
        
        # Otherwise just add the account
        else 
        {
          # We need to rank accounts by how specific they are
          my $weight = 100 * generality($accountProject) + 10 * generality($accountUser) + generality($accountMachine);
          if (! exists $accounts{$accountId} || $weight < $accounts{$accountId})
          {
            $accounts{$accountId} = $weight;
          }
        }
      }
    
      if ($log->is_debug())
      {
        $log->debug("Initial accepted quote account list is: " . join ',', keys %accounts);
      }
    }
  
    # Only screen these accounts if there are some to do so to
    if (scalar keys %accounts)
    {
      # Check to make sure these accounts are not rejected
      # SELECT DISTINCT Account.Id FROM Account,AccountUser,AccountProject,AccountMachine WHERE AccountProject.Account=Account.Id AND AccountUser.Account=Account.Id AND AccountMachine.Account=Account.Id AND <Id IN AccountList>
  
      my @objects =
      (
        new Gold::Object(name => "Account"),
        new Gold::Object(name => "AccountUser"),
        new Gold::Object(name => "AccountProject"),
        new Gold::Object(name => "AccountMachine")
      );
    
      my @selections = ( new Gold::Selection(object => "Account", name => "Id") );
    
      my @conditions =
      (
        new Gold::Condition(object => "AccountProject", name => "Account", subject => "Account", value => "Id"),
        new Gold::Condition(object => "AccountUser", name => "Account", subject => "Account", value => "Id"),
        new Gold::Condition(object => "AccountMachine", name => "Account", subject => "Account", value => "Id"),

        # Project conditions
        new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+3"),
        new Gold::Condition(object => "AccountProject", name => "Access", value => "False", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountProject", name => "Name", value => $project, conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountProject", name => "Access", value => "False", conj => "And", group => "-2"),
    
        # User conditions
        new Gold::Condition(object => "AccountUser", name => "Name", value => "ANY", conj => "Or", group => "+2"),
        new Gold::Condition(object => "AccountUser", name => "Access", value => "False", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountUser", name => "Name", value => $user, conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountUser", name => "Access", value => "False", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountUser", name => "Name", value => "MEMBERS", conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountUser", name => "Access", value => "False", conj => "And", group => "-2"),

        # Machine conditions
        new Gold::Condition(object => "AccountMachine", name => "Name", value => "ANY", conj => "Or", group => "+2"),
        new Gold::Condition(object => "AccountMachine", name => "Access", value => "False", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountMachine", name => "Name", value => $machine, conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountMachine", name => "Access", value => "False", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountMachine", name => "Name", value => "MEMBERS", conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountMachine", name => "Access", value => "False", conj => "And", group => "-3"),
      );
    
      my @options = ( new Gold::Option(name => "Unique", value => "True") );
  
      # Constrain to list of accepted ids
      my $firstTime = 1;
      my $counter = 0;
      foreach my $id (keys %accounts)
      {
        $counter++;
        my $lastTime = ($counter == scalar keys %accounts) ? 1 : 0;
  
        if ($firstTime && $lastTime)
        {
          push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "And", group => "0");
        }
        elsif ($firstTime)
        {
          $firstTime = 0;
          push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "And", group => "+1");
        }
        elsif ($lastTime)
        {
          push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "Or", group => "-1");
        }
        else
        {
          push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "Or", group => "0");
        }
      }
  
      my $results = $database->select(objects => \@objects, selections => \@selections, conditions => \@conditions, options => \@options);
      foreach my $row (@{$results->{data}})
      {
        my $accountId = $row->[0];
  
        # Remove from accounts
        delete $accounts{$accountId};
      }
  
      if ($log->is_debug())
      {
        $log->debug("Post rejection quote account list is: " . join ',', keys %accounts);
      }
    }
  
    # Add ancestor accounts
    # Build up account linkages
    my %ancestors = ();
    # SELECT Account,Id FROM AccountAccount WHERE Overflow=True
  
    my @selections =
    (
      new Gold::Selection(name => "Account"),
      new Gold::Selection(name => "Id"),
    );
  
    my @conditions =
    (
      new Gold::Condition(name => "Overflow", value => "True")
    );
  
    my $results = $database->select(object => "AccountAccount", selections => \@selections, conditions => \@conditions);
    foreach my $row (@{$results->{data}})
    {
      my $parent = $row->[0];
      my $child = $row->[1];
  
      $ancestors{$child}{$parent} = 1;
    }
  
    # Add ancestors a generation at a time until there is no more growth
    my $distance = 100;
    while (1)
    {
      $distance *= 10;
      my $count = scalar keys %accounts;
      foreach my $account (keys %accounts)
      {
        foreach my $parent (keys %{$ancestors{$account}})
        {
          $accounts{$parent} = $distance unless exists $accounts{$parent};
        }
      }
      last if $count == scalar keys %accounts;
    }
  
    if ($log->is_debug())
    {
      $log->debug("Post ancestral account list is: " . join ',', keys %accounts);
    }
  
    # Fail if there are no acounts to quote against
    if (! scalar keys %accounts)
    {
      return new Gold::Response()->failure("782", "Insufficient funds: There are no valid allocations to satisfy the quotation");
    }
  
    # Quote Back if BackHost option is specified and CallType is Normal
    my $backHost = $request->getOptionValue("BackHost");
    if (defined $backHost && $callType eq "Normal")
    {
      my $backPort = $request->getOptionValue("BackPort") || 7112;
  
      # Update the (cloned) job data with the quote (for quote back)
      my $dataClone = $data->cloneNode(1);
      my @jobClones = $dataClone->getChildrenByTagName("Job");
      my $chargeElement = new XML::LibXML::Element("Charge");
      $chargeElement->appendText($quote);
      $jobClones[0]->appendChild($chargeElement);

      # Build Back Quote Request
      my $backRequest = new Gold::Request(object => "Job", action => "Quote");
      $backRequest->setDataElement($dataClone);
      $backRequest->setOption("CallType", "Back");
      $backRequest->setOption("Guarantee", "True") if $guarantee;
      $backRequest->setOption("BackProject", $backProject) if defined $backProject;
      $backRequest->setOption("BackUser", $backUser) if defined $backUser;
      $backRequest->setOption("BackMachine", $backMachine) if defined $backMachine;
      $backRequest->setOption("ItemizedCharges", $itemizedCharges);
  
      # Use long form of message send in order to specify alternate host and port
      my $messageChunk = new Gold::Chunk()->setRequest($backRequest);
      my $message = new Gold::Message();
      $message->sendChunk($messageChunk, $backHost, $backPort);
      my $reply = $message->getReply();
      my $replyChunk = $reply->receiveChunk(); 
      my $backResponse = $replyChunk->getResponse();
      $backMessage = "\nBack Quote: " . $backResponse->getMessage();
      if ($backResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($backResponse->getCode(), "Back Quote Failed: " . $backResponse->getMessage() . ".\nQuotation Aborted.");
      }
    }

    # Lookup active allocations from account list
    # SELECT Id,Account,Amount,CreditLimit,EndTime FROM Allocation WHERE StartTime<=$startTime AND EndTime>$startTime AND CallType=$callType AND (Account=<Id> ...)
  
    @selections =
    (
      new Gold::Selection(name => "Id"),
      new Gold::Selection(name => "Account"),
      new Gold::Selection(name => "Amount"),
      new Gold::Selection(name => "CreditLimit"),
      new Gold::Selection(name => "EndTime"),
    );
  
    @conditions =
    (
      new Gold::Condition(name => "StartTime", value => $startTime, op => "LE"),
      new Gold::Condition(name => "EndTime", value => $startTime, op => "GT"),
      new Gold::Condition(name => "CallType", value => $callType),
    );
  
    # Constrain to list of accepted ids
    my $firstTime = 1;
    my $counter = 0;
    foreach my $id (keys %accounts)
    {
      $counter++;
      my $lastTime = ($counter == scalar keys %accounts) ? 1 : 0;
  
      if ($firstTime && $lastTime)
      {
        push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "And", group => "0");
      }
      elsif ($firstTime)
      {
        $firstTime = 0;
        push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "And", group => "+1");
      }
      elsif ($lastTime)
      {
        push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "Or", group => "-1");
      }
      else
      {
        push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "Or", group => "0");
      }
    }
  
    $results = $database->select(object => "Allocation", selections => \@selections, conditions => \@conditions);
    foreach my $row (@{$results->{data}})
    {
      my $allocationId = $row->[0];
      my $accountId = $row->[1];
      my $allocationAmount = $row->[2];
      my $allocationCreditLimit = $row->[3];
      my $allocationEndTime = $row->[4];
      
      $allocations{$allocationId}{account} = $accountId;
      $allocations{$allocationId}{endTime} = $allocationEndTime;
      $allocations{$allocationId}{weight} = $distance * $allocationEndTime + $accounts{$accountId};
      $allocations{$allocationId}{balance} = $allocationAmount + $allocationCreditLimit;
    }
  
    # Subtract reservations from allocation balances
    # Lookup reservation amounts against these accounts
    # SELECT ReservationAllocation.Id,ReservationAllocation.Amount FROM Reservation,ReservationAllocation WHERE Reservation.Id=ReservationAllocation.Reservation AND Reservation.StartTime<=$startTime AND Reservation.EndTime>$startTime AND (Account=<Id> ...)

    my @objects =
    (
      new Gold::Object(name => "Reservation"),
      new Gold::Object(name => "ReservationAllocation"),
    );
  
    @selections =
    (
      new Gold::Selection(object => "ReservationAllocation", name => "Id"),
      new Gold::Selection(object => "ReservationAllocation", name => "Amount"),
    );
  
    @conditions =
    (
      new Gold::Condition(object => "Reservation", name => "Id", subject => "ReservationAllocation", value => "Reservation"),
      new Gold::Condition(object => "Reservation", name => "StartTime", value => $startTime, op => "LE"),
      new Gold::Condition(object => "Reservation", name => "EndTime", value => $startTime, op => "GT"),
    );
  
    # Constrain to list of accepted ids
    $firstTime = 1;
    $counter = 0;
    foreach my $id (keys %accounts)
    {
      $counter++;
      my $lastTime = ($counter == scalar keys %accounts) ? 1 : 0;
  
      if ($firstTime && $lastTime)
      {
        push @conditions, new Gold::Condition(object => "ReservationAllocation", name => "Account", value => $id, conj => "And", group => "0");
      }
      elsif ($firstTime)
      {
        $firstTime = 0;
        push @conditions, new Gold::Condition(object => "ReservationAllocation", name => "Account", value => $id, conj => "And", group => "+1");
      }
      elsif ($lastTime)
      {
        push @conditions, new Gold::Condition(object => "ReservationAllocation", name => "Account", value => $id, conj => "Or", group => "-1");
      }
      else
      {
        push @conditions, new Gold::Condition(object => "ReservationAllocation", name => "Account", value => $id, conj => "Or", group => "0");
      }
    }
  
    $results = $database->select(objects => \@objects, selections => \@selections, conditions => \@conditions);
    foreach my $row (@{$results->{data}})
    {
      my $allocationId = $row->[0];
      my $reservationAmount = $row->[1];
      
      if (exists $allocations{$allocationId})
      {
        $allocations{$allocationId}{balance} -= $reservationAmount;
      }
    }
  
    # Sort the allocations by weight
    my @allocations = sort { $allocations{$a}{weight} <=> $allocations{$b}{weight} } keys %allocations;
  
    # Iterate through the allocation list
    foreach my $allocationId (@allocations)
    {
      # The amount I subtract from this allocation should be the minimum of:
      # 1. $remaining (the amount left to withdraw)
      # 2. $allocations{$allocationId}{balance} (the amount available within this allocation (considering reservations and credit))
      my $accountId = $allocations{$allocationId}{account};
      my $debitAmount = min($remaining, $allocations{$allocationId}{balance});
      next unless $debitAmount > 0;
  
      # Forward the quotation to the forwarding account if necessary
      my $results = $database->select(objects => [ new Gold::Object(name => "AccountOrganization"), new Gold::Object(name => "Organization") ], selections => [ new Gold::Selection(object => "AccountOrganization", name => "Name"), new Gold::Selection(object => "AccountOrganization", name => "User"), new Gold::Selection(object => "AccountOrganization", name => "Project"), new Gold::Selection(object => "AccountOrganization", name => "Machine"), new Gold::Selection(object => "Organization", name => "Host"), new Gold::Selection(object => "Organization", name => "Port") ], conditions => [ new Gold::Condition(name => "Account", value => $accountId), new Gold::Condition(object => "AccountOrganization", name => "Name", subject => "Organization", value => "Name") ]);
      foreach my $row (@{$results->{data}})
      {
        my $organization = $row->[0];
        my $forwardUser = $row->[1];
        my $forwardProject = $row->[2];
        my $forwardMachine = $row->[3];
        my $forwardHost = $row->[4];
        my $forwardPort = $row->[5] || 7112;
  
        # Update the (cloned) job data with the quote (for quote forward)
        my $dataClone = $data->cloneNode(1);
        my @jobClones = $dataClone->getChildrenByTagName("Job");
        my $chargeElement = new XML::LibXML::Element("Charge");
        $chargeElement->appendText($debitAmount);
        $jobClones[0]->appendChild($chargeElement);

        # Build Forward Quote Request
        my $forwardRequest = new Gold::Request(object => "Job", action => "Quote");
        $forwardRequest->setDataElement($dataClone);
        $forwardRequest->setOption("CallType", "Forward");
        $forwardRequest->setOption("Guarantee", "True") if $guarantee;
        $forwardRequest->setOption("ForwardProject", $forwardProject) if defined $forwardProject;
        $forwardRequest->setOption("ForwardUser", $forwardUser) if defined $forwardUser;
        $forwardRequest->setOption("ForwardMachine", $forwardMachine) if defined $forwardMachine;
        $forwardRequest->setOption("ItemizedCharges", $itemizedCharges);
    
        # Use long form of message send in order to specify alternate host and port
        my $messageChunk = new Gold::Chunk()->setRequest($forwardRequest);
        my $message = new Gold::Message();
        $message->sendChunk($messageChunk, $forwardHost, $forwardPort);
        my $reply = $message->getReply();
        my $replyChunk = $reply->receiveChunk(); 
        my $forwardResponse = $replyChunk->getResponse();
        $forwardMessage = "\nForward Quote ($organization): " . $forwardResponse->getMessage();
        if ($forwardResponse->getStatus() eq "Failure")
        {
          return new Gold::Response()->failure($forwardResponse->getCode(), "Forward Quote Failed: " . $forwardResponse->getMessage() . ".\nQuotation Aborted.");
        }
      }

      $remaining -= $debitAmount;

      # Break out if we are done
      last if $remaining <= 0;
    }
  
    # Fail if not all amount could be debited
    if ($remaining > 0)
    {
      return new Gold::Response()->failure("784", "Insufficient balance to satisfy quotation");
    }
  }

  my $time_division = defined $request->getOptionValue("ShowHours") ? 3600 : 1;
  my $currency_precision = $config->get_property("currency.precision", 0);
  $quote = sprintf("%.${currency_precision}f", $quote / $time_division);
  my $message = "Successfully quoted $quote credits";
  $message .= " with quote id $quotationId" if $guarantee;
  my $response = new Gold::Response()->success($quote, $message . $quoteMessage . $backMessage . $forwardMessage);

  # Add data to response
  my $datum = new Gold::Datum("Quote");
  $datum->setValue("Id", $quotationId) if $guarantee;
  $datum->setValue("Amount", $quote);
  $datum->setValue("Job", $id) if $guarantee;
  $response->setDatum($datum);

  return $response;
}
  

# ----------------------------------------------------------------------------
# $response = refund($request, $requestId);
# ----------------------------------------------------------------------------

# Refund (Job)
sub refund
{
  my ($class, $request, $requestId) = @_;

  if ($log->is_debug())
  {
    $log->debug("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my $object = $request->getObject();
  my $actor = $request->getActor();
  my $database = $request->getDatabase();
  my @options = $request->getOptions();
  my $refundSum = 0;
  my $now = time;

  if ($object ne "Job")
  {
    return new Gold::Response()->failure("315", "The Bank class does not implement $object Refund");
  }

  my $jobId = $request->getOptionValue("JobId");
  my $id = $request->getOptionValue("Id");

  # First look for the job to be refunded in the Job Table
  # SELECT Id,JobId,Project,User,Machine,Charge FROM Job WHERE (JobId=<JobId>|Id=<Instance Id>)

  my @subSelections =
  (
    new Gold::Selection(name => "Id"),
    new Gold::Selection(name => "JobId"),
    new Gold::Selection(name => "User"),
    new Gold::Selection(name => "Project"),
    new Gold::Selection(name => "Machine"),
    new Gold::Selection(name => "Charge"),
  );
  
  my @subConditions = ();
  push @subConditions, new Gold::Condition(name => "Stage", value => "Charge");
  push @subConditions, new Gold::Condition(name => "JobId", value => $jobId) if defined $jobId;
  push @subConditions, new Gold::Condition(name => "Id", value => $id) if defined $id;
  
  my @subOptions = ( new Gold::Option(name => "Limit", value =>"20") );
  my $results = $database->select(object => "Job", selections => \@subSelections, conditions => \@subConditions, options => \@subOptions);

  # No jobs were matched
  if (@{$results->{data}} == 0)
  {
    return new Gold::Response()->failure("740", "There are no jobs matching the specified job id");
  }

  # Multiple jobs were matched
  elsif (@{$results->{data}} > 1)
  {
    my $jobs = "";
    foreach my $row (@{$results->{data}})
    {
      my $id = $row->[0];
      my $jobId = $row->[1];
      my $user = $row->[2];
      my $project = $row->[3];
      my $machine = $row->[4];
      my $charge = $row->[5];

      $jobs .= "\t$id\t[$jobId,$user,$project,$machine,$charge]\n";
    }
    return new Gold::Response()->failure("740", "There are multiple jobs matching the specified job id.\nPlease respecify using one of the following gold job ids:\n" . $jobs);
  }
  
  # A unique job was matched
  else
  {
    my $id = ${$results->{data}}[0]->[0];
    $jobId = ${$results->{data}}[0]->[1];
    my $user = ${$results->{data}}[0]->[2];
    my $project = ${$results->{data}}[0]->[3];
    my $machine = ${$results->{data}}[0]->[4];
    my $charge = ${$results->{data}}[0]->[5];
    
    my $amount = $request->getOptionValue("Amount");
    my $account = $request->getOptionValue("Account");

    # Amount must be positive and not greater than charge
    if (defined $amount)
    {
      if ($amount <= 0)
      {
        return new Gold::Response()->failure("740", "Amount must be positive");
      }
      if ($amount > $charge)
      {
        return new Gold::Response()->failure("740", "Refund amount ($amount) cannot exceed job charge ($charge)");
      }
    }
    else
    {
      $amount = $charge ? $charge : 0;
    }
    
    # Fail if there are no charges to refund
    if ($amount == 0)
    {
      return new Gold::Response()->failure("740", "There are no charges to refund");
    }
    
    # If the account is provided we can just issue the refund
    if (defined $account)
    {
      # Figure out the earliest expiring allocation in the account
      # SELECT Id,EndTime,StartTime FROM Allocation WHERE Account=$account AND StartTime<=$now AND EndTime>$now AND CallType=Normal ORDER BY EndTime,StartTime
  
      my @selections =
      (
        new Gold::Selection(name => "Id"),
        new Gold::Selection(name => "EndTime", op => "Sort"),
        new Gold::Selection(name => "StartTime", op => "Sort"),
      );
    
      my @conditions =
      (
        new Gold::Condition(name => "Account", value => $account),
        new Gold::Condition(name => "StartTime", value => $now, op => "LE"),
        new Gold::Condition(name => "EndTime", value => $now, op => "GT"),
        new Gold::Condition(name => "CallType", value => "Normal"),
      );
  
      my $results = $database->select(object => "Allocation", selections => \@selections, conditions => \@conditions);

      # An active allocation exists
      if (@{$results->{data}})
      {
        my $allocationId = ${$results->{data}}[0]->[0];

        # Credit the allocation
        my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Modify", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Amount", value => $amount, op => "Inc") ], conditions => [ new Gold::Condition(name => "Account", value => $account), new Gold::Condition(name => "Id", value => $allocationId) ]);
        my $subResponse = Gold::Base->modify($subRequest, $requestId);
        if ($subResponse->getStatus() eq "Failure")
        {
          return new Gold::Response()->failure($subResponse->getCode(), "Unable to credit allocation: " . $subResponse->getMessage());
        }
      }
  
      # An active allocation does not exist
      else
      {
        # Create a new one
        my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Account", value => $account), new Gold::Assignment(name => "Amount", value => $amount) ]);
        my $subResponse = Gold::Base->create($subRequest, $requestId);
        if ($subResponse->getStatus() eq "Failure")
        {
          return new Gold::Response()->failure($subResponse->getCode(), "Unable to create allocation: " . $subResponse->getMessage());
        }
      }

      # Log the transaction
      my @logOptions = @options;
      push @logOptions, new Gold::Option(name => "Amount", value => $amount);
      Gold::Bank->logTransaction(database => $database, requestId => $requestId, txnId => $database->nextId("Transaction"), object => "Job", action => "Refund", actor => $actor, options => \@logOptions, count => 1, account => $account, delta => $amount);
      $refundSum += $amount;
    }

    # Otherwise we have to look up the charges from the transaction log
    else
    {
      my $remaining = $amount;

      # SELECT Account,Delta FROM Transaction WHERE Object=Job AND Action=Charge AND Name=$id
      $results = $database->select(object => "Transaction", selections => [ new Gold::Selection(name => "Account"), new Gold::Selection(name => "Delta") ], conditions => [ new Gold::Condition(name => "Object", value => "Job"), new Gold::Condition(name => "Action", value => "Charge"), new Gold::Condition(name => "Name", value => $id) ]);
      foreach my $row (@{$results->{data}})
      {
        my $account = $row->[0];
        my $delta = $row->[1];

        my $subRefund = min(0 - $delta, $remaining);
        next unless $subRefund;

        # Figure out the earliest expiring allocation in the account
        # SELECT Id,EndTime,StartTime FROM Allocation WHERE Account=$account AND StartTime<=$now AND EndTime>$now AND CallType=Normal ORDER BY EndTime,StartTime
  
        my @selections =
        (
          new Gold::Selection(name => "Id"),
          new Gold::Selection(name => "EndTime", op => "Sort"),
          new Gold::Selection(name => "StartTime", op => "Sort"),
        );
    
        my @conditions =
        (
          new Gold::Condition(name => "Account", value => $account),
          new Gold::Condition(name => "StartTime", value => $now, op => "LE"),
          new Gold::Condition(name => "EndTime", value => $now, op => "GT"),
          new Gold::Condition(name => "CallType", value => "Normal"),
        );
  
        my $results = $database->select(object => "Allocation", selections => \@selections, conditions => \@conditions);

        # An active allocation exists
        my $allocationId = 0;
        if (@{$results->{data}})
        {
          $allocationId = ${$results->{data}}[0]->[0];
  
          # Credit the allocation
          my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Modify", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Amount", value => $subRefund, op => "Inc") ], conditions => [ new Gold::Condition(name => "Account", value => $account), new Gold::Condition(name => "Id", value => $allocationId) ]);
          my $subResponse = Gold::Base->modify($subRequest, $requestId);
          if ($subResponse->getStatus() eq "Failure")
          {
            return new Gold::Response()->failure($subResponse->getCode(), "Unable to credit allocation: " . $subResponse->getMessage());
          }
        }
    
        # An active allocation does not exist
        else
        {
          # Create a new one
          my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Account", value => $account), new Gold::Assignment(name => "Amount", value => $subRefund) ]);
          my $subResponse = Gold::Base->create($subRequest, $requestId);
          if ($subResponse->getStatus() eq "Failure")
          {
            return new Gold::Response()->failure($subResponse->getCode(), "Unable to create allocation: " . $subResponse->getMessage());
          }

          # Figure out the id of the allocation we just created
          $allocationId = $subResponse->getDatumValue("Id");
        }

        # Log the transaction
        my @logOptions = @options;
        push @logOptions, new Gold::Option(name => "Amount", value => $subRefund);
        Gold::Bank->logTransaction(database => $database, requestId => $requestId, txnId => $database->nextId("Transaction"), object => "Job", action => "Refund", actor => $actor, options => \@logOptions, count => 1, account => $account, delta => $subRefund, allocation => $allocationId);
        $refundSum += $subRefund;
        $remaining -= $subRefund;
        last unless $remaining > 0;        
      }

      # Bail if transaction log charge data was insufficient to determine
      # the entirety of the accounts and amounts to refund
      if ($remaining > 0)
      {
        return new Gold::Response()->failure("740", "The job charge data could not be found in the transaction logs.\nPlease respecify with the account to refund into.");
      }
    }

    # Update the job record amount
    my $subRequest = new Gold::Request(database => $database, object => "Job", action => "Modify", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Charge", value => $amount, op => "Dec") ], conditions => [ new Gold::Condition(name => "Id", value => $id) ]);
    my $subResponse = Gold::Base->modify($subRequest, $requestId);
    if ($subResponse->getStatus() eq "Failure")
    {
      return new Gold::Response()->failure($subResponse->getCode(), "Unable to modify job record: " . $subResponse->getMessage());
    }
  }

  my $time_division = defined $request->getOptionValue("ShowHours") ? 3600 : 1;
  my $currency_precision = $config->get_property("currency.precision", 0);
  $refundSum = sprintf("%.${currency_precision}f", $refundSum / $time_division);
  my $response = new Gold::Response()->success($refundSum, "Successfully refunded $refundSum credits for job $jobId");

  # Add data to response
  my $datum = new Gold::Datum("Refund");
  $datum->setValue("JobId", $jobId) if defined $jobId;
  $datum->setValue("Refund", $refundSum);
  $response->setDatum($datum);

  return $response;
}
  

# ----------------------------------------------------------------------------
# $response = refresh($request, $requestId);
# ----------------------------------------------------------------------------

# Refresh (Allocation)
sub refresh
{
  my ($class, $request, $requestId) = @_;

  if ($log->is_debug())
  {
    $log->debug("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my $object = $request->getObject();
  my $actor = $request->getActor();
  my $database = $request->getDatabase();
  my @options = $request->getOptions();
  my $activationSum = 0;
  my $deactivationSum = 0;
  my $results;
  my $now = time;

  if ($object ne "Allocation")
  {
    return new Gold::Response()->failure("315", "The Bank class does not implement $object Refresh");
  }

  # Activate allocations that are newly activated or no longer expired

  # Get a list of allocations to be activated
  # SELECT Id,Account,Amount FROM Allocation WHERE ( StartTime<=$now AND EndTime>=$now ) AND Active='False'
  $results = $database->select(object => "Allocation", selections => [ new Gold::Selection(name => "Id"), new Gold::Selection(name => "Account"), new Gold::Selection(name => "Amount") ], conditions => [ new Gold::Condition(name => "StartTime", value => $now, op => "LE", conj => "And", group => "+1"), new Gold::Condition(name => "EndTime", value => $now, op => "GE", conj => "And", group => "-1"), new Gold::Condition(name => "Active", value => "False") ]);
  foreach my $row (@{$results->{data}})
  {
    my $id = $row->[0];
    my $account = $row->[1];
    my $amount = $row->[2];

    # Construct an individual modify based on account id in list
    my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Modify", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Active", value => "True") ], conditions => [ new Gold::Condition(name => "Account", value => $account), new Gold::Condition(name => "Id", value => $id) ]);
    my $subResponse = Gold::Base->modify($subRequest, $requestId);
    if ($subResponse->getStatus() eq "Failure")
    {
      return new Gold::Response()->failure($subResponse->getCode(), "Unable to activate allocation ($id): " . $subResponse->getMessage());
    }

    $activationSum += $amount;
  
    # Log the transaction
    my @activateOptions = @options;
    push @activateOptions, new Gold::Option(name => "Id", value => $id);
    Gold::Bank->logTransaction(database => $database, requestId => $requestId, txnId => $database->nextId("Transaction"), object => "Allocation", action => "Activate", actor => $actor, options => \@activateOptions, count => 1, account => $account, delta => $amount, allocation => $id);
  }
  
  # Deactivate allocations that are newly expired or no longer active

  # Get a list of allocations to be deactivated
  # SELECT Id,Account,Amount FROM Allocation WHERE ( StartTime>=$now OR EndTime<=$now ) AND Active='True'
  $results = $database->select(object => "Allocation", selections => [ new Gold::Selection(name => "Id"), new Gold::Selection(name => "Account"), new Gold::Selection(name => "Amount") ], conditions => [ new Gold::Condition(name => "StartTime", value => $now, op => "GE", conj => "And", group => "+1"), new Gold::Condition(name => "EndTime", value => $now, op => "LE", conj => "Or", group => "-1"), new Gold::Condition(name => "Active", value => "True") ]);
  foreach my $row (@{$results->{data}})
  {
    my $id = $row->[0];
    my $account = $row->[1];
    my $amount = $row->[2];

    # Construct an individual modify based on account id in list
    my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Modify", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Active", value => "False") ], conditions => [ new Gold::Condition(name => "Account", value => $account), new Gold::Condition(name => "Id", value => $id) ]);
    my $subResponse = Gold::Base->modify($subRequest, $requestId);
    if ($subResponse->getStatus() eq "Failure")
    {
      return new Gold::Response()->failure($subResponse->getCode(), "Unable to deactivate allocation ($id): " . $subResponse->getMessage());
    }

    $deactivationSum += $amount;
  
    # Log the transaction
    my @deactivateOptions = @options;
    push @deactivateOptions, new Gold::Option(name => "Id", value => $id);
    Gold::Bank->logTransaction(database => $database, requestId => $requestId, txnId => $database->nextId("Transaction"), object => "Allocation", action => "Deactivate", actor => $actor, options => \@deactivateOptions, count => 1, account => $account, delta => 0 - $amount, allocation => $id);
  }
  
  my $time_division = defined $request->getOptionValue("ShowHours") ? 3600 : 1;
  my $currency_precision = $config->get_property("currency.precision", 0);
  $activationSum = sprintf("%.${currency_precision}f", $activationSum / $time_division);
  $deactivationSum = sprintf("%.${currency_precision}f", $deactivationSum / $time_division);
  return new Gold::Response()->success("Successfully activated $activationSum credits and deactivated $deactivationSum credits");
}


# ----------------------------------------------------------------------------
# $response = reserve($request, $requestId);
# ----------------------------------------------------------------------------

# Reserve (Job)
sub reserve
{
  my ($class, $request, $requestId) = @_;

  if ($log->is_debug())
  {
    $log->debug("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my $object = $request->getObject();
  my $actor = $request->getActor();
  my $database = $request->getDatabase();
  my $replace = $request->getOptionValue("Replace");
  my $quoteMessage = "";
  my $reserveMessage = "";
  my $backMessage = "";
  my $forwardMessage = "";
  my $now = time;
  my $startTime = $now;
  my $endTime = 2147483647; # Infinity
  my $callType = $request->getOptionValue("CallType") || "Normal";
  if ($callType ne "Normal" && $callType ne "Back" && $callType ne "Forward")
  {
    $callType = "Normal";
  }
  my $backProject = $request->getOptionValue("BackProject");
  my $backUser = $request->getOptionValue("BackUser");
  my $backMachine = $request->getOptionValue("BackMachine");
  my $forwardProject = $request->getOptionValue("ForwardProject");
  my $forwardUser = $request->getOptionValue("ForwardUser");
  my $forwardMachine = $request->getOptionValue("ForwardMachine");

  if ($object ne "Job")
  {
    return new Gold::Response()->failure("315", "The Bank class does not implement $object Reserve");
  }

  # Data must be present
  my $doc = XML::LibXML::Document->new();
  my $data = $request->getDataElement();
  $doc->setDocumentElement($data);
  unless (defined $data)
  {
    return new Gold::Response()->failure("314", "Job data is required");
  }

  # Return failure if we detect a job object property we do not support
  foreach my $property (qw(JobGroup JobDefaults TaskGroup TaskGroupDefaults Requested Delivered Resource Extension))
  {
    if ($data->findnodes("//$property"))
    {
      return new Gold::Response()->failure("710", "The $property element is not supported");
    }
  }

  # We currently only support a solitary job
  my @jobs = $data->findnodes("/Data/Job");
  if (@jobs == 0)
  {
    return new Gold::Response()->failure("314", "At least one job must be specified");
  }
  elsif (@jobs > 1)
  {
    return new Gold::Response()->failure("314", "Only one job may be specified");
  }

  my $job = $jobs[0];

  # Build up a list of job attributes
  my %attributes = ();
  my $results = $database->select(object => "Attribute", selections => [ new Gold::Selection(name => "Name") ], conditions => [ new Gold::Condition(name => "Object", value => "Job"), new Gold::Condition(name => "Hidden", value => "False") ]);
  foreach my $row (@{$results->{data}})
  {
      my $name = $row->[0];
      $attributes{$name} = 1;
  }
  
  # There are some properties that we explicitly look for
  my @assignments = ();

  # JobId
  my $jobId = $job->findvalue("//JobId");
  if ($jobId ne "")
  {
    if (exists $attributes{JobId})
    {
      delete $attributes{JobId};
      push @assignments, new Gold::Assignment(name => "JobId", value => $jobId);
    }
  }
  else
  {
    return new Gold::Response()->failure("314", "A job id must be specified for the reservation");
  }

  # User
  my $user = $job->findvalue("//UserId");
  if ($callType eq "Back" && defined $backUser) { $user = $backUser; }
  if ($callType eq "Forward" && defined $forwardUser) { $user = $forwardUser; }
  if ($user eq "")
  {
    # Look for a system default project
    $user = $config->get_property("user.default", $USER_DEFAULT);
    if ($user eq "NONE" || $user eq "")
    {
      return new Gold::Response()->failure("314", "A user must be specified for the reservation");
    }
  }

  # Verify user
  # SELECT Active,Special FROM User WHERE Name=$user
  my $subResults = $database->select(object => "User", selections => [ new Gold::Selection(name => "Active"), new Gold::Selection(name => "Special") ], conditions => [ new Gold::Condition(name => "Name", value => $user) ]);
  if (@{$subResults->{data}})
  {
    my $active = ${$subResults->{data}}[0]->[0];
    my $special = ${$subResults->{data}}[0]->[1];
    if (defined $active && $active ne "True")
    {
      return new Gold::Response()->failure("740", "User $user is not active");
    }
    if (defined $special && $special eq "True")
    {
      return new Gold::Response()->failure("740", "User $user is special");
    }
  }
  else
  {
    if ($config->get_property("user.autogen", $USER_AUTOGEN) =~ /true/i)
    {
      # Create the user
      my $subRequest = new Gold::Request(database => $database, object => "User", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Name", value => $user), new Gold::Assignment(name => "Description", value => "Auto-Generated") ]);
      my $subResponse = Gold::Base->create($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to create user: " . $subResponse->getMessage());
      }
    }
    else
    {
      return new Gold::Response()->failure("740", "User $user does not exist");
    }
  }
    
  if (exists $attributes{User})
  {
    push @assignments, new Gold::Assignment(name => "User", value => $user);
    delete $attributes{User};
  }

  # Project
  my $project = $job->findvalue("//ProjectId");
  if ($callType eq "Back" && defined $backProject) { $project = $backProject; }
  if ($callType eq "Forward" && defined $forwardProject) { $project = $forwardProject; }
  if ($project eq "")
  {
    # Look for a user default project
    # SELECT DefaultProject FROM User WHERE Name=$user
    my $subResults = $database->select(object => "User", selections => [ new Gold::Selection(name => "DefaultProject") ], conditions => [ new Gold::Condition(name => "Name", value => $user) ]);
    if (@{$subResults->{data}})
    {
      my $defaultProject = ${$subResults->{data}}[0]->[0];
      if (defined $defaultProject)
      {
        $project = $defaultProject;
      }
    }
    # Look for a system default project
    else
    {
      $project = $config->get_property("project.default", $PROJECT_DEFAULT);
      if ($project eq "NONE" || $project eq "")
      {
        return new Gold::Response()->failure("314", "A project must be specified for the reservation\nor a default project must exist for the user");
      }
    }
  }

  # Verify project
  # SELECT Active,Special FROM Project WHERE Name=$project
  $subResults = $database->select(object => "Project", selections => [ new Gold::Selection(name => "Active"), new Gold::Selection(name => "Special") ], conditions => [ new Gold::Condition(name => "Name", value => $project) ]);
  if (@{$subResults->{data}})
  {
    my $active = ${$subResults->{data}}[0]->[0];
    my $special = ${$subResults->{data}}[0]->[1];
    if (defined $active && $active ne "True")
    {
      return new Gold::Response()->failure("740", "Project $project is not active");
    }
    if (defined $special && $special eq "True")
    {
      return new Gold::Response()->failure("740", "Project $project is special");
    }
  }
  else
  {
    if ($config->get_property("project.autogen", $PROJECT_AUTOGEN) =~ /true/i)
    {
      # Create the project
      my $subRequest = new Gold::Request(database => $database, object => "Project", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Name", value => $project), new Gold::Assignment(name => "Description", value => "Auto-Generated") ]);
      my $subResponse = Gold::Base->create($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to create project: " . $subResponse->getMessage());
      }
    }
    else
    {
      return new Gold::Response()->failure("740", "Project $project does not exist");
    }
  }

  if (exists $attributes{Project})
  {
    delete $attributes{Project};
    push @assignments, new Gold::Assignment(name => "Project", value => $project);
  }

  # Machine
  my $machine = $job->findvalue("//MachineName");
  if ($callType eq "Back" && defined $backMachine) { $machine = $backMachine; }
  if ($callType eq "Forward" && defined $forwardMachine) { $machine = $forwardMachine; }
  if ($machine eq "")
  {
    # Look for a system default machine
    $machine = $config->get_property("machine.default", $MACHINE_DEFAULT);
    if ($machine eq "NONE" || $machine eq "")
    {
      return new Gold::Response()->failure("314", "A machine must be specified for the reservation");
    }
  }

  # Verify machine
  # SELECT Active,Special FROM Machine WHERE Name=$machine
  $subResults = $database->select(object => "Machine", selections => [ new Gold::Selection(name => "Active"), new Gold::Selection(name => "Special") ], conditions => [ new Gold::Condition(name => "Name", value => $machine) ]);
  if (@{$subResults->{data}})
  {
    my $active = ${$subResults->{data}}[0]->[0];
    my $special = ${$subResults->{data}}[0]->[1];
    if (defined $active && $active ne "True")
    {
      return new Gold::Response()->failure("740", "Machine $machine is not active");
    }
    if (defined $special && $special eq "True")
    {
      return new Gold::Response()->failure("740", "Machine $machine is special");
    }
  }
  else
  {
    if ($config->get_property("machine.autogen", $MACHINE_AUTOGEN) =~ /true/i)
    {
      # Create the machine
      my $subRequest = new Gold::Request(database => $database, object => "Machine", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Name", value => $machine), new Gold::Assignment(name => "Description", value => "Auto-Generated") ]);
      my $subResponse = Gold::Base->create($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to create machine: " . $subResponse->getMessage());
      }
    }
    else
    {
      return new Gold::Response()->failure("740", "Machine $machine does not exist");
    }
  }

  if (exists $attributes{Machine})
  {
    delete $attributes{Machine};
    push @assignments, new Gold::Assignment(name => "Machine", value => $machine);
  }

  # Wall Duration
  my $wallDuration = $job->findvalue("//WallDuration");
  if ($wallDuration ne "")
  {
    delete $attributes{WallDuration};
    push @assignments, new Gold::Assignment(name => "WallDuration", value => $wallDuration);
  }
  else
  {
    return new Gold::Response()->failure("314", "A wall duration must be specified for the reservation");
  }
  if ($wallDuration !~ /^\d+$/)
  {
    return new Gold::Response()->failure("314", "The wall duration must be an integer number of seconds");
  }

  # Start Time
  my $start = $job->findvalue("//StartTime");
  if ($start ne "")
  {
    delete $attributes{StartTime};
    push @assignments, new Gold::Assignment(name => "StartTime", value => $start);
    $startTime = $start;
  }

  # End Time
  my $end = $job->findvalue("//EndTime");
  if ($end ne "")
  {
    delete $attributes{EndTime};
    push @assignments, new Gold::Assignment(name => "EndTime", value => $end);
    $endTime = $end;
  }
  else
  {
    # Add 10 minute grace period to end of reservation
    $endTime = $startTime + $wallDuration + 600;
  }

  # Look for Charge (an external calculation for how much should be reserved)
  my $reserve = $job->findvalue("//Charge");
  my $itemizedCharges;

  # Quote Id
  my $quoteId = $job->findvalue("//QuoteId");
  my $id = "";
  if ($quoteId ne "")
  {
    # Check to see if the quote exists and is not expired or used
    # SELECT Job FROM Quotation WHERE Id=$quoteId AND Uses>0 AND StartTime<$startTime AND EndTime>$startTime
    my $subResults = $database->select(object => "Quotation", selections => [ new Gold::Selection(name => "Job") ], conditions => [ new Gold::Condition(name => "Id", value => $quoteId), new Gold::Condition(name => "Uses", value => "0", op => "GT"), new Gold::Condition(name => "StartTime", value => $startTime, op => "LE"), new Gold::Condition(name => "EndTime", value => $startTime, op => "GT") ]);
    if (@{$subResults->{data}})
    {
      $id = ${$subResults->{data}}[0]->[0];

      if (exists $attributes{QuoteId})
      {
        delete $attributes{'QuoteId'};
        push @assignments, new Gold::Assignment(name => "QuoteId", value => $quoteId);
      }
    }
    else
    {
      # Nullify the quoteId if absent, expired or used
      $quoteMessage .= "\nWarning: Quote ($quoteId) is invalid and cannot be used";
      $quoteId = "";
    }
  }

  # Remove simarly named reservations if Replace option is specified
  # DELETE FROM Reservation WHERE Name=$jobId
  if (defined $replace && $replace eq "True")
  {
    my $subRequest = new Gold::Request(database => $database, object => "Reservation", action => "Delete", actor => $config->get_property("super.user", $SUPER_USER), conditions => [ new Gold::Condition(name => "Name", value => $jobId) ]);
    my $subResponse = Gold::Base->delete($subRequest, $requestId);
    if ($subResponse->getStatus() eq "Failure")
    {
      return new Gold::Response()->failure($subResponse->getCode(), "Unable to delete reservations: " . $subResponse->getMessage());
    }
    my $count = $subResponse->getCount();
    if ($count)
    {
      $reserveMessage .= "\n$count reservations were removed";
    }
  }
  
  # Calculate reserve amount if not already specified
  if ($reserve eq "")
  {
    $reserve = 0;

    # Create a new job if one does not already exist
    # Look up the current charge rates
    # SELECT Type,Name,Rate FROM ChargeRate
    my %chargeRate = ();
    $results = $database->select(object => "ChargeRate", selections => [ new Gold::Selection(name => "Type"), new Gold::Selection(name => "Name"), new Gold::Selection(name => "Rate") ]);
    foreach my $row (@{$results->{data}})
    {
      my $type = $row->[0];
      my $name = $row->[1];
      my $rate = $row->[2];
  
      $chargeRate{$type}{$name} = $rate;
    }

	  # Override with quoted charge rates
	  if ($quoteId ne "")
	  {
	    # Look up the quoted charge rates
	    # SELECT Type,Name,Rate FROM QuotationChargeRate WHERE Quotation=$quoteId
	    my $results = $database->select(object => "QuotationChargeRate", selections => [ new Gold::Selection(name => "Type"), new Gold::Selection(name => "Name"), new Gold::Selection(name => "Rate") ], conditions => [ new Gold::Condition(name => "Quotation", value => $quoteId) ]);
	    foreach my $row (@{$results->{data}})
	    {
	      my $type = $row->[0];
	      my $name = $row->[1];
	      my $rate = $row->[2];
	
	      $chargeRate{$type}{$name} = $rate;
	    }
	  }
	    
	  # Iterate over the charge multipliers
	  my $multiplier = 1;
	  my @multiplierCharges = ( "$wallDuration [WallDuration]" );
	  foreach my $type (keys %chargeRate)
	  {
	    next if $type eq "Resource";
	
	    # Look for this charge type in the job properties
	    my $name = $job->findvalue("//$type");
	    if ($name ne "")
	    {
	      if (exists $chargeRate{$type}{$name})
	      {
	        $multiplier *= $chargeRate{$type}{$name};
	        push @multiplierCharges, "$chargeRate{$type}{$name} [ChargeRate{$type}{$name}]";
	      }
	      else
	      {
	        $reserveMessage .= "\nWarning: ChargeRate for $type $name is not defined";
	      }
	
	      if (exists $attributes{$type})
	      {
	        delete $attributes{$type};
	        push @assignments, new Gold::Assignment(name => "$type", value => $name);
	      }
	    }
	  }
	
	  # Iterate over the consumable resources
	  my @resourceCharges = ();
	  foreach my $name (keys %{$chargeRate{Resource}})
	  {
	    # Look for this resource in the job properties
	    my $amount = $job->findvalue("//$name");
	    if ($amount ne "")
	    {
	      # Calculate reserve amount if not already specified
	      my $rate = $chargeRate{Resource}{$name};
	      my $subReserve = $amount * $rate * $wallDuration * $multiplier;
	      $reserve = $reserve + $subReserve;
	      push @resourceCharges, "( $amount [$name] * $rate [ChargeRate{Resource}{$name}] )";
	  
	      if (exists $attributes{$name})
	      {
	        delete $attributes{$name};
	        push @assignments, new Gold::Assignment(name => "$name", value => $amount);
	      }
	    }
	  }
	
	  $itemizedCharges = "( " . join(' + ', @resourceCharges), " ) * " . join(' * ', @multiplierCharges) . " = $reserve";
  }

  # If Charge is not included in job properties,
  # look for itemized charges in an option
  else
  {
    $itemizedCharges = $request->getOptionValue("ItemizedCharges");
    if (! defined $itemizedCharges)
    {
      $itemizedCharges = "$reserve [externally calculated] = $reserve";
    }
  }

  # Process the remaining job attributes
  foreach my $name (keys %attributes)
  {
    my $value = $job->findvalue("//$name");
    if ($value ne "")
    {
      delete $attributes{$name};
      push @assignments, new Gold::Assignment(name => "$name", value => $value);
    }
  }

  # Place Reservations against the Account(s)
  if ($reserve > 0)
  {
    my $remaining = $reserve;
    my %accounts = ();
    my %allocations = ();

    # Refresh Allocations
    my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Refresh");
    my $subResponse = Gold::Bank->refresh($subRequest, $requestId);
    if ($subResponse->getStatus() eq "Failure")
    {
      return new Gold::Response()->failure($subResponse->getCode(), "Failed while refreshing allocations: " . $subResponse->getMessage());
    }
    
    # Construct list of viable accounts
    {
      # SELECT Account.Id,AccountProject.Name,AccountUser.Name,AccountMachine.Name FROM Account,AccountUser,AccountProject,AccountMachine,Allocation WHERE Allocation.StartTime<=$startTime AND Allocation.EndTime>$startTime AND Allocation.CallType='$callType' AND AccountProject.Account=Account.Id AND AccountUser.Account=Account.Id AND AccountMachine.Account=Account.Id AND Allocation.Account=Account.Id
    
      my @objects =
      (
        new Gold::Object(name => "Account"),
        new Gold::Object(name => "AccountUser"),
        new Gold::Object(name => "AccountProject"),
        new Gold::Object(name => "AccountMachine"),
        new Gold::Object(name => "Allocation"),
      );
    
      my @selections =
      (
        new Gold::Selection(object => "Account", name => "Id"),
        new Gold::Selection(object => "AccountProject", name => "Name"),
        new Gold::Selection(object => "AccountUser", name => "Name"),
        new Gold::Selection(object => "AccountMachine", name => "Name")
      );
    
      my @conditions =
      (
        new Gold::Condition(object => "Allocation", name => "Account", subject => "Account", value => "Id"),
        new Gold::Condition(object => "AccountProject", name => "Account", subject => "Account", value => "Id"),
        new Gold::Condition(object => "AccountUser", name => "Account", subject => "Account", value => "Id"),
        new Gold::Condition(object => "AccountMachine", name => "Account", subject => "Account", value => "Id"),

        # Allocation conditions
        new Gold::Condition(object => "Allocation", name => "StartTime", value => $startTime, op => "LE"),
        new Gold::Condition(object => "Allocation", name => "EndTime", value => $startTime, op => "GT"),
        new Gold::Condition(object => "Allocation", name => "CallType", value => $callType),
        
        # Project conditions
        new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+3"),
        new Gold::Condition(object => "AccountProject", name => "Access", value => "True", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountProject", name => "Name", value => $project, conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountProject", name => "Access", value => "True", conj => "And", group => "-2"),

        # User conditions
        new Gold::Condition(object => "AccountUser", name => "Name", value => "ANY", conj => "And", group => "+2"),
        new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountUser", name => "Name", value => $user, conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountUser", name => "Name", value => "MEMBERS", conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountUser", name => "Access", value => "True", conj => "And", group => "-2"),

        # Machine conditions
        new Gold::Condition(object => "AccountMachine", name => "Name", value => "ANY", conj => "And", group => "+2"),
        new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountMachine", name => "Name", value => $machine, conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountMachine", name => "Name", value => "MEMBERS", conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountMachine", name => "Access", value => "True", conj => "And", group => "-3"),
      );
    
      my $results = $database->select(objects => \@objects, selections => \@selections, conditions => \@conditions);
      foreach my $row (@{$results->{data}})
      {
        my $accountId = $row->[0];
        my $accountProject = $row->[1];
        my $accountUser = $row->[2];
        my $accountMachine = $row->[3];
        
        # Check membership
        if ($accountUser eq "MEMBERS" || $accountMachine eq "MEMBERS")
        {
          my @selections = ();
          my @conditions = ();
          my @objects = ();
          
          if ($accountUser eq "MEMBERS")
          {
            push @selections, new Gold::Selection(object => "ProjectUser", name => "Project");
            push @objects, new Gold::Object(name => "ProjectUser");
            if (defined $user)
            {
              push @conditions, new Gold::Condition(object => "ProjectUser", name => "Name", value => $user);
            }
            push @conditions, new Gold::Condition(object => "ProjectUser", name => "Active", value => "True");
            if ($accountProject ne "ANY")
            {
              push @conditions, new Gold::Condition(object => "ProjectUser", name => "Project", value => $accountProject);
            }
          }
    
          if ($accountMachine eq "MEMBERS")
          {
            push @selections, new Gold::Selection(object => "ProjectMachine", name => "Project");
            push @objects, new Gold::Object(name => "ProjectMachine");
            if (defined $machine)
            {
              push @conditions, new Gold::Condition(object => "ProjectMachine", name => "Name", value => $machine);
            }
            push @conditions, new Gold::Condition(object => "ProjectMachine", name => "Active", value => "True");
            if ($accountProject ne "ANY")
            {
              push @conditions, new Gold::Condition(object => "ProjectMachine", name => "Project", value => $accountProject);
            }
          }
    
          if ($accountUser eq "MEMBERS" && $accountMachine eq "MEMBERS")
          {
            push @conditions, new Gold::Condition(object => "ProjectUser", name => "Project", subject => "ProjectMachine", value => "Project");
          }
    
          # If there is a matching member found, add the account
          my $subResults = $database->select(objects => \@objects, selections => \@selections, conditions => \@conditions);
          if (@{$subResults->{data}})
          {
            # We need to rank accounts by how specific they are
            my $weight = 100 * generality($accountProject) + 10 * generality($accountUser) + generality($accountMachine);
            if (! exists $accounts{$accountId} || $weight < $accounts{$accountId})
            {
              $accounts{$accountId} = $weight;
            }
          }
        }
        
        # Otherwise just add the account
        else 
        {
          # We need to rank accounts by how specific they are
          my $weight = 100 * generality($accountProject) + 10 * generality($accountUser) + generality($accountMachine);
          if (! exists $accounts{$accountId} || $weight < $accounts{$accountId})
          {
            $accounts{$accountId} = $weight;
          }
        }
      }
    
      if ($log->is_debug())
      {
        $log->debug("Initial accepted reserve account list is: " . join ',', keys %accounts);
      }
    }
  
    # Only screen these accounts if there are some to do so to
    if (scalar keys %accounts)
    {
      # Check to make sure these accounts are not rejected
      # SELECT DISTINCT Account.Id FROM Account,AccountUser,AccountProject,AccountMachine WHERE AccountProject.Account=Account.Id AND AccountUser.Account=Account.Id AND AccountMachine.Account=Account.Id AND <Id IN AccountList>
  
      my @objects =
      (
        new Gold::Object(name => "Account"),
        new Gold::Object(name => "AccountUser"),
        new Gold::Object(name => "AccountProject"),
        new Gold::Object(name => "AccountMachine")
      );
    
      my @selections = ( new Gold::Selection(object => "Account", name => "Id") );
    
      my @conditions =
      (
        new Gold::Condition(object => "AccountProject", name => "Account", subject => "Account", value => "Id"),
        new Gold::Condition(object => "AccountUser", name => "Account", subject => "Account", value => "Id"),
        new Gold::Condition(object => "AccountMachine", name => "Account", subject => "Account", value => "Id"),

        # Project conditions
        new Gold::Condition(object => "AccountProject", name => "Name", value => "ANY", conj => "And", group => "+3"),
        new Gold::Condition(object => "AccountProject", name => "Access", value => "False", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountProject", name => "Name", value => $project, conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountProject", name => "Access", value => "False", conj => "And", group => "-2"),
    
        # User conditions
        new Gold::Condition(object => "AccountUser", name => "Name", value => "ANY", conj => "Or", group => "+2"),
        new Gold::Condition(object => "AccountUser", name => "Access", value => "False", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountUser", name => "Name", value => $user, conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountUser", name => "Access", value => "False", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountUser", name => "Name", value => "MEMBERS", conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountUser", name => "Access", value => "False", conj => "And", group => "-2"),

        # Machine conditions
        new Gold::Condition(object => "AccountMachine", name => "Name", value => "ANY", conj => "Or", group => "+2"),
        new Gold::Condition(object => "AccountMachine", name => "Access", value => "False", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountMachine", name => "Name", value => $machine, conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountMachine", name => "Access", value => "False", conj => "And", group => "-1"),
        new Gold::Condition(object => "AccountMachine", name => "Name", value => "MEMBERS", conj => "Or", group => "+1"),
        new Gold::Condition(object => "AccountMachine", name => "Access", value => "False", conj => "And", group => "-3"),
      );
    
      my @options = ( new Gold::Option(name => "Unique", value => "True") );
  
      # Constrain to list of accepted ids
      my $firstTime = 1;
      my $counter = 0;
      foreach my $id (keys %accounts)
      {
        $counter++;
        my $lastTime = ($counter == scalar keys %accounts) ? 1 : 0;
  
        if ($firstTime && $lastTime)
        {
          push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "And", group => "0");
        }
        elsif ($firstTime)
        {
          $firstTime = 0;
          push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "And", group => "+1");
        }
        elsif ($lastTime)
        {
          push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "Or", group => "-1");
        }
        else
        {
          push @conditions, new Gold::Condition(object => "Account", name => "Id", value => $id, conj => "Or", group => "0");
        }
      }
  
      my $results = $database->select(objects => \@objects, selections => \@selections, conditions => \@conditions, options => \@options);
      foreach my $row (@{$results->{data}})
      {
        my $accountId = $row->[0];
  
        # Remove from accounts
        delete $accounts{$accountId};
      }
  
      if ($log->is_debug())
      {
        $log->debug("Post rejection reserve account list is: " . join ',', keys %accounts);
      }
    }
  
    # Add ancestor accounts
    # Build up account linkages
    my %ancestors = ();
    # SELECT Account,Id FROM AccountAccount WHERE Overflow=True
  
    my @selections =
    (
      new Gold::Selection(name => "Account"),
      new Gold::Selection(name => "Id"),
    );
  
    my @conditions = ( new Gold::Condition(name => "Overflow", value => "True") );
  
    my $results = $database->select(object => "AccountAccount", selections => \@selections, conditions => \@conditions);
    foreach my $row (@{$results->{data}})
    {
      my $parent = $row->[0];
      my $child = $row->[1];
  
      $ancestors{$child}{$parent} = 1;
    }
  
    # Add ancestors a generation at a time until there is no more growth
    my $distance = 100;
    while (1)
    {
      $distance *= 10;
      my $count = scalar keys %accounts;
      foreach my $account (keys %accounts)
      {
        foreach my $parent (keys %{$ancestors{$account}})
        {
          $accounts{$parent} = $distance unless exists $accounts{$parent};
        }
      }
      last if $count == scalar keys %accounts;
    }
  
    if ($log->is_debug())
    {
      $log->debug("Post ancestral account list is: " . join ',', keys %accounts);
    }
  
    # Fail if there are no acounts to reserve against
    if (! scalar keys %accounts)
    {
      return new Gold::Response()->failure("782", "Insufficient funds: There are no valid allocations against which to make the reservation");
    }
  
    # Reserve Back if BackHost option is specified and CallType is Normal
    my $backHost = $request->getOptionValue("BackHost");
    if (defined $backHost && $callType eq "Normal")
    {
      my $backPort = $request->getOptionValue("BackPort") || 7112;
  
      # Update the (cloned) job data with the reserve (for reserve back)
      my $dataClone = $data->cloneNode(1);
      my @jobClones = $dataClone->getChildrenByTagName("Job");
      my $chargeElement = new XML::LibXML::Element("Charge");
      $chargeElement->appendText($reserve);
      $jobClones[0]->appendChild($chargeElement);

      # Build Back Reserve Request
      my $backRequest = new Gold::Request(object => "Job", action => "Reserve");
      $backRequest->setDataElement($dataClone);
      $backRequest->setOption("CallType", "Back");
      $backRequest->setOption("BackProject", $backProject) if defined $backProject;
      $backRequest->setOption("BackUser", $backUser) if defined $backUser;
      $backRequest->setOption("BackMachine", $backMachine) if defined $backMachine;
      $backRequest->setOption("ItemizedCharges", $itemizedCharges);
  
      # Use long form of message send in order to specify alternate host and port
      my $messageChunk = new Gold::Chunk()->setRequest($backRequest);
      my $message = new Gold::Message();
      $message->sendChunk($messageChunk, $backHost, $backPort);
      my $reply = $message->getReply();
      my $replyChunk = $reply->receiveChunk(); 
      my $backResponse = $replyChunk->getResponse();
      $backMessage = "\nBack Reserve: " . $backResponse->getMessage();
      if ($backResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($backResponse->getCode(), "Back Reserve Failed: " . $backResponse->getMessage() . ".\nReservation Aborted.");
      }
    }

    # Job was referenced within the quote
    if ($id ne "")
    {
      # Modify the existing job record
      push @assignments, new Gold::Assignment(name => "Stage", value => "Reserve");
      push @assignments, new Gold::Assignment(name => "CallType", value => $callType);
      my $subRequest = new Gold::Request(database => $database, object => "Job", action => "Modify", actor => $config->get_property("super.user", $SUPER_USER), conditions => [ new Gold::Condition(name => "Id", value => $id) ], options => [ new Gold::Option(name => "JobId", value => $jobId) ], assignments => \@assignments);
      my $subResponse = Gold::Base->modify($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to modify job record: " . $subResponse->getMessage());
      }
    }
  
    # Job was not referenced within the quote
    else
    {
      # Create a new job record
      push @assignments, new Gold::Assignment(name => "Stage", value => "Reserve");
      push @assignments, new Gold::Assignment(name => "Charge", value => 0);
      push @assignments, new Gold::Assignment(name => "CallType", value => $callType);
      my $subRequest = new Gold::Request(database => $database, object => "Job", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), options => [ new Gold::Option(name => "JobId", value => $jobId) ], assignments => \@assignments);
      my $subResponse = Gold::Base->create($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to create job record: " . $subResponse->getMessage());
      }
  
      # Figure out the id of the job we just created
      $id = $subResponse->getDatumValue("Id");
    }

    # Create the reservation
    $subRequest = new Gold::Request(database => $database, object => "Reservation", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Name", value => $jobId), new Gold::Assignment(name => "StartTime", value => $startTime), new Gold::Assignment(name => "EndTime", value => $endTime), new Gold::Assignment(name => "Job", value => $id), new Gold::Assignment(name => "User", value => $user), new Gold::Assignment(name => "Project", value => $project), new Gold::Assignment(name => "Machine", value => $machine),  new Gold::Assignment(name => "CallType", value => $callType) ]);
    $subResponse = Gold::Base->create($subRequest, $requestId);
    if ($subResponse->getStatus() eq "Failure")
    {
      return new Gold::Response()->failure($subResponse->getCode(), "Unable to create reservation: " . $subResponse->getMessage());
    }

    # Figure out the id of the reservation we just created
    my $reservationId = $subResponse->getDatumValue("Id");

    # Lookup active allocations from account list
    # SELECT Id,Account,Amount,CreditLimit,EndTime FROM Allocation WHERE StartTime<=$startTime AND EndTime>$startTime AND CallType=$callType AND (Account=<Id> ...)
  
    @selections =
    (
      new Gold::Selection(name => "Id"),
      new Gold::Selection(name => "Account"),
      new Gold::Selection(name => "Amount"),
      new Gold::Selection(name => "CreditLimit"),
      new Gold::Selection(name => "EndTime"),
    );
  
    @conditions =
    (
      new Gold::Condition(name => "StartTime", value => $startTime, op => "LE"),
      new Gold::Condition(name => "EndTime", value => $startTime, op => "GT"),
      new Gold::Condition(name => "CallType", value => $callType),
    );
  
    # Constrain to list of accepted ids
    my $firstTime = 1;
    my $counter = 0;
    foreach my $id (keys %accounts)
    {
      $counter++;
      my $lastTime = ($counter == scalar keys %accounts) ? 1 : 0;
  
      if ($firstTime && $lastTime)
      {
        push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "And", group => "0");
      }
      elsif ($firstTime)
      {
        $firstTime = 0;
        push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "And", group => "+1");
      }
      elsif ($lastTime)
      {
        push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "Or", group => "-1");
      }
      else
      {
        push @conditions, new Gold::Condition(name => "Account", value => $id, conj => "Or", group => "0");
      }
    }
  
    $results = $database->select(object => "Allocation", selections => \@selections, conditions => \@conditions);
    foreach my $row (@{$results->{data}})
    {
      my $allocationId = $row->[0];
      my $accountId = $row->[1];
      my $allocationAmount = $row->[2];
      my $allocationCreditLimit = $row->[3];
      my $allocationEndTime = $row->[4];
      
      $allocations{$allocationId}{account} = $accountId;
      $allocations{$allocationId}{endTime} = $allocationEndTime;
      $allocations{$allocationId}{weight} = $distance * $allocationEndTime + $accounts{$accountId};
      $allocations{$allocationId}{balance} = $allocationAmount + $allocationCreditLimit;
    }
  
    # Subtract reservations from allocation balances
    # Lookup reservation amounts against these accounts
    # SELECT ReservationAllocation.Id,ReservationAllocation.Amount FROM Reservation,ReservationAllocation WHERE Reservation.Id=ReservationAllocation.Reservation AND Reservation.StartTime<=$startTime AND Reservation.EndTime<=$startTime AND (Account=<Id> ...)
 
    my @objects =
    (
      new Gold::Object(name => "Reservation"),
      new Gold::Object(name => "ReservationAllocation"),
    );

    @selections =
    (
      new Gold::Selection(object => "ReservationAllocation", name => "Id"),
      new Gold::Selection(object => "ReservationAllocation", name => "Amount"),
    );
  
    @conditions =
    (
      new Gold::Condition(object => "Reservation", name => "Id", subject => "ReservationAllocation", value => "Reservation"),
      new Gold::Condition(object => "Reservation", name => "StartTime", value => $startTime, op => "LE"),
      new Gold::Condition(object => "Reservation", name => "EndTime", value => $startTime, op => "GT"),
    );
  
    # Constrain to list of accepted ids
    $firstTime = 1;
    $counter = 0;
    foreach my $id (keys %accounts)
    {
      $counter++;
      my $lastTime = ($counter == scalar keys %accounts) ? 1 : 0;
  
      if ($firstTime && $lastTime)
      {
        push @conditions, new Gold::Condition(object => "ReservationAllocation", name => "Account", value => $id, conj => "And", group => "0");
      }
      elsif ($firstTime)
      {
        $firstTime = 0;
        push @conditions, new Gold::Condition(object => "ReservationAllocation", name => "Account", value => $id, conj => "And", group => "+1");
      }
      elsif ($lastTime)
      {
        push @conditions, new Gold::Condition(object => "ReservationAllocation", name => "Account", value => $id, conj => "Or", group => "-1");
      }
      else
      {
        push @conditions, new Gold::Condition(object => "ReservationAllocation", name => "Account", value => $id, conj => "Or", group => "0");
      }
    }
  
    $results = $database->select(objects => \@objects, selections => \@selections, conditions => \@conditions);
    foreach my $row (@{$results->{data}})
    {
      my $allocationId = $row->[0];
      my $reservationAmount = $row->[1];
      
      if (exists $allocations{$allocationId})
      {
        $allocations{$allocationId}{balance} -= $reservationAmount;
      }
    }
  
    # Sort the allocations by weight
    my @allocations = sort { $allocations{$a}{weight} <=> $allocations{$b}{weight} } keys %allocations;
  
    # Iterate through the allocation list
    foreach my $allocationId (@allocations)
    {
      # The amount I subtract from this allocation should be the minimum of:
      # 1. $remaining (the amount left to withdraw)
      # 2. $allocations{$allocationId}{balance} (the amount available within this allocation (considering reservations and credit))
      my $accountId = $allocations{$allocationId}{account};
      my $debitAmount = min($remaining, $allocations{$allocationId}{balance});
      next unless $debitAmount > 0;
  
      # Forward the reservation to the forwarding account if necessary
      my $results = $database->select(objects => [ new Gold::Object(name => "AccountOrganization"), new Gold::Object(name => "Organization") ], selections => [ new Gold::Selection(object => "AccountOrganization", name => "Name"), new Gold::Selection(object => "AccountOrganization", name => "User"), new Gold::Selection(object => "AccountOrganization", name => "Project"), new Gold::Selection(object => "AccountOrganization", name => "Machine"), new Gold::Selection(object => "Organization", name => "Host"), new Gold::Selection(object => "Organization", name => "Port") ], conditions => [ new Gold::Condition(name => "Account", value => $accountId), new Gold::Condition(object => "AccountOrganization", name => "Name", subject => "Organization", value => "Name") ]);
      foreach my $row (@{$results->{data}})
      {
        my $organization = $row->[0];
        my $forwardUser = $row->[1];
        my $forwardProject = $row->[2];
        my $forwardMachine = $row->[3];
        my $forwardHost = $row->[4];
        my $forwardPort = $row->[5] || 7112;
  
        # Update the (cloned) job data with the reserve (for reserve forward)
        my $dataClone = $data->cloneNode(1);
        my @jobClones = $dataClone->getChildrenByTagName("Job");
        my $chargeElement = new XML::LibXML::Element("Charge");
        $chargeElement->appendText($debitAmount);
        $jobClones[0]->appendChild($chargeElement);

        # Build Forward Reserve Request
        my $forwardRequest = new Gold::Request(object => "Job", action => "Reserve");
        $forwardRequest->setDataElement($dataClone);
        $forwardRequest->setOption("CallType", "Forward");
        $forwardRequest->setOption("ForwardProject", $forwardProject) if defined $forwardProject;
        $forwardRequest->setOption("ForwardUser", $forwardUser) if defined $forwardUser;
        $forwardRequest->setOption("ForwardMachine", $forwardMachine) if defined $forwardMachine;
        $forwardRequest->setOption("ItemizedCharges", $itemizedCharges);
    
        # Use long form of message send in order to specify alternate host and port
        my $messageChunk = new Gold::Chunk()->setRequest($forwardRequest);
        my $message = new Gold::Message();
        $message->sendChunk($messageChunk, $forwardHost, $forwardPort);
        my $reply = $message->getReply();
        my $replyChunk = $reply->receiveChunk(); 
        my $forwardResponse = $replyChunk->getResponse();
        $forwardMessage = "\nForward Reserve ($organization): " . $forwardResponse->getMessage();
        if ($forwardResponse->getStatus() eq "Failure")
        {
          return new Gold::Response()->failure($forwardResponse->getCode(), "Forward Reserve Failed: " . $forwardResponse->getMessage() . ".\nReservation Aborted.");
        }
      }

      # Create the reservationAllocation
      my $subRequest = new Gold::Request(database => $database, object => "ReservationAllocation", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Reservation", value => $reservationId), new Gold::Assignment(name => "Id", value => $allocationId), new Gold::Assignment(name => "Account", value => $accountId), new Gold::Assignment(name => "Amount", value => $debitAmount) ]);
      my $subResponse = Gold::Base->create($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to create reservationAllocation: " . $subResponse->getMessage());
      }

      $remaining -= $debitAmount;
      # Break out if we are done
      last if $remaining <= 0;
    }
  
    # Fail if not all amount could be debited
    if ($remaining > 0)
    {
      return new Gold::Response()->failure("784", "Insufficient balance to reserve job");
    }
  }

  # Log the transaction
  Gold::Bank->logTransaction(database => $database, requestId => $requestId, txnId => $database->nextId("Transaction"), object => "Job", action => "Reserve", actor => $actor, conditions => [ new Gold::Condition(name => "Amount", value => $reserve) ], assignments => \@assignments, options => [ new Gold::Option(name => "ItemizedCharges", value => $itemizedCharges) ], count => 1);

  my $time_division = defined $request->getOptionValue("ShowHours") ? 3600 : 1;
  my $currency_precision = $config->get_property("currency.precision", 0);
  $reserve = sprintf("%.${currency_precision}f", $reserve / $time_division);
  my $response = new Gold::Response()->success($reserve, "Successfully reserved $reserve credits for job $jobId" . $quoteMessage . $reserveMessage . $backMessage . $forwardMessage);

  # Add data to response
  my $datum = new Gold::Datum("Reserve");
  $datum->setValue("Amount", $reserve);
  $datum->setValue("Job", $id);
  $response->setDatum($datum);

  return $response;
}
  

# ----------------------------------------------------------------------------
# $response = transfer($request, $requestId);
# ----------------------------------------------------------------------------

# Transfer (Account)
sub transfer
{
  my ($class, $request, $requestId) = @_;

  if ($log->is_debug())
  {
    $log->debug("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my $object = $request->getObject();
  my $actor = $request->getActor();
  my $database = $request->getDatabase();
  my $dbh = $database->{_handle};
  my $amount = $request->getOptionValue("Amount");
  my $remaining = $amount;
  my $fromId = $request->getOptionValue("FromId");
  my $toId = $request->getOptionValue("ToId");
  my $allocation = $request->getOptionValue("Allocation");
  my $type = $request->getOptionValue("CallType") || "Normal";
  my @options = $request->getOptions();
  my %allocations = ();
  my $active = 0;
  my $now = time;

  if ($object ne "Account")
  {
    return new Gold::Response()->failure("315", "The Bank class does not implement $object Transfer");
  }

  # Amount must be positive
  if (! defined $amount)
  {
    return new Gold::Response()->failure("740", "Amount must be specified");
  }
  if ($amount <= 0)
  {
    return new Gold::Response()->failure("740", "Amount must be positive");
  }
  
  # FromId must be specified
  if (! defined $fromId)
  {
    return new Gold::Response()->failure("740", "The source account id (FromId) must be specified");
  }

  # ToId must be specified
  if (! defined $toId)
  {
    return new Gold::Response()->failure("740", "The destination account id (ToId) must be specified");
  }

  # Refresh Allocations
  my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Refresh");
  my $subResponse = Gold::Bank->refresh($subRequest, $requestId);
  if ($subResponse->getStatus() eq "Failure")
  {
    return new Gold::Response()->failure($subResponse->getCode(), "Failed while refreshing allocations: " . $subResponse->getMessage());
  }
  
  # Verify source account exists while obtaining credit limit
  # SELECT Id FROM Account WHERE Id=$fromId
  my $results = $database->select(object => "Account", selections => [ new Gold::Selection(name => "Id") ], conditions => [ new Gold::Condition(name => "Id", value => $fromId) ]);
  unless (@{$results->{data}})
  {
    return new Gold::Response()->failure("740", "Invalid source account id ($fromId)");
  }
  
  # Verify destination account exists
  # SELECT Id FROM Account WHERE Id=$toId
  $results = $database->select(object => "Account", selections => [ new Gold::Selection(name => "Id") ], conditions => [ new Gold::Condition(name => "Id", value => $toId) ]);
  unless (@{$results->{data}})
  {
    return new Gold::Response()->failure("740", "Invalid destination account id ($toId)");
  }
  
  # Look for candidate source allocations
  # SELECT Id,Amount,CreditLimit,StartTime,EndTime FROM Allocation WHERE CallType=$type AND Account=$fromId

  my @selections =
  (
    new Gold::Selection(name => "Id"),
    new Gold::Selection(name => "Amount"),
    new Gold::Selection(name => "CreditLimit"),
    new Gold::Selection(name => "StartTime"),
    new Gold::Selection(name => "EndTime"),
  );

  my @conditions =
  (
    new Gold::Condition(name => "Account", value => $fromId),
    new Gold::Condition(name => "CallType", value => $type),
  );

  if (defined $allocation)
  {
    push @conditions, new Gold::Condition(name => "Id", value => $allocation);
  }
  else
  {
    push @conditions, new Gold::Condition(name => "StartTime", value => $now, op => "LE");
    push @conditions, new Gold::Condition(name => "EndTime", value => $now, op => "GT");
  }

  $results = $database->select(object => "Allocation", selections => \@selections, conditions => \@conditions);

  # Fail if there are no valid allocations to withdraw from
  unless (@{$results->{data}})
  {
    return new Gold::Response()->failure("782", "Insufficient funds: There are no valid allocations from which to perform the transfer");
  }

  foreach my $row (@{$results->{data}})
  {
    my $allocationId = $row->[0];
    my $allocationAmount = $row->[1];
    my $allocationCreditLimit = $row->[2];
    my $allocationStartTime = $row->[3];
    my $allocationEndTime = $row->[4];
    
    $allocations{$allocationId}{startTime} = $allocationStartTime;
    $allocations{$allocationId}{endTime} = $allocationEndTime;
    $allocations{$allocationId}{balance} = $allocationAmount + $allocationCreditLimit;
  }

  # Subtract reservations from allocation balances
  # Lookup reservation amounts against these accounts
  # SELECT ReservationAllocation.Id,ReservationAllocation.Amount FROM Reservation,ReservationAllocation WHERE Reservation.Id=ReservationAllocation.Reservation AND Reservation.StartTime<=$now AND Reservation.EndTime>$now AND Account=$fromId

  my @objects =
  (
    new Gold::Object(name => "Reservation"),
    new Gold::Object(name => "ReservationAllocation"),
  );
  
  @selections =
  (
    new Gold::Selection(object => "ReservationAllocation", name => "Id"),
    new Gold::Selection(object => "ReservationAllocation", name => "Amount"),
  );
  
  @conditions =
  (
    new Gold::Condition(object => "Reservation", name => "Id", subject => "ReservationAllocation", value => "Reservation"),
    new Gold::Condition(object => "ReservationAllocation", name => "Account", value => $fromId),
  );
  if (defined $allocation)
  {
    push @conditions, new Gold::Condition(object => "ReservationAllocation", name => "Id", value => $allocation);
  }
  else
  {
    push @conditions, new Gold::Condition(object => "Reservation", name => "StartTime", value => $now, op => "LE");
    push @conditions, new Gold::Condition(object => "Reservation", name => "EndTime", value => $now, op => "GT");
  }
  
  $results = $database->select(objects => \@objects, selections => \@selections, conditions => \@conditions);
  foreach my $row (@{$results->{data}})
  {
    my $allocationId = $row->[0];
    my $reservationAmount = $row->[1];
      
    if (exists $allocations{$allocationId})
    {
      $allocations{$allocationId}{balance} -= $reservationAmount;
    }
  }

  # Sort the allocations by weight (earliest endtime first)
  my @allocations = sort { $allocations{$a}{endTime} <=> $allocations{$b}{endTime} } keys %allocations;

  # Iterate through the allocation list
  foreach my $allocationId (@allocations)
  {
    # The amount I subtract from this allocation should be the minimum of:
    # 1. $remaining (the amount left to withdraw)
    # 2. $allocations{$allocationId}{balance}
    my $transferAmount = min($remaining, $allocations{$allocationId}{balance});
    my $allocationStartTime = $allocations{$allocationId}{startTime};
    my $allocationEndTime = $allocations{$allocationId}{endTime};
    next unless $transferAmount;

    # Debit the allocation
    my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Modify", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Amount", value => $transferAmount, op => "Dec") ], conditions => [ new Gold::Condition(name => "Account", value => $fromId), new Gold::Condition(name => "Id", value => $allocationId) ]);
    my $subResponse = Gold::Base->modify($subRequest, $requestId);
    if ($subResponse->getStatus() eq "Failure")
    {
      return new Gold::Response()->failure($subResponse->getCode(), "Unable to debit allocation: " . $subResponse->getMessage());
    }

    # Log the transaction
    my @debitOptions = @options;
    push @debitOptions, new Gold::Option(name => "Id", value => $fromId);
    push @debitOptions, new Gold::Option(name => "Child", value => $allocationId);
    if ($allocationStartTime <= $now && $allocationEndTime > $now)
    {
      Gold::Bank->logTransaction(database => $database, requestId => $requestId, txnId => $database->nextId("Transaction"), object => "Account", action => "Transfer", actor => $actor, options => \@debitOptions, count => 1, account => $fromId, delta => 0 - $transferAmount, allocation => $allocationId);
    }
    else
    {
      Gold::Bank->logTransaction(database => $database, requestId => $requestId, txnId => $database->nextId("Transaction"), object => "Account", action => "Transfer", actor => $actor, options => \@debitOptions, count => 1, allocation => $allocationId);
    }
    $remaining -= $transferAmount;

    # Look to see if the destination Allocation already exists
    # SELECT Id FROM Allocation WHERE Account=$toId AND StartTime=$allocationStartTime AND EndTime=$allocationEndTime AND CallType=$type
    my $results = $database->select(object => "Allocation", selections => [ new Gold::Selection(name => "Id") ], conditions => [ new Gold::Condition(name => "Account", value => $toId), new Gold::Condition(name => "StartTime", value => $allocationStartTime), new Gold::Condition(name => "EndTime", value => $allocationEndTime), new Gold::Condition(name => "CallType", value => $type) ]);

    # An Allocation already exists
    my $allocationId = 0;
    if (@{$results->{data}})
    {
      my $allocationId = ${$results->{data}}[0]->[0];

      # Credit the allocation
      my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Modify", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Amount", value => $transferAmount, op => "Inc") ], conditions => [ new Gold::Condition(name => "Account", value => $toId), new Gold::Condition(name => "Id", value => $allocationId) ]);
      my $subResponse = Gold::Base->modify($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to credit allocation: " . $subResponse->getMessage());
      }
    }

    # An Allocation does not exist
    else
    {
      # Create a new one
      my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Create", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Account", value => $toId), new Gold::Assignment(name => "StartTime", value => $allocationStartTime), new Gold::Assignment(name => "EndTime", value => $allocationEndTime), new Gold::Assignment(name => "CallType", value => $type), new Gold::Assignment(name => "Amount", value => $transferAmount) ]);
      my $subResponse = Gold::Base->create($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to create allocation: " . $subResponse->getMessage());
      }
  
      # Figure out the id of the allocation we just created
      $allocationId = $subResponse->getDatumValue("Id");
    }

    # Log the transaction
    my @creditOptions = @options;
    push @creditOptions, new Gold::Option(name => "Id", value => $toId);
    push @creditOptions, new Gold::Option(name => "Child", value => $allocationId);
    if ($allocationStartTime <= $now && $allocationEndTime > $now)
    {
      Gold::Bank->logTransaction(database => $database, requestId => $requestId, txnId => $database->nextId("Transaction"), object => "Account", action => "Transfer", actor => $actor, options => \@creditOptions, count => 1, account => $toId, delta => $transferAmount, allocation => $allocationId);
    }
    else
    {
      Gold::Bank->logTransaction(database => $database, requestId => $requestId, txnId => $database->nextId("Transaction"), object => "Account", action => "Transfer", actor => $actor, options => \@creditOptions, count => 1, allocation => $allocationId);
    }

    # Break out if we are done
    last if $remaining <= 0;
  }

  # Fail if not all amount could be transferred
  if ($remaining > 0)
  {
    return new Gold::Response()->failure("784", "Insufficient balance to perform requested transfer");
  }

  my $time_division = defined $request->getOptionValue("ShowHours") ? 3600 : 1;
  my $currency_precision = $config->get_property("currency.precision", 0);
  $amount = sprintf("%.${currency_precision}f", $amount / $time_division);
  return new Gold::Response()->success($amount, "Successfully transferred $amount credits from account $fromId to account $toId");
}
  

# ----------------------------------------------------------------------------
# $response = withdraw($request, $requestId);
# ----------------------------------------------------------------------------

# Withdraw (Account)
sub withdraw
{
  my ($class, $request, $requestId) = @_;

  if ($log->is_debug())
  {
    $log->debug("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my $object = $request->getObject();
  my $actor = $request->getActor();
  my $database = $request->getDatabase();
  my $dbh = $database->{_handle};
  my $amount = $request->getOptionValue("Amount");
  my $remaining = $amount;
  my $id = $request->getOptionValue("Id");
  my $allocation = $request->getOptionValue("Allocation");
  my $type = $request->getOptionValue("CallType") || "Normal";
  my @options = $request->getOptions();
  my %allocations = ();
  my $active = 0;
  my $now = time;

  if ($object ne "Account")
  {
    return new Gold::Response()->failure("315", "The Bank class does not implement $object Withdraw");
  }

  # Amount must be positive
  if (! defined $amount)
  {
    return new Gold::Response()->failure("740", "Amount must be specified");
  }
  if ($amount <= 0)
  {
    return new Gold::Response()->failure("740", "Amount must be positive");
  }
  
  # Id must be specified
  if (! defined $id)
  {
    return new Gold::Response()->failure("740", "The account id must be specified");
  }

  # Refresh Allocations
  my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Refresh");
  my $subResponse = Gold::Bank->refresh($subRequest, $requestId);
  if ($subResponse->getStatus() eq "Failure")
  {
    return new Gold::Response()->failure($subResponse->getCode(), "Failed while refreshing allocations: " . $subResponse->getMessage());
  }

  # Check for valid account id
  # SELECT Id FROM Account WHERE Id=$id
  my $results = $database->select(object => "Account", selections => [ new Gold::Selection(name => "Id") ], conditions => [ new Gold::Condition(name => "Id", value => $id) ]);
  unless (@{$results->{data}})
  {
    return new Gold::Response()->failure("740", "Invalid account id ($id)");
  }
  
  # Look for candidate source allocations
  # SELECT Id,Amount,CreditLimit,StartTime,EndTime FROM Allocation WHERE CallType=$type AND Account=$id

  my @selections =
  (
    new Gold::Selection(name => "Id"),
    new Gold::Selection(name => "Amount"),
    new Gold::Selection(name => "CreditLimit"),
    new Gold::Selection(name => "StartTime"),
    new Gold::Selection(name => "EndTime"),
  );

  my @conditions =
  (
    new Gold::Condition(name => "Account", value => $id),
    new Gold::Condition(name => "CallType", value => $type),
  );

  if (defined $allocation)
  {
    push @conditions, new Gold::Condition(name => "Id", value => $allocation);
  }
  else
  {
    push @conditions, new Gold::Condition(name => "StartTime", value => $now, op => "LE");
    push @conditions, new Gold::Condition(name => "EndTime", value => $now, op => "GT");
  }

  $results = $database->select(object => "Allocation", selections => \@selections, conditions => \@conditions);

  # Fail if there are no valid allocations to withdraw from
  unless (@{$results->{data}})
  {
    return new Gold::Response()->failure("782", "Insufficient funds: There are no valid allocations from which to withdraw");
  }

  foreach my $row (@{$results->{data}})
  {
    my $allocationId = $row->[0];
    my $allocationAmount = $row->[1];
    my $allocationCreditLimit = $row->[2];
    my $allocationStartTime = $row->[3];
    my $allocationEndTime = $row->[4];
    
    $allocations{$allocationId}{startTime} = $allocationStartTime;
    $allocations{$allocationId}{endTime} = $allocationEndTime;
    $allocations{$allocationId}{weight} = $allocationEndTime;
    $allocations{$allocationId}{balance} = $allocationAmount + $allocationCreditLimit;
  }

  # Subtract active reservations from allocation balances
  # Lookup reservation amounts against these accounts
  # SELECT ReservationAllocation.Id,ReservationAllocation.Amount FROM Reservation,ReservationAllocation WHERE Reservation.Id=ReservationAllocation.Reservation AND Reservation.StartTime<=$now AND Reservation.EndTime>$now AND Account=$fromId

  my @objects =
  (
    new Gold::Object(name => "Reservation"),
    new Gold::Object(name => "ReservationAllocation"),
  );
  
  @selections =
  (
    new Gold::Selection(object => "ReservationAllocation", name => "Id"),
    new Gold::Selection(object => "ReservationAllocation", name => "Amount"),
  );
  
  @conditions =
  (
    new Gold::Condition(object => "Reservation", name => "Id", subject => "ReservationAllocation", value => "Reservation"),
    new Gold::Condition(object => "ReservationAllocation", name => "Account", value => $id),
  );
  
  if (defined $allocation)
  {
    push @conditions, new Gold::Condition(object => "ReservationAllocation", name => "Id", value => $allocation);
  }
  else
  {
    push @conditions, new Gold::Condition(object => "Reservation", name => "StartTime", value => $now, op => "LE");
    push @conditions, new Gold::Condition(object => "Reservation", name => "EndTime", value => $now, op => "GT");
  }
  
  $results = $database->select(objects => \@objects, selections => \@selections, conditions => \@conditions);
  foreach my $row (@{$results->{data}})
  {
    my $allocationId = $row->[0];
    my $reservationAmount = $row->[1];
      
    if (exists $allocations{$allocationId})
    {
      $allocations{$allocationId}{balance} -= $reservationAmount;
    }
  }

  # Sort the allocations by weight (earliest endtime first)
  my @allocations = sort { $allocations{$a}{endTime} <=> $allocations{$b}{endTime} } keys %allocations;

  # Iterate through the allocation list
  foreach my $allocationId (@allocations)
  {
    # The amount I subtract from this allocation should be the minimum of:
    # 1. $remaining (the amount left to withdraw)
    # 2. $allocations{$allocationId}{balance} (the amount supportable by this allocation itself (and constrained by credit limit))
    my $debitAmount = min($remaining, $allocations{$allocationId}{balance});
    my $allocationStartTime = $allocations{$allocationId}{startTime};
    my $allocationEndTime = $allocations{$allocationId}{endTime};
    next unless $debitAmount > 0;

    # Debit the allocation
    my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Modify", actor => $config->get_property("super.user", $SUPER_USER), assignments => [ new Gold::Assignment(name => "Amount", value => $debitAmount, op => "Dec") ], conditions => [ new Gold::Condition(name => "Account", value => $id), new Gold::Condition(name => "Id", value => $allocationId) ]);
    my $subResponse = Gold::Base->modify($subRequest, $requestId);
    if ($subResponse->getStatus() eq "Failure")
    {
      return new Gold::Response()->failure($subResponse->getCode(), "Unable to debit allocation: " . $subResponse->getMessage());
    }

    # Log the transaction
    my @creditOptions = @options;
    push @creditOptions, new Gold::Option(name => "Child", value => $allocationId);
    if ($allocationStartTime <= $now && $allocationEndTime > $now)
    {
      Gold::Bank->logTransaction(database => $database, requestId => $requestId, txnId => $database->nextId("Transaction"), object => "Account", action => "Withdraw", actor => $actor, options => \@creditOptions, count => 1, account => $id, delta => 0 - $debitAmount, allocation => $allocationId);
    }
    else
    {
      Gold::Bank->logTransaction(database => $database, requestId => $requestId, txnId => $database->nextId("Transaction"), object => "Account", action => "Withdraw", actor => $actor, options => \@creditOptions, count => 1, allocation => $allocationId);
    }
    $remaining -= $debitAmount;

    # Break out if we are done
    last if $remaining <= 0;
  }

  # Fail if not all amount could be debited
  if ($remaining > 0)
  {
    return new Gold::Response()->failure("784", "Insufficient balance to perform requested withdrawal");
  }

  my $time_division = defined $request->getOptionValue("ShowHours") ? 3600 : 1;
  my $currency_precision = $config->get_property("currency.precision", 0);
  $amount = sprintf("%.${currency_precision}f", $amount / $time_division);
  return new Gold::Response()->success($amount, "Successfully withdrew $amount credits from account $id");
}
  

# ----------------------------------------------------------------------------
# $response = undelete($request, $requestId);
# ----------------------------------------------------------------------------

# Undelete (Account, Allocation)
sub undelete
{
  my ($class, $request, $requestId) = @_;

  if ($log->is_debug())
  {
    $log->debug("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my $object = $request->getObject();
  my $actor = $request->getActor();
  my $database = $request->getDatabase();
  my @conditions = $request->getConditions();
  my @options = $request->getOptions();
  my $now = time;

  if ($object eq "Account")
  {
    # Get a list of accounts to be undeleted
    # SELECT Id FROM Account WHERE Deleted=True && <Conditions>
    push @conditions, new Gold::Condition(name => "Deleted", value => "True");
    my $results = $database->select(object => "Account", selections => [ new Gold::Selection(name => "Id") ], conditions => \@conditions);
    foreach my $row (@{$results->{data}})
    {
      my $id = $row->[0];

      # Undelete all allocations associated with this account
      my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Undelete", actor => $config->get_property("super.user", $SUPER_USER), conditions => [ new Gold::Condition(name => "Account", value => $id) ]);
      my $subResponse = Gold::Bank->undelete($subRequest, $requestId);
      if ($subResponse->getStatus() eq "Failure")
      {
        return new Gold::Response()->failure($subResponse->getCode(), "Unable to undelete allocation: " . $subResponse->getMessage());
      }
    }

    # Undelete accounts by calling base Account Undelete
    my $baseResponse = Gold::Base->undelete($request, $requestId);
  
    return $baseResponse;
  }

  elsif ($object eq "Allocation")
  {
    # Refresh Allocations
    my $subRequest = new Gold::Request(database => $database, object => "Allocation", action => "Refresh");
    my $subResponse = Gold::Bank->refresh($subRequest, $requestId);
    if ($subResponse->getStatus() eq "Failure")
    {
      return new Gold::Response()->failure($subResponse->getCode(), "Failed while refreshing allocations: " . $subResponse->getMessage());
    }
  
    # Get a list of allocations to be undeleted
    # SELECT Id,Account,Amount,StartTime,EndTime FROM Allocation WHERE Deleted=True AND <Conditions>
    push @conditions, new Gold::Condition(name => "Deleted", value => "True");
    my $results = $database->select(object => "Allocation", selections => [ new Gold::Selection(name => "Id"), new Gold::Selection(name => "Account"), new Gold::Selection(name => "Amount"), new Gold::Selection(name => "StartTime"), new Gold::Selection(name => "EndTime") ], conditions => \@conditions);
    foreach my $row (@{$results->{data}})
    {
      my $id = $row->[0];
      my $account = $row->[1];
      my $amount = $row->[2];
      my $startTime = $row->[3];
      my $endTime = $row->[4];
  
      # Log the transaction (includes the new account id and delta)
      if ($startTime <= $now && $endTime > $now)
      {
        Gold::Bank->logTransaction(database => $database, requestId => $requestId, txnId => $database->nextId("Transaction"), object => "Allocation", action => "Undelete", actor => $actor, conditions => [ new Gold::Condition(name => "Id", value => $id), new Gold::Condition(name => "Description", value => "Redundant entry includes account and delta") ], options => \@options, count => 1, account => $account, delta => $amount, allocation => $id);
      }
    }
    
    # Undelete allocations by calling base Allocation Undelete
    my $baseResponse = Gold::Base->undelete($request, $requestId);
  
    return $baseResponse;
  }

  else
  {
    return new Gold::Response()->failure("315", "The Bank class does not implement $object Undelete");
  }
}


# ----------------------------------------------------------------------------
# $response = usage($request, $requestId);
# ----------------------------------------------------------------------------

# Custom Bank Usage
sub usage
{
  my ($class, $request, $requestId) = @_;

  if ($log->is_debug())
  {
    $log->debug("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  my $action = $request->getAction();
  my $object = $request->getObject();
  my @objects = $request->getObjects();

  # Begin the usage
  my $usage = "<Request action=\"$action\">\n";

  # Bank actions do not support multiple objects
  if (@objects > 1)
  {
    return new Gold::Response()->failure("313", "Bank actions do not suppport multiple objects");
  }

  # Handle disabled commands
  if ($action eq "Create" && $object eq "Allocation")
  {
    return new Gold::Response(status => "Warning", code => "144", message => "This Bank action is disallowed because it bypasses accounting");
  }

  # Add the object to the usage
  $usage .= "    <Object>$object</Object>\n";

  # Balance (Account)
  if ($action eq "Balance" && $object eq "Account")
  {
    $usage .= "    [<Option name=\"User\">{User Name}</Option>]\n";
    $usage .= "    [<Option name=\"Project\">{Project Name}</Option>]\n";
    $usage .= "    [<Option name=\"Machine\">{Machine Name}</Option>]\n";
    $usage .= "    [<Option name=\"Id\">{Account Id}</Option>]*\n";
    $usage .= "    [<Option name=\"IgnoreReservations\">True|False (False)</Option>]\n";
    $usage .= "    [<Option name=\"IgnoreAncestors\">True|False (False)</Option>]\n";
    $usage .= "    [<Option name=\"ShowAvailableCredit\">True|False (False)</Option>]\n";
  }
  
  # Charge (Job)
  elsif ($action eq "Charge" && $object eq "Job")
  {
    $usage .= "    <Data>\n";
    $usage .= "      <Job>\n";
    $usage .= "        <JobId>{Job Id}</JobId>\n";
    $usage .= "        [<UserId>{User Name}</UserId>]\n";
    $usage .= "        [<ProjectId>{Project Name}</ProjectId>]\n";
    $usage .= "        [<MachineName>{Machine Name}</MachineName>]\n";
    $usage .= "        <WallDuration>{Integer Number}</WallDuration>\n";
    $usage .= "        [<StartTime>{Start Time}</StartTime>]\n";
    $usage .= "        [<EndTime>{End Time}</EndTime>]\n";
    $usage .= "        [<QuoteId>{Quotation Id}</QuoteId>]\n";
    $usage .= "        [<{Consumable Resource Name}>{Consumable Resource Amount}</{Consumable Resource Name}>]*\n";
    $usage .= "        [<{Charge Rate Type}>{Charge Rate Name}</{Charge Rate Type}>]*\n";
    $usage .= "        [<{Job Property Name}>{Job Property Value}</{Job Property Name}>]*\n";
    $usage .= "      </Job>\n";
    $usage .= "    </Data>\n";
  }
  
  # Deposit (Account)
  elsif ($action eq "Deposit" && $object eq "Account")
  {
    $usage .= "    <Option name=\"Id\">{Account Id}</Option>\n";
    $usage .= "    [<Option name=\"Amount\">{Decimal Number}</Option>]\n";
    $usage .= "    [<Option name=\"StartTime\">{Start Time}</Option>]\n";
    $usage .= "    [<Option name=\"EndTime\">{End Time}</Option>]\n";
    $usage .= "    [<Option name=\"Ancestors\">{List of Ancestor Ids}</Option>]\n";
    $usage .= "    [<Option name=\"Description\">{Transaction Description}</Option>]\n";
  }
  
  # Query (Account)
  elsif ($action eq "Query" && $object eq "Account")
  {
    $usage .= "    [<Get name=\"Id\" [op=\"Sort|Tros|Count|GroupBy|Max|Min\"]></Get>]\n";
    $usage .= "    [<Get name=\"Name\" [op=\"Sort|Tros|Count|GroupBy|Max|Min\"]></Get>]\n";
    $usage .= "    [<Get name=\"Description\" [op=\"Sort|Tros|Count|GroupBy|Max|Min\"]></Get>]\n";
    $usage .= "    [<Where name=\"Id\" [op=\"EQ|NE|GT|GE|LT|LE (EQ)\"] [conj=\"And|Or (And)\"] [group=\"<Integer Number>\"]>{Integer Number}</Where>]*\n";
    $usage .= "    [<Where name=\"Name\" [op=\"EQ|NE|GT|GE|LT|LE|Match (EQ)\"] [conj=\"And|Or (And)\"] [group=\"<Integer Number>\"]>{Account Name}</Where>]\n";
    $usage .= "    [<Where name=\"Description\" [op=\"EQ|NE|GT|GE|LT|LE|Match (EQ)\"] [conj=\"And|Or (And)\"] [group=\"<Integer Number>\"]>{Description}</Where>]\n";
    $usage .= "    [<Option name=\"User\">{User Name}</Option>]\n";
    $usage .= "    [<Option name=\"Project\">{Project Name}</Option>]\n";
    $usage .= "    [<Option name=\"Machine\">{Machine Name}</Option>]\n";
    $usage .= "    [<Option name=\"Active\">True|False</Option>]\n";
    $usage .= "    [<Option name=\"UseRules\">True|False (False)</Option>]\n";
    $usage .= "    [<Option name=\"IncludeAncestors\">True|False (False)</Option>]\n";
    $usage .= "    [<Option name=\"Time\">YYYY-MM-DD [hh:mm:ss]</Option>]\n";
    $usage .= "    [<Option name=\"Unique\">True|False (False)</Option>]\n";
    $usage .= "    [<Option name=\"Limit\">{Integer Number}</Option>\n";
    $usage .= "    [<Option name=\"Offset\">{Integer Number}</Option>]]\n";
  }
  
  # Quote (Job)
  elsif ($action eq "Quote" && $object eq "Job")
  {
    $usage .= "    <Data>\n";
    $usage .= "      <Job>\n";
    $usage .= "        [<UserId>{User Name}</UserId>]\n";
    $usage .= "        [<ProjectId>{Project Name}</ProjectId>]\n";
    $usage .= "        [<MachineName>{Machine Name}</MachineName>]\n";
    $usage .= "        <WallDuration>{Integer Number}</WallDuration>\n";
    $usage .= "        [<StartTime>{Start Time}</StartTime>]\n";
    $usage .= "        [<EndTime>{End Time}</EndTime>]\n";
    $usage .= "        [<{Consumable Resource Name}>{Consumable Resource Amount}</{Consumable Resource Name}>]*\n";
    $usage .= "        [<{Charge Rate Type}>{Charge Rate Name}</{Charge Rate Type}>]*\n";
    $usage .= "        [<{Job Property Name}>{Job Property Value}</{Job Property Name}>]*\n";
    $usage .= "      </Job>\n";
    $usage .= "    </Data>\n";
    $usage .= "    [<Option name=\"Guarantee\">True|False (False)</Option>]\n";
  }
  
  # Refund (Job)
  elsif ($action eq "Refund" && $object eq "Job")
  {
    $usage .= "    [<Option name=\"JobId\">{Job Id}</Option>]\n";
    $usage .= "    [<Option name=\"Id\">{Internal Job Id}</Option>]\n";
    $usage .= "    [<Option name=\"Account\">{Account Id}</Option>]\n";
    $usage .= "    [<Option name=\"Amount\">{Decimal Number}</Option>]\n";
    $usage .= "    [<Option name=\"Description\">{Transaction Description}</Option>]\n";
  }
  
  # Reserve (Job)
  elsif ($action eq "Reserve" && $object eq "Job")
  {
    $usage .= "    <Data>\n";
    $usage .= "      <Job>\n";
    $usage .= "        <JobId>{Job Id}</JobId>\n";
    $usage .= "        [<UserId>{User Name}</UserId>]\n";
    $usage .= "        [<ProjectId>{Project Name}</ProjectId>]\n";
    $usage .= "        [<MachineName>{Machine Name}</MachineName>]\n";
    $usage .= "        <WallDuration>{Integer Number}</WallDuration>\n";
    $usage .= "        [<QuoteId>{Quotation Id}</QuoteId>]\n";
    $usage .= "        [<StartTime>{Start Time}</StartTime>]\n";
    $usage .= "        [<EndTime>{End Time}</EndTime>]\n";
    $usage .= "        [<{Consumable Resource Name}>{Consumable Resource Amount}</{Consumable Resource Name}>]*\n";
    $usage .= "        [<{Charge Rate Type}>{Charge Rate Name}</{Charge Rate Type}>]*\n";
    $usage .= "        [<{Job Property Name}>{Job Property Value}</{Job Property Name}>]*\n";
    $usage .= "      </Job>\n";
    $usage .= "    </Data>\n";
    $usage .= "    [<Option name=\"Replace\">True|False (False)</Option>]\n";
  }
  
  # Transfer (Account)
  elsif ($action eq "Transfer" && $object eq "Account")
  {
    $usage .= "    <Option name=\"FromId\">{Source Account Id}</Option>\n";
    $usage .= "    <Option name=\"ToId\">{Target Account Id}</Option>\n";
    $usage .= "    <Option name=\"Amount\">{Decimal Number}</Option>\n";
    $usage .= "    [<Option name=\"StartTime\">{Start Time}</Option>\n";
    $usage .= "    <Option name=\"EndTime\">{End Time}</Option>]\n";
    $usage .= "    [<Option name=\"Description\">{Transaction Description}</Option>]\n";
  }
  
  # Withdraw (Account)
  elsif ($action eq "Withdraw" && $object eq "Account")
  {
    $usage .= "    <Option name=\"Id\">{Account Id}</Option>\n";
    $usage .= "    <Option name=\"Amount\">{Decimal Number}</Option>\n";
    $usage .= "    [<Option name=\"StartTime\">{Start Time}</Option>\n";
    $usage .= "    <Option name=\"EndTime\">{End Time}</Option>]\n";
    $usage .= "    [<Option name=\"Description\">{Transaction Description}</Option>]\n";
  }
  
  # Fall through to Base actions
  else
  {
    return new Gold::Response()->failure("313", "Unsupported bank usage: ($action)");
  }

  # Terminate the usage
  $usage .= "    [<Option name=\"ShowHidden\">True|False (False)</Option>]\n";
  $usage .= "    [<Option name=\"ShowUsage\">True|False (False)</Option>]\n";
  $usage .= "</Request>";

  return new Gold::Response(status => "Success", code => "010", message => $usage);
}
 

# ----------------------------------------------------------------------------
# logTransaction(database => $database,
#                   object => $object,
#                   action => $action,
#                   actor => $actor,
#                   assignments => \@assignments,
#                   conditions => \@conditions,
#                   options => \@options,
#                   data => \@data,
#                   count => $count,
#                   account => $account,
#                   allocation => $allocation,
#                   delta => $delta,
#                   requestId => $requestId,
#                   txnId => $txnId
#                   );
# ----------------------------------------------------------------------------

# Log Transaction
sub logTransaction
{
  my ($class, %arg) = @_;

  if ($log->is_debug())
  {
    $log->debug("invoked with arguments: (" , join(', ', map { "$_ => $arg{$_}" } keys %arg) , ")");
  }

  # Declare and Initialize variables
  my $database = $arg{database};
  my $dbh = $database->{_handle};
  my $object = $arg{object};
  my $action = $arg{action} || "Create";
  my $actor = $arg{actor};
  my @assignments = $arg{assignments} ? @{$arg{assignments}} : ();
  my @conditions = $arg{conditions} ? @{$arg{conditions}} : ();
  my @options = $arg{options} ? @{$arg{options}} : ();
  my @data = $arg{data} ? @{$arg{data}} : ();
  my $count = $arg{count};
  my $delta = $arg{delta};
  my $account = $arg{account};
  my $allocation = $arg{allocation};
  my $requestId = $arg{requestId};
  my $txnId = $arg{txnId};
  my $names = "g_object,g_action";
  my $values = "'$object','$action'";
  my $subject = "";
  my $child = "";
  my $user = "";
  my $project = "";
  my $machine = "";
  my $jobId = "";
  my $description = "";
  my $details = "";
  my $firstTime;
  my $amount;
  my $now = time;

  # Log the user requesting the transaction
  $names .= ",g_actor";
  $values .= ",'$actor'";

  # Iterate over assignments
  foreach my $assignment (@assignments)
  {
    my $name = $assignment->getName();
    my $value = $assignment->getValue();
    my $op = $assignment->getOperator();

    # Append name to name or child
    if ($name eq "Name" || $name eq "Id")
    {
      if (Gold::Cache->getObjectProperty($object, "Association") eq "True")
      {
       if ($child ne "") { $child .= ","; }
       $child .= $value;
      }
      else
      {
        if ($subject ne "") { $subject .= ","; }
        $subject .= $value;
      }
    }

    # Append parent to name if association
    elsif (Gold::Cache->getObjectProperty($object, "Association") eq "True" && $name eq Gold::Cache->getObjectProperty($object, "Parent"))
    {
      if ($subject ne "") { $subject .= ","; }
       $subject .= $value;
    }

    # Append jobId
    elsif ($name eq "JobId")
    {
      if ($jobId ne "") { $jobId .= ","; }
      $jobId .= $value;
    }

    # Append user
    elsif ($name eq "User")
    {
      if ($user ne "") { $user .= ","; }
      $user .= $value;
    }

    # Append project
    elsif ($name eq "Project")
    {
      if ($project ne "") { $project .= ","; }
      $project .= $value;
    }

    # Append machine
    elsif ($name eq "Machine")
    {
      if ($machine ne "") { $machine .= ","; }
      $machine .= $value;
    }

    # Set amount
    elsif ($name eq "Amount")
    {
      $amount = $value;
    }

    # Append description
    elsif ($name eq "Description")
    {
      if ($description ne "") { $description .= ","; }
      $description .= $value;
    }

    # Append as detail
    else
    {
      if ($details ne "") { $details .= ","; }
      $details .= $name;
      if (! $op)
      {
        $details .= "="; # Use = for assignments
      }
      else
      {
        if ($op eq "Assign") { $details .= "="; }
        elsif ($op eq "Inc") { $details .= "+="; }
        elsif ($op eq "Dec") { $details .= "-="; }
        else {$details .= "{" + $op + "}"; }
      }
      $details .= $value;
    }
  }

  # Iterate over conditions
  foreach my $condition (@conditions)
  {
    my $name = $condition->getName();
    my $value = $condition->getValue();
    my $op = $condition->getOperator();

    # Append name to name or child
    if ($name eq "Name" || $name eq "Id")
    {
      if (Gold::Cache->getObjectProperty($object, "Association") eq "True")
      {
       if ($child ne "") { $child .= ","; }
       $child .= $value;
      }
      else
      {
        if ($subject ne "") { $subject .= ","; }
        $subject .= $value;
      }
    }

    # Append parent to name if association
    elsif (Gold::Cache->getObjectProperty($object, "Association") eq "True" && $name eq Gold::Cache->getObjectProperty($object, "Parent"))
    {
      if ($subject ne "") { $subject .= ","; }
       $subject .= $value;
    }

    # Append JobId
    elsif ($name eq "JobId")
    {
      if ($jobId ne "") { $jobId .= ","; }
      $jobId .= $value;
    }

    # Append user
    elsif ($name eq "User")
    {
      if ($user ne "") { $user .= ","; }
      $user .= $value;
    }

    # Append project
    elsif ($name eq "Project")
    {
      if ($project ne "") { $project .= ","; }
      $project .= $value;
    }

    # Append machine
    elsif ($name eq "Machine")
    {
      if ($machine ne "") { $machine .= ","; }
      $machine .= $value;
    }

    # Set amount
    elsif ($name eq "Amount")
    {
      $amount = $value;
    }

    # Append description
    elsif ($name eq "Description")
    {
      if ($description ne "") { $description .= ","; }
      $description .= $value;
    }

    # Append as detail
    else
    {
      if ($details ne "") { $details .= ","; }
      $details .= $name;
      if (! $op)
      {
        $details .= "==";
      }
      else
      {
        if ($op eq "EQ") { $details .= "=="; }
        elsif ($op eq "GT") { $details .= ">"; }
        elsif ($op eq "GE") { $details .= ">="; }
        elsif ($op eq "LT") { $details .= "<"; }
        elsif ($op eq "LE") { $details .= "<="; }
        elsif ($op eq "NE") { $details .= "!="; }
        elsif ($op eq "Match") { $details .= "~="; }
        else {$details .= "{" + $op + "}"; }
      }
      $details .= $value;
    }
  }

  # Iterate over options
  foreach my $option (@options)
  {
    my $name = $option->getName();
    my $value = $option->getValue();
    my $op = $option->getOperator();

    # Append name to name or child
    if ($name eq "Name" || $name eq "Id")
    {
      if (Gold::Cache->getObjectProperty($object, "Association") eq "True")
      {
       if ($child ne "") { $child .= ","; }
       $child .= $value;
      }
      else
      {
        if ($subject ne "") { $subject .= ","; }
        $subject .= $value;
      }
    }

    # Append parent to name if association
    elsif (Gold::Cache->getObjectProperty($object, "Association") eq "True" && $name eq Gold::Cache->getObjectProperty($object, "Parent"))
    {
      if ($subject ne "") { $subject .= ","; }
       $subject .= $value;
    }

    # Append jobId
    elsif ($name eq "JobId")
    {
      if ($jobId ne "") { $jobId .= ","; }
      $jobId .= $value;
    }

    # Append user
    elsif ($name eq "User")
    {
      if ($user ne "") { $user .= ","; }
      $user .= $value;
    }

    # Append project
    elsif ($name eq "Project")
    {
      if ($project ne "") { $project .= ","; }
      $project .= $value;
    }

    # Append machine
    elsif ($name eq "Machine")
    {
      if ($machine ne "") { $machine .= ","; }
      $machine .= $value;
    }

    # Set amount
    elsif ($name eq "Amount")
    {
      $amount = $value;
    }

    # Append description
    elsif ($name eq "Description")
    {
      if ($description ne "") { $description .= ","; }
      $description .= $value;
    }

    # Explicity set child if specified
    elsif ($name eq "Child")
    {
      $child .= $value;
    }

    # Append as detail
    else
    {
      if ($details ne "") { $details .= ","; }
      $details .= $name;
      if (! $op)
      {
        $details .= ":=";
      }
      else
      {
        if ($op eq "Not") { $details .= ":!"; }
        else {$details .= "{" + $op + "}"; }
      }
      $details .= $value;
    }
  }

  # Iterate over data
  foreach my $datum (@data)
  {
    my $name = $datum->getName();
    if ($name eq "Job")
    {
      # Append jobId
      if ($datum->getValue("JobId"))
      {
        $jobId = $datum->getValue("JobId");
      }

      # Append user
      if ($datum->getValue("UserId"))
      {
        $user = $datum->getValue("UserId");
      }

      # Append project
      if ($datum->getValue("ProjectId"))
      { 
        $project = $datum->getValue("ProjectId");
      }

      # Append machine
      if ($datum->getValue("MachineName"))
      {
        $machine = $datum->getValue("MachineName");
      }

      # Set charge
      if ($datum->getValue("Charge"))
      {
        $amount = $datum->getValue("Charge");
      }

      # Append job details
      if ($details ne "") { $details .= ","; }
      $details .= $datum->toString();
    }
  }

  # Add fields to sql names and values

  # Log name
  if ($subject ne "")
  {
    $names .= ",g_name";
    $values .= ",'$subject'";
  }
  
  # Log child
  if ($child ne "")
  {
    $names .= ",g_child";
    $values .= ",'$child'";
  }
  
  # Log jobId
  if ($jobId ne "")
  {
    $names .= ",g_job_id";
    $values .= ",'$jobId'";
  }
  
  # Log project
  if ($project ne "")
  {
    $names .= ",g_project";
    $values .= ",'$project'";
  }
  
  # Log user
  if ($user ne "")
  {
    $names .= ",g_user";
    $values .= ",'$user'";
  }
  
  # Log machine
  if ($machine ne "")
  {
    $names .= ",g_machine";
    $values .= ",'$machine'";
  }
  
  # Log count
  if (defined $count)
  {
    $names .= ",g_count";
    $values .= ",$count";
  }
  
  # Log amount
  if (defined $amount)
  {
    $names .= ",g_amount";
    $values .= ",$amount";
  }
  
  # Log account
  if (defined $account)
  {
    $names .= ",g_account";
    $values .= ",$account";
  }
  
  # Log allocation
  if (defined $allocation)
  {
    $names .= ",g_allocation";
    $values .= ",$allocation";
  }

  # Log delta
  if (defined $delta)
  {
    $names .= ",g_delta";
    $values .= ",$delta";
  }
  
  # Log description
  if ($description ne "")
  {
    $names .= ",g_description";
    $values .= ",'$description'";
  }

  # Log details
  if ($details ne "")
  {
    # Truncate details value if necessary
    if (length $details >= 1024)
    {
      $details = substr($details, 0, 1024);
    }
    $names .= ",g_details";
    $values .= ",'$details'";
  }

  # Log creationdate, modificationdate, requestId, txnId and id
  $names .= ",g_creation_time,g_modification_time,g_request_id,g_transaction_id,g_id";
  $values .= ",$now,$now,$requestId,$txnId,$txnId";

  # Add column list
  my $sql = "INSERT INTO g_transaction ($names) VALUES ($values)";

  # Perform SQL Update
  if ($log->is_debug())
  {
    $log->debug("SQL Update: $sql");
  }
  $dbh->do($sql);
}

1;

