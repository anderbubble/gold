#! /usr/bin/perl -wT
################################################################################
#
# Make a deposit
#
# File   :  gdeposit
# History:  22 AUG 2003 [Scott Jackson] first implementation
#           30 JUL 2004 [Scott Jackson] perl alpha
#           3 FEB 2005 [Scott Jackson] beta mods
#
################################################################################
#                                                                              #
#                        Copyright (c) 2003, 2004, 2005                        #
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
use vars qw($log $time_division $verbose @ARGV %supplement $quiet $VERSION);
use lib qw (/usr/local/gold/lib /usr/local/gold/lib/perl5);
use Getopt::Long 2.24 qw(:config no_ignore_case);
use autouse 'Pod::Usage' => qw(pod2usage);
use Gold;

Main:
{
  $log->debug("Command line arguments: @ARGV");

  # Parse Command Line Arguments
  my ($help, $man, $amount, $account, $description, $limit, $allocation, $endTime, $startTime, $callType, $version, $hours, $project);
  GetOptions
  (
    'z=i' => \$amount,
    'a=i' => \$account,
    'i=i' => \$allocation,
    's=s' => \$startTime,
    'e=s' => \$endTime,
    'L=i' => \$limit,
    'c=s' => \$callType,
    'd=s' => \$description,
    'p=s' => \$project,
    'hours|h' => \$hours,
    'debug' => \&Gold::Client::enableDebug,
    'help|?' => \$help,
    'man' => \$man,
    'quiet' => \$quiet,
    'verbose|v' => \$verbose,
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

  # Use sole remaining argument as amount if present
  if ($#ARGV == 0) { $amount = $ARGV[0]; }

  # Check for required arguments
  pod2usage(2) if ! defined $account && ! defined $project;

  # Convert hours to seconds if specified
  if ($hours)
  {
    $time_division = 3600;
    if (defined $amount)
    {
      $amount = $amount * 3600;
    }
    if (defined $limit)
    {
      $limit = $limit * 3600;
    }
  }

  # If project is specified, determine account id if unique
  # otherwise display a list of accounts to choose from
  if (defined $project)
  {
    # Query Accounts the project can charge to
    my $request = new Gold::Request(object => "Account", action => "Query");
    $request->setSelection("Id", "Sort");
    $request->setSelection("Name");
    $request->setCondition("Id", $account) if defined $account; 
    $request->setOption("Project", $project); 
    $request->setOption("UseRules", "True"); 
    $log->info("Built request: ", $request->toString());

    # Obtain Response
    my $response = $request->getResponse();
    my $count = $response->getCount();

    if (! defined $count || $count == 0)
    {
      # Display an error message and exit
      $response = new Gold::Response()->failure("There are no accounts for the specified project. Please respecify the deposit with a valid account id.");
      &Gold::Client::displayResponse($response);
      exit 74;
    }
    elsif ($count == 1)
    {
      # Deposit into the unique account
      $account = $response->getDatumValue("Id");
    }
    else
    {
      # Display a list of account names and break
      print "The specified project has multiple accounts. Please respecify the deposit with the appropriate account id.\n";
      $verbose = 1;
      &Gold::Client::displayResponse($response);
      exit 74;
    }
  }

  # Issue the deposit

  # Build request
  my $request = new Gold::Request(object => "Account", action => "Deposit");
  $request->setOption("Id", $account); 
  $request->setOption("Amount", $amount) if defined $amount; 
  $request->setOption("Allocation", $allocation) if defined $allocation; 
  $request->setOption("StartTime", $startTime) if defined $startTime; 
  $request->setOption("EndTime", $endTime) if defined $endTime; 
  $request->setOption("CreditLimit", $limit) if defined $limit; 
  $request->setOption("CallType", $callType) if defined $callType; 
  $request->setOption("Description", $description) if defined $description; 
  $request->setOption("ShowHours", "True") if defined $hours; 
  Gold::Client::buildSupplements($request);
  $log->info("Built request: ", $request->toString());

  # Obtain Response
  my $response = $request->getResponse();
  if (defined($project) && $response->getStatus() eq "Success")
  {
    my $count = $response->getCount();
    $response = new Gold::Response()->success($count, "Successfully deposited $count credits into project $project");
  }

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

gdeposit - issue a deposit

=head1 SYNOPSIS

B<gdeposit> {B<-a> <account id> | B<-p> <project name>} [B<-i> <allocation id>] [B<-s> <start time>] [B<-e> <end time>] [B<-L> <credit limit>] [B<-d> <description>] [B<-h>, B<--hours>] [B<--debug>] [B<-?>, B<--help>] [B<--man>] [B<--quiet>] [B<-v>, B<--verbose>] [B<-V>, B<--version>] [[B<-z>] <amount>]

=head1 DESCRIPTION

B<gdeposit> is used to make time-bounded deposits into existing accounts. Accounts must first be created using B<gmkaccount>.

=head1 OPTIONS

=over 4

=item B<-a> <account id>

the account into which the deposit will be made

=item B<-p> <project name>

if the project name is specified and there is exactly one account for the named project, a deposit will be made into that account. Otherwise, a list of accounts will be displayed for the specified project and you will be prompted to respecify the deposit against one of the enumerated accounts.

=item [B<-z>] <amount>

amount to deposit

=item B<-i> <allocation id>

specifies that the deposit should go into the specified allocation. This option is incompatible with the B<-L> option.

=item B<-s> <start time>

start time for the allocation to be credited in the format [YYYY-MM-DD[ hh:mm:ss]|-infinity|infinity|now]. The start time will default to -infinity.

=item B<-e> <end time>

end time for the allocation to be credited in the format [YYYY-MM-DD[ hh:mm:ss]|-infinity|infinity|now]. The end time will default to infinity.

=item B<-L> <credit limit>

if a credit limit is specified, a new allocation will be created with the specified credit limit. This option is incompatible with the B<-i> option.

=item B<-c> <call type>

Call types are used in support of distributed accounting for when multiple organizations are involved. This may be one of Normal, Back or Forward, with Normal being the default.

=item B<-d> <description>

reason for the deposit

=item B<-h | --hours>

treat currency as specified in hours. In systems where the currency is measured in resource-seconds (like processor-seconds), this option allows the amount and credit limit to be specified in resource-hours.

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

