#! /usr/bin/perl -wT
################################################################################
#
# Create a job quotation
#
# File   :  gquote
# History:  18 AUG 2003 [Scott Jackson] first implementation
#           29 JUL 2004 [Scott Jackson] perl alpha
#           9 SEP 2004 [Scott Jackson] beta mods
#           16 NOV 2004 [Scott Jackson] general release
#
################################################################################
#                                                                              #
#                           Copyright (c) 2003, 2004                           #
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
#     � Redistributions of source code must retain the above copyright         #
#     notice, this list of conditions and the following disclaimer.            #
#                                                                              #
#     � Redistributions in binary form must reproduce the above copyright      #
#     notice, this list of conditions and the following disclaimer in the      #
#     documentation and/or other materials provided with the distribution.     #
#                                                                              #
#     � Neither the name of Battelle nor the names of its contributors         #
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
use vars qw($log $verbose @ARGV %supplement $quiet $VERSION);
use lib qw (/usr/local/gold/lib /usr/local/gold/lib/perl5);
use Getopt::Long 2.24 qw(:config no_ignore_case);
use autouse 'Pod::Usage' => qw(pod2usage);
use Gold;

Main:
{
  $log->debug("Command line arguments: @ARGV");

  # Parse Command Line Arguments
  my ($help, $man, $user, $project, $machine, $disk, $memory, $procs, $qos, $time, $start, $end, $description, $guarantee, $version, %extensions);
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
    's=s' => \$start,
    'e=s' => \$end,
    'd=s' => \$description,
    'extension|X=s' => \%extensions,
    'guarantee' => \$guarantee,
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

  # No arguments are allowed
  pod2usage(2) if $#ARGV > -1;

  # Build request
  my $request = new Gold::Request(object => "Job", action => "Quote");
  Gold::Client::buildSupplements($request);
  my $job = new Gold::Datum("Job");
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
  $job->setValue("Description", $description) if defined $description; 
  foreach my $key (keys %extensions)
  {
    $job->setValue($key, $extensions{$key});
  }
  $request->setDatum($job); 
  $request->setOption("Guarantee", "True") if $guarantee;
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

gquote - create a job quotation

=head1 SYNOPSIS

B<gquote> [B<-p> <project name>] [B<-u> <user name>] [B<-m> <machine name>] [B<-P> <processors>] [B<-M> <memory>] [B<-D> <disk>] [B<-Q> <QOS>] [B<-t> <wallclock time>] [B<-s> <start time>] [B<-e> <end time>] [B<-d> <description>] [B<--extension|-X> <property>=<value>]* [B<--guarantee>] [B<--debug>] [B<-?>, B<--help>] [B<--man>] [B<--quiet>] [B<-v>, B<--verbose>] [B<-V>, B<--version>]

=head1 DESCRIPTION

B<gquote> is used to create a guaranteed job quote.

=head1 OPTIONS

=over 4

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

forecasted job start time in the format [YYYY-MM-DD[ hh:mm:ss]|-infinity|infinity|now]

=item B<-e> <end time>

forecasted job end time in the format [YYYY-MM-DD[ hh:mm:ss]|-infinity|infinity|now]

=item B<-d> <description>

explanatory message for the quote

=item B<--extension | -X> <property>=<value>

extension property. Any number of extra job properties may be specified with the quotation.

=item B<--guarantee>

guarantees the quote and returns a quote id to secure the current charge rates. This results in the creation of a quote record and a permanent job record. 

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

