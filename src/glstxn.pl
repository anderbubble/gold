#! /usr/bin/perl -wT
################################################################################
#
# Query transactions
#
# File   :  glstxn
# History:  3 SEP 2003 [Scott Jackson] first implementation
#           29 JUL 2004 [Scott Jackson] perl alpha
#           27 OCT 2004 [Scott Jackson] beta mods
#           16 NOV 2004 [Scott Jackson] general release
#
################################################################################
#                                                                              #
#                           Copyright (c) 2003, 2004                           #
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
use vars qw($log $raw $time_division $verbose @ARGV %supplement $quiet $VERSION);
use lib qw (/usr/local/gold/lib /usr/local/gold/lib/perl5);
use Getopt::Long 2.24 qw(:config no_ignore_case);
use autouse 'Pod::Usage' => qw(pod2usage);
use Gold;

Main:
{
  $log->debug("Command line arguments: @ARGV");

  # Parse Command Line Arguments
  my ($help, $man, $txnid, $requestid, $start, $end, $object, $action, $name, $project, $machine, $user, $account, $jobid, $type, $actor, $show, $showHidden, $version, $hours, $allocation);
  $verbose = 1; # Always display query results
  GetOptions
  (
    'T=i' => \$txnid,
    'R=i' => \$requestid,
    's=s' => \$start,
    'e=s' => \$end,
    'O=s' => \$object,
    'A=s' => \$action,
    'i=i' => \$allocation,
    'a=i' => \$account,
    'n=s' => \$name,
    'p=s' => \$project,
    'm=s' => \$machine,
    'u=s' => \$user,
    'J=s' => \$jobid,
    'U=s' => \$actor,
    'show=s' => \$show,
    'showHidden' => \$showHidden,
    'debug' => \&Gold::Client::enableDebug,
    'help|?' => \$help,
    'man' => \$man,
    'quiet' => \$quiet,
    'raw' => \$raw,
    'hours|h' => \$hours,
    'get' => \&Gold::Client::parseSupplement,
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

  # Display currency in hours if requested
  if ($hours)
  {
    $time_division = 3600;
  }

  # No arguments are allowed
  pod2usage(2) if $#ARGV > -1;

  # Use a hard-coded selection list if no --show option specified
  unless ($show)
  {
    $show = $config->get_property("transaction.show", "Id,Object,Action,Actor,Name,Child,JobId,Amount,Delta,Account,Project,User,Machine,Allocation,Count,Description");
    if ($showHidden)
    {
      $show .= ",Details,CreationTime,ModificationTime,Deleted,RequestId,TransactionId";    }
  }

  # Build request
  my $request = new Gold::Request(object => "Transaction", action => "Query");
  Gold::Client::buildSupplements($request);
  $request->setCondition("CreationTime", $start, "GT") if defined $start; 
  $request->setCondition("CreationTime", $end, "LE") if defined $end; 
  $request->setCondition("TransactionId", $txnid) if defined $txnid; 
  $request->setCondition("RequestId", $requestid) if defined $requestid; 
  $request->setCondition("Object", $object) if defined $object; 
  $request->setCondition("Action", $action) if defined $action; 
  $request->setCondition("Name", $name) if defined $name; 
  $request->setCondition("Project", $project) if defined $project; 
  $request->setCondition("User", $user) if defined $user; 
  $request->setCondition("Machine", $machine) if defined $machine; 
  $request->setCondition("Account", $account) if defined $account; 
  $request->setCondition("Allocation", $allocation) if defined $allocation; 
  $request->setCondition("Actor", $actor) if defined $actor; 
  $request->setCondition("JobId", $jobid) if defined $jobid; 
  $request->setOption("ShowHidden", "True") if $showHidden;
  if (defined($show))
  {
    foreach my $selection (split(/,/, $show))
    {
      $request->setSelection($selection);
    }
  }
  $log->info("Built request: ", $request->toString());

  # Obtain Response
  my $response = $request->getResponse();

  # Print out the response
  &Gold::Client::displayResponse($response);

  # Exit with status code
  my $code = $response->getCode();
  $log->info("$0 (PID $$) Exiting with status code ($code)");
  exit $code / 10;
}


##############################################################################

__END__

=head1 NAME

glstxn - query transactions

=head1 SYNOPSIS

B<glstxn> [B<-O> <object>] [B<-A> <action>] [B<-n> <name>] [B<-U> <actor>] [B<-a> <account id>]  [B<-i> <allocation id>] [B<-u> <user name>] [B<-p> <project name>] [B<-m> <machine name>] [B<-J> <job id>] [B<-s> <start time>] [<-e> <end time>] [B<-T> <transaction id>] [B<-R> <request id>] [B<--show> <attribute name>[,<attribute name>]* [B<--showHidden>] [B<--raw>] [B<-h>, B<--hours>] [B<--debug>] [B<-?>, B<--help>] [B<--man>] [B<--quiet>] [B<-V>, B<--version>]

=head1 DESCRIPTION

B<glstxn> is used to display transaction information.

=head1 OPTIONS

=over 4

=item [B<-O>] <object>

displays only transactions performing actions on the given object type

=item [B<-A>] <action>

displays only transactions invoking the specified action

=item B<-n> <name>

displays only transactions on object instances of the given name or associations with the given parent name

=item B<-U> <actor>

displays only transactions invoked by the specified user

=item B<-a> <account id>

displays only transactions involving the specified account

=item B<-i> <allocation id>

displays only transactions logged against the specific allocation

=item B<-u> <user name>

displays only transactions involving the given user

=item B<-p> <project name>

displays only transactions involving the given project

=item B<-m> <machine name>

displays only transactions involving the given machine

=item B<-J> <job id>

displays only transactions affiliated with the given jobid

=item B<-s> <start time>

displays transactions occuring after the specified time in the format: [YYYY-MM-DD[ hh:mm:ss]|-infinity|infinity|now]

=item B<-e> <end time>

displays transactions occuring before the specified time in the format: [YYYY-MM-DD[ hh:mm:ss]|-infinity|infinity|now]

=item B<-T> <transaction id>

displays only transactions with the specified transaction id. A transaction occurs when an action is invoked on an object. A complex request may involve multiple transactions.

=item B<-R> <request id>

displays only transactions with the specified request id. A unique request id is associated with each request, while each request may be associated with more than one transaction.

=item B<--show> <attribute name>[,<attribute name>]*

displays only the specified attributes in the order listed. Valid attributes include: Id, Object, Action, Actor, Name, Child, Count, Details, Project, User, Machine, JobId, Amount, Delta, Account, Description, CreationTime, ModificationTime, Deleted, RequestId, TransactionId

=item B<--debug>

log debug info to screen

=item B<-? | --help>

brief help message

=item B<--raw>

raw data output format. Data will be displayed with pipe-delimited fields without headers for automated parsing.

=item B<-h | --hours>

display time-based credits in hours. In cases where the currency is measured in resource-seconds (like processor-seconds), the currency is divided by 3600 to display resource-hours.

=item B<--man>

full documentation

=item B<--quiet>

suppress headers and success messages

=item B<-V | --version>

display Gold package version

=back

=head1 AUTHOR

Scott Jackson, Scott.Jackson@pnl.gov

=cut

