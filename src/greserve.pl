#! /usr/bin/perl -wT
################################################################################
#
# Create a job reservation
#
# File   :  greserve
# History:  19 AUG 2003 [Scott Jackson] first implementation
#           29 JUL 2004 [Scott Jackson] perl alpha
#           9 SEP 2004 [Scott Jackson] beta mods
#           2 FEB 2005 [Scott Jackson] general release
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
use vars qw($log $verbose @ARGV %supplement $quiet $VERSION);
use lib qw (/usr/local/gold/lib /usr/local/gold/lib/perl5);
use Getopt::Long 2.24 qw(:config no_ignore_case);
use autouse 'Pod::Usage' => qw(pod2usage);
use Gold;

Main:
{
  $log->debug("Command line arguments: @ARGV");

  # Parse Command Line Arguments
  my ($help, $man, $user, $project, $machine, $disk, $memory, $procs, $qos, $time, $quote, $jobId, $start, $end, $description, $version, $replace, %extensions);
  GetOptions
  (
    'u=s' => \$user,
    'p=s' => \$project,
    'm=s' => \$machine,
    'D=s' => \$disk,
    'M=s' => \$memory,
    'P=s' => \$procs,
    'Q=s' => \$qos,
    't=s' => \$time,
    'q=i' => \$quote,
    's=s' => \$start,
    'e=s' => \$end,
    'J=s' => \$jobId,
    'd=s' => \$description,
    'extension|X=s' => \%extensions,
    'replace' => \$replace,
    'debug' => \&Gold::Client::enableDebug,
    'help|?' => \$help,
    'man' => \$man,
    'quiet' => \$quiet,
    'verbose|v' => \$verbose,
    'job' => \&Gold::Client::parseSupplement,
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

  # JobId must be specified
  if (! defined $jobId)
  {
    if ($#ARGV == 0) { $jobId = $ARGV[0]; }
    else { pod2usage(2); }
  }

  # Build request
  my $request = new Gold::Request(object => "Job", action => "Reserve");
  Gold::Client::buildSupplements($request);
  my $job = new Gold::Datum("Job");
  $job->setValue("JobId", $jobId); 
  $job->setValue("ProjectId", $project) if defined $project; 
  $job->setValue("UserId", $user) if defined $user; 
  $job->setValue("MachineName", $machine) if defined $machine; 
  $job->setValue("Processors", $procs) if defined $procs; 
  $job->setValue("Memory", $memory) if defined $memory; 
  $job->setValue("Disk", $disk) if defined $disk; 
  $job->setValue("QualityOfService", $qos) if defined $qos; 
  $job->setValue("WallDuration", $time) if defined $time; 
  $job->setValue("StartTime", $start) if defined $start; 
  $job->setValue("EndTime", $end) if defined $end; 
  $job->setValue("QuoteId", $quote) if defined $quote; 
  $job->setValue("Description", $description) if defined $description; 
  foreach my $key (keys %extensions)
  {
    $job->setValue($key, $extensions{$key});
  }
  $request->setDatum($job); 
  $request->setOption("Replace", "True") if $replace; 
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

greserve - create a job reservation

=head1 SYNOPSIS

B<greserve> [B<-p> <project name>] [B<-u> <user name>] [B<-m> <machine name>] [B<-P> <processors>] [B<-M> <memory>] [B<-D> <disk>] [B<-Q> <QOS>] [B<-t> <wallclock time>] [B<-s> <start time>] [B<-e> <end time>] [B<-q> <quote id>] [B<-d> <description>] [B<--extension|-X> <property>=<value>]* [B<--replace] [B<--debug>] [B<-?>, B<--help>] [B<--man>] [B<--quiet>] [B<-v>, B<--verbose>] [B<-V>, B<--version>] {[B<-J>] <job id>} 

=head1 DESCRIPTION

B<greserve> is used to create a job reservation.

=head1 OPTIONS

=over 4

=item [B<-J>] <job id>

specifies the job id

=item B<-p> <project name>

project name

=item B<-u> <user name>

user name

=item B<-m> <machine name>

machine name

=item B<-P> <processors>

number of processors

=item B<-M> <memory>

amount of memory

=item B<-D> <disk>

amount of disk

=item B<-Q> <QOS>

quality of service

=item B<-t> <wallclock time>

estimated wallclock time (in seconds)

=item B<-s> <start time>

reservation start time in the format: [YYYY-MM-DD[ hh:mm:ss]|-infinity|infinity|now]. Defaults to now if omitted.

=item B<-e> <end time>

reservation end time in the format: [YYYY-MM-DD[ hh:mm:ss]|-infinity|infinity|now]. Defaults to now + wallDuration if omitted.

=item B<-q> <quote id>

quote used to determine charge rates

=item B<-d> <description>

explanatory message for the reservation

=item B<--extension | -X> <property>=<value>

extension property. Any number of extra job properties may be specified with the reservation.

=item B<--replace>

If this option is specifed, similarly named reservations will be deleted before this reservation is created. The default action is to create a new reservation even if an existing reservation of the same name exists. This behavior supports systems that may reuse jobids or make incremental charges. The replace option should be specified if you want this reservation to replace existing reservations of the same name (associated with the same job).

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

