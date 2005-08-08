#! /usr/bin/perl -w
# 1. Update the above line with the fully qualified path to your Perl binary

################################################################################
#
# Synchronizes gold with qbank
# This perl script is a starting point for translating a QBank 2.11.0 database
# to a new Gold 1.0.b0.0 installation via qbank low-level queries and
# Gold API calls. This script will certainly require manual tweaking and thus
# is intended only as an aid to experienced admins. It should be run with
# both qbankd and goldd running and after the gold <bank.gold has completed.
#
# File   :  qbank2gold.pl
# History:  5 DEC 2003 [Scott Jackson] first implementation
#           3 SEP 2004 [Scott Jackson] beta mods
#
################################################################################

use strict;
use vars qw($GOLD_HOME);

# 2. Set the GOLD_HOME variable to the gold install directory (same as prefix)

BEGIN { $GOLD_HOME = "/usr/local/gold"; }

use lib qw ($GOLD_HOME/lib $GOLD_HOME/lib/perl5);
use Gold;

# 3. Set the QBANK_HOME variable to the qbank install directory

my $QBANK_HOME = "/usr/local/qbank";
my $debug = 0;
$| = 1;

# 4. Disable the account autogen property by uncommenting and setting the line
#    account.autogen = false
#    in the $GOLD_HOME/etc/goldd.conf file.

# 5. Examine the remainder of the script for applicability and edit as
#    necessary.

# 6. Make this script executable (chmod +x qbank2gold.pl) and run it
#    (./qbank2gold.pl).

Main:
{
  # Synchronize Machines
  print "Synchronizing Machines:\n";
  open ALLOCATIONS, "${QBANK_HOME}/bin/qbank get_allocations|";
  my %machines = ();
  foreach my $line (<ALLOCATIONS>)
  {
    chomp $line;
    my ($accountname,$allockey,$amount,$expirationdate,$activationdate,$active,$allowmachines,$alloctype) = split(/\|/,$line);

    if ($allowmachines)
    {
      foreach my $machinename (split(/:/, $allowmachines))
      {
        if ($machinename && $machinename ne "ANY")
	{
          $machines{$machinename}++;
	}
      }
    }
  }

  foreach my $machinename (keys %machines)
  {
    # Create the new machine
    my $request = new Gold::Request(object => "Machine", action => "Create");
    $request->setAssignment("Name", $machinename); 
    print "Request: ", $request->toString() if $debug;
    my $response = $request->getResponse();
    print "Response: ", $response->toString() if $debug;
    &Gold::Client::displayResponse($response);
  }

  print "Sleeping for 5 seconds...\n";
  sleep 5; 

  # Synchronize Projects
  print "Synchronizing Projects:\n";
  open ACCOUNTS, "${QBANK_HOME}/bin/qbank get_accounts|";
  foreach my $line (<ACCOUNTS>)
  {
    chomp $line;
    my ($accountname,$accountactive,$defaultmachines,$creationdate,$accounttype,$exchangehost,$exchangeport,$exchangeacct,$exchangeuser,$exchangerate) = split(/\|/,$line);

    # Create the new Project
    my $request = new Gold::Request(object => "Project", action => "Create");
    $request->setAssignment("Name", $accountname); 
    $request->setAssignment("Active", "False") unless $accountactive;
    print "Request: ", $request->toString() if $debug;
    my $response = $request->getResponse();
    print "Response: ", $response->toString() if $debug;
    &Gold::Client::displayResponse($response);

    # Create ProjectMachines
    if ($defaultmachines)
    {
      foreach my $machinename (split(/:/, $defaultmachines))
      {
        if ($machinename && $machinename ne "ANY")
	{
	  # Create the new ProjectMachine
          my $request = new Gold::Request(object => "ProjectMachine", action => "Create");
          $request->setAssignment("Project", $accountname); 
    	  $request->setAssignment("Name", $machinename);
          print "Request: ", $request->toString() if $debug;
          my $response = $request->getResponse();
          print "Response: ", $response->toString() if $debug;
          &Gold::Client::displayResponse($response);
	}
      }
    }
  }

  print "Sleeping for 5 seconds...\n";
  sleep 5; 

  # Synchronize Users
  print "Synchronizing Users:\n";
  open USERS, "${QBANK_HOME}/bin/qbank get_users|";
  foreach my $line (<USERS>)
  {
    chomp $line;
    my ($username,$defaultaccount,$realname,$phonenumber,$email,$description) = split(/\|/,$line);

    next if $username eq "KITTY" || $username eq "RESERVE" || $username eq "ANY";

    # Create the new user
    my $request = new Gold::Request(object => "User", action => "Create");
    $request->setAssignment("Name", $username); 
    $request->setAssignment("Description", $description) if $description; 
    $request->setAssignment("CommonName", $realname) if $realname; 
    $request->setAssignment("PhoneNumber", $phonenumber) if $phonenumber; 
    $request->setAssignment("EmailAddress", $email) if $email; 
    $request->setOption("NoRefresh", "True"); 
    print "Request: ", $request->toString() if $debug;
    my $response = $request->getResponse();
    print "Response: ", $response->toString() if $debug;
    &Gold::Client::displayResponse($response);

    # Set the default project
    if ($response->getStatus() eq "Success" && $defaultaccount)
    {
      my $request = new Gold::Request(object => "User", action => "Modify");
      $request->setAssignment("DefaultProject", $defaultaccount);
      $request->setCondition("Name", $username);
      print "Request: ", $request->toString() if $debug;
      my $response = $request->getResponse();
      print "Response: ", $response->toString() if $debug;
      &Gold::Client::displayResponse($response);
    }
  }

  print "Sleeping for 5 seconds...\n";
  sleep 5; 

  # Synchronize ProjectUsers
  print "Synchronizing ProjectUsers:\n";
  open SUBACCOUNTS, "${QBANK_HOME}/bin/qbank get_subaccounts|";
  foreach my $line (<SUBACCOUNTS>)
  {
    chomp $line;
    my ($accountname,$username,$userstatus,$depositmask) = split(/\|/,$line);

    next if $userstatus eq "reserved";

    # Create the new projectUser
    my $request = new Gold::Request(object => "ProjectUser", action => "Create");
    $request->setAssignment("Project", $accountname); 
    $request->setAssignment("Name", $username); 
    $request->setAssignment("Active", "False") if $userstatus eq "disabled";
    $request->setAssignment("Admin", "True") if $userstatus eq "admin";
    print "Request: ", $request->toString() if $debug;
    my $response = $request->getResponse();
    print "Response: ", $response->toString() if $debug;
    &Gold::Client::displayResponse($response);
  }

  print "Sleeping for 5 seconds...\n";
  sleep 5; 

  # Synchronize Accounts and Allocations
  # We do not want to run this section more than once as it will create a duplicate set of accounts
  print "Synchronizing Accounts:\n";
  my %accounts = ();
  open SUBALLOCATIONS, "${QBANK_HOME}/bin/qbank get_suballocations|";
  foreach my $line (<SUBALLOCATIONS>)
  {
    chomp $line;
    my ($accountname,$username,$amount,$allockey,$alloctype,$expirationdate,$activationdate,$active,$allowmachines,$overdraft) = split(/\|/,$line);

    #$accounts{"${accountname}|${username}|${allowmachines}|${alloctype}|${overdraft}"}{"${activationdate}|${expirationdate}"}=$amount;
    $accounts{"${accountname}|${username}|${allowmachines}|${alloctype}|${overdraft}"}{"${activationdate}|${expirationdate}"}+=$amount;
  }

  foreach my $account (keys %accounts)
  {
    my ($accountname,$username,$allowmachines,$alloctype,$overdraft) = split(/\|/, $account);

    # Create the new account
    my $request = new Gold::Request(object => "Account", action => "Create");
    my $name = $accountname;
    if ($username eq "ANY") { $name .= " for ANY"; }
    elsif ($username eq "RESERVE") { $name .= " for NONE"; }
    elsif ($username ne "KITTY") { $name .= " for $username"; }
    my $machines = $allowmachines;
    $machines =~ s/^://;
    $machines =~ s/:$//;
    $name .= " on $machines";
    $request->setAssignment("Name", $name); 
    print "Request: ", $request->toString() if $debug;
    my $response = $request->getResponse();
    print "Response: ", $response->toString() if $debug;
    &Gold::Client::displayResponse($response);

    # Obtain the allocation id just created
    my $id = $response->getDatumValue("Id");

    # Create AccountProject
    $request = new Gold::Request(object => "AccountProject", action => "Create");
    $request->setAssignment("Account", $id);
    $request->setAssignment("Name", $accountname);
    print "Request: ", $request->toString() if $debug;
    $response = $request->getResponse();
    print "Response: ", $response->toString() if $debug;
    &Gold::Client::displayResponse($response);

    # Create AccountUser
    $request = new Gold::Request(object => "AccountUser", action => "Create");
    $request->setAssignment("Account", $id);
    if ($username eq "KITTY")
    {
      $request->setAssignment("Name", "MEMBERS");
    }
    elsif ($username eq "RESERVE")
    {
      $request->setAssignment("Name", "NONE");
    }
    elsif ($username eq "ANY")
    {
      $request->setAssignment("Name", "ANY");
    }
    else
    {
      $request->setAssignment("Name", $username);
    }
    print "Request: ", $request->toString() if $debug;
    $response = $request->getResponse();
    print "Response: ", $response->toString() if $debug;
    &Gold::Client::displayResponse($response);

    # Create AccountMachines
    foreach my $machinename (split(/:/, $allowmachines))
    {
      next unless $machinename;

      # Create the new AccountMachine
      my $request = new Gold::Request(object => "AccountMachine", action => "Create");
      $request->setAssignment("Account", $id); 
      if ($machinename eq "ANY")
      {
        $request->setAssignment("Name", "ANY");
      }
      else
      {
        $request->setAssignment("Name", $machinename);
      }
      print "Request: ", $request->toString() if $debug;
      my $response = $request->getResponse();
      print "Response: ", $response->toString() if $debug;
      &Gold::Client::displayResponse($response);
    }

    # Create Allocations
    foreach my $allocation (keys %{$accounts{$account}})
    {
      my ($activationdate,$expirationdate) = split(/\|/, $allocation);
      my $amount = $accounts{$account}{$allocation};

      # Make a Deposit
      my $request = new Gold::Request(object => "Account", action => "Deposit");
      $request->setOption("Id", $id); 
      $request->setOption("StartTime", $activationdate); 
      $request->setOption("EndTime", $expirationdate); 
      $request->setOption("CreditLimit", $overdraft) if ($alloctype eq "Credit");
      $request->setOption("Amount", $amount); 
      print "Request: ", $request->toString() if $debug;
      my $response = $request->getResponse();
      print "Response: ", $response->toString() if $debug;
      &Gold::Client::displayResponse($response);
    }
  }

  print "Sleeping for 5 seconds...\n";
  sleep 5; 

  # Synchronize ChargeRates
  print "Synchronizing ChargeRates:\n";
  open CHARGERATES, "${QBANK_HOME}/bin/qbank get_chargerates|";
  foreach my $line (<CHARGERATES>)
  {
    chomp $line;
    my ($machinename,$chargetype,$chargename,$chargerate) = split(/\|/,$line);

    my $request = new Gold::Request(object => "ChargeRate", action => "Create");
    $request->setAssignment("Type", $chargetype); 
    $request->setAssignment("Name", $chargename); 
    $request->setAssignment("Rate", $chargerate); 
    print "Request: ", $request->toString() if $debug;
    my $response = $request->getResponse();
    print "Response: ", $response->toString() if $debug;
    &Gold::Client::displayResponse($response);
  }

  # Create ChargeRates
  print "Creating ChargeRates:\n";
  my $request = new Gold::Request(object => "ChargeRate", action => "Create");
  $request->setAssignment("Type", "Resource"); 
  $request->setAssignment("Name", "Processors"); 
  $request->setAssignment("Rate", 1); 
  print "Request: ", $request->toString() if $debug;
  my $response = $request->getResponse();
  print "Response: ", $response->toString() if $debug;
  &Gold::Client::displayResponse($response);

  # Depositmasks are not supported in Gold
  # Quotations cannot be translated since there are no chargerates stored
  # It is also not useful to translate reservations since it cannot be
  # determined which account a reservation should impinge againsts since
  # most of them specify KITTY for the username in QBank

  print "Synchronization Completed\n";
}

