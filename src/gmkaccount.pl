#! /usr/bin/perl -wT
################################################################################
#
# Create a new account
#
# File   :  gmkaccount
# History:  29 JUL 2004 [Scott Jackson] perl alpha
#           27 OCT 2004 [Scott Jackson] beta mods
#           16 NOV 2004 [Scott Jackson] general release
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
use vars qw($log $verbose @ARGV %supplement $quiet $VERSION);
use lib qw (/usr/local/gold/lib /usr/local/gold/lib/perl5);
use Getopt::Long 2.24 qw(:config no_ignore_case);
use autouse 'Pod::Usage' => qw(pod2usage);
use Gold;

Main:
{
  $log->debug("Command line arguments: @ARGV");

  # Parse Command Line Arguments
  my ($help, $man, $name, $description, $machines, $projects, $users, $version, %extensions);
  GetOptions
  (
    'n=s' => \$name,
    'p=s' => \$projects,
    'u=s' => \$users,
    'm=s' => \$machines,
    'extension|X=s' => \%extensions,
    'd=s' => \$description,
    'debug' => \&Gold::Client::enableDebug,
    'help|?' => \$help,
    'man' => \$man,
    'quiet' => \$quiet,
    'verbose|v' => \$verbose,
    'set' => \&Gold::Client::parseSupplement,
    'where' => \&Gold::Client::parseSupplement,
    'option' => \&Gold::Client::parseSupplement,
    'version|V' => \$version,
  ) or pod2usage(2);

  # Display usage if necessary
  pod2usage(0) if $help;
  if ($man)
  {
    if ($< == 0) # Cannot invoke perldoc as root
    {
      my $id = eval { getpwnam("nobody") };
      $id = eval { getpwnam("nouser") } unless defined $id;
      $id = -2 unless defined $id;
      $< = $id;
    }
    $> = $<; # Disengage setuid
    $ENV{PATH} = "/bin:/usr/bin"; # Untaint PATH
    delete @ENV{ 'IFS', 'CDPATH', 'ENV', 'BASH_ENV' };
    if ($0 =~ /^([-\/\w\.]+)$/) { $0 = $1; } # Untaint $0
    else { die "Illegal characters were found in \$0 ($0)\n";  }
    pod2usage(-exitstatus => 0, -verbose => 2);
  }

  # Display version if requested
  if ($version)
  {
    print "Gold version $VERSION\n";
    exit 0;
  }

  # No arguments are allowed
  pod2usage(2) if $#ARGV > -1;

  # Create the account

  # Build request
  my $request = new Gold::Request(object => "Account", action => "Create");
  $request->setAssignment("Name", $name) if defined $name; 
  $request->setAssignment("Description", $description) if defined $description; 
  foreach my $key (keys %extensions)
  {
    $request->setAssignment($key, $extensions{$key});
  }
  Gold::Client::buildSupplements($request);
  $log->info("Built request: ", $request->toString());

  # Obtain Response
  my $response = $request->getResponse();

  # Obtain the account id just created
  my $account = $response->getDatumValue("Id");
  if ($response->getStatus() eq "Success")
  {
    $response->setMessage("Successfully created Account $account");
  }

  # Print out the response
  &Gold::Client::displayResponse($response);

  # On success add members to the account
  if ($response->getStatus() ne "Failure")
  {
    my %created = ();

    # Add project members
    if (defined $projects)
    {
      foreach my $project (split(/,/, $projects))
      {
        $project = $2 if $project =~ /(-|\+)?([\S ]+)/;
        my $deny = ($1 eq "-") ? 1 : 0 if $1;

        # Build request
        my $request = new Gold::Request(object => "AccountProject", action => "Create");
        $request->setAssignment("Account", $account);
        $request->setAssignment("Name", $project);
        $request->setAssignment("Access", "False") if $deny;
        $log->info("Built request: ", $request->toString());

        # Obtain Response
        my $response = $request->getResponse();
        if ($response->getStatus() eq "Success")
        {
          $created{Project} = 1;
        }
        else
        {
          &Gold::Client::displayResponse($response);
        }
      }
    }

    # Add user members
    if (defined $users)
    {
      foreach my $user (split(/,/, $users))
      {
        $user = $2 if $user =~ /(-|\+)?([\S ]+)/;
        my $deny = ($1 eq "-") ? 1 : 0 if $1;

        # Build request
        my $request = new Gold::Request(object => "AccountUser", action => "Create");
        $request->setAssignment("Account", $account);
        $request->setAssignment("Name", $user);
        $request->setAssignment("Access", "False") if $deny;
        $log->info("Built request: ", $request->toString());

        # Obtain Response
        my $response = $request->getResponse();
        if ($response->getStatus() eq "Success")
        {
          $created{User} = 1;
        }
        else
        {
          &Gold::Client::displayResponse($response);
        }
      }
    }

    # Add machine members
    if (defined $machines)
    {
      foreach my $machine (split(/,/, $machines))
      {
        $machine = $2 if $machine =~ /(-|\+)?([\S ]+)/;
        my $deny = ($1 eq "-") ? 1 : 0 if $1;

        # Build request
        my $request = new Gold::Request(object => "AccountMachine", action => "Create");
        $request->setAssignment("Account", $account);
        $request->setAssignment("Name", $machine);
        $request->setAssignment("Access", "False") if $deny;
        $log->info("Built request: ", $request->toString());

        # Obtain Response
        my $response = $request->getResponse();
        if ($response->getStatus() eq "Success")
        {
          $created{Machine} = 1;
        }
        else
        {
          &Gold::Client::displayResponse($response);
        }
      }
    }

    # Provide defaults for entity types not specified
    foreach my $type ( "Project", "User", "Machine" )
    {
      unless ($created{$type})
      {
        # Build request
        my $request = new Gold::Request(object => "Account".$type, action => "Create");
        $request->setAssignment("Account", $account);
        $request->setAssignment("Name", "ANY"); 
        $log->info("Built request: ", $request->toString());

        # Obtain Response
        my $response = $request->getResponse();

        if ($response->getStatus() ne "Success")
        {
          &Gold::Client::displayResponse($response);
        }
      }
    }
  }

  # Exit with status code
  my $code = $response->getCode();
  $log->info("$0 (PID $$) Exiting with status code ($code)");
  exit $code / 10;
}


##############################################################################

__END__

=head1 NAME

gmkaccount - create a new account

=head1 SYNOPSIS

B<gmkaccount> [B<-n> <account name>] [B<-p> <project name>[,<project name>]*] [B<-u> <user name>[,<user name>]*] [B<-m> <machine name>[,<machine name>]*] [B<-d> <description>] [B<-X | --extension> <property>=<value>]* [B<--debug>] [B<-?>, B<--help>] [B<--man>] [B<--quiet>] [B<-v>, B<--verbose>] [B<-V>, B<--version>]

=head1 DESCRIPTION

B<gmkaccount> is used to create new accounts. A new id is automatically generated for the account. It essentially creates a new container into which time-bounded credits valid toward a specific set of projects, users and machines can be later deposited and tracked.

=head1 OPTIONS

=over 4

=item B<-n> <account name>

account name

=item B<-p> [+|-]<project name>[,[+|-]<project name>]*

defines projects that share this account. The special projects ANY and NONE may be used. If this option is omitted the account will default to ANY project. More than one project can be specified by using a comma-separated list. The optional plus or minus signs can preceed each project to indicate whether it is included (+) or excluded (-). If no sign is specified, the project is included.

=item B<-u> [+|-]<user name>[,[+|-]<user name>]*

defines users that share this account. The special users ANY, MEMBERS and NONE may be used. If this option is omitted the account will default to ANY user. More than one user can be specified by using a comma-separated list. The optional plus or minus signs can preceed each user to indicate whether it is included (+) or excluded (-). If no sign is specified, the user is included.

=item B<-m> [+|-]<machine name>[,[+|-]<machine name>]*

defines machines that share this account. The special machines ANY, MEMBERS and NONE may be used. If this option is omitted the account will default to ANY machine. More than one machine can be specified by using a comma-separated list. The optional plus or minus signs can preceed each machine to indicate whether it is included (+) or excluded (-). If no sign is specified, the machine is included.

=item B<-d> <description>

account description

=item B<-X | --extension> <property>=<value>

extension property. Any number of extra field assignments may be specified.

=item B<--debug>

log debug info to screen

=item B<-? | --help>

brief help message

=item B<--man>

full documentation

=item B<--quiet>

suppress headers and success messages

=item B<-v | --verbose>

display modified objects

=item B<-V | --version>

display Gold package version

=back

=head1 AUTHOR

Scott Jackson, Scott.Jackson@pnl.gov

=cut

