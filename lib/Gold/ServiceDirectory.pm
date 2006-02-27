#! /usr/bin/perl -wT
################################################################################
#
# Gold Service Directory object
#
# File   :  ServiceDirectory.pm
# History:  25 MAR 2005 [Scott Jackson] initial implementation
#           25 AUG 2005 [Gary Skouson] Fixed this so it works.
#
#
################################################################################
#                                                                              #
#                              Copyright (c) 2005                              #
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

Gold::ServiceDirectory  ties Gold into SSS ServiceDirectory

=head1 DESCRIPTION

The B<Gold::ServiceDirectory> module ties Gold into the SSS Service Directory

=head1 METHODS

=over 4

=item $boolean = Gold::ServiceDirectory->register();

=item $boolean = Gold::ServiceDirectory->remove();

=back

=head1 EXAMPLES

use Gold::ServiceDirectory;

my $rc = Gold::ServiceDirectory->register();

my $rc = Gold::ServiceDirectory->remove();

=head1 REQUIRES

Perl 5.6

=head1 AUTHOR

Gary Skouson, Gary.Skouson@pnl.gov

=cut

##############################################################################

package Gold::ServiceDirectory;

use vars qw($log);
#use Compress::Zlib;
#use Crypt::CBC;
use Data::Properties;
#use Digest::SHA1;
#use Digest::HMAC;
use Digest::MD5 qw(md5_hex);
use Error qw(:try);
#use MIME::Base64;
use IO::Socket;
#use XML::LibXML;
use Gold::Exception;
use Gold::Global;
#use Gold::Message;
#use Gold::Request;
#use Gold::Response;
#use Gold::Reply;

#
#
#
sub challengeSend{
	my ($server, $port, $key, $msg) = @_;
	my $socket = IO::Socket::INET->new(PeerAddr => $server,
					   PeerPort => $port);
	unless(defined($socket)){
		close $socket;
		return(-1);
	}
#	print "Socket Opened...\n";
	#
	# Grab the challenge string from the socket
	#
#	print "Grabbing challenge...\n";
	my $challenge = <$socket>;
	chomp($challenge);
	unless(length($challenge)){
		close $socket;
		return(-1);
	}
#	print "Got '$challenge'\n";
	#
	# Send the hash of the appropriate response.
	#
	my $resp = md5_hex($challenge . $key);
	print $socket "$resp\n";
#	print "Sent response $resp\n";
	#
	# Check to see if we're in.
	#
	my $rc;
	my $bytes = read($socket, $rc, 1);
	unless($bytes || $rc == 1){
		#
		# Didn't make it.
		#
		close $socket;
		return(-1);
	}
	#
	# Build/send the message
	#
#	print "Sending Message '$msg'\n";
	my $len = length($msg);
	print $socket "$len $msg";

	#
	# See what they think about my request...
	#
	my $in;
	$len = "";
	while ($bytes = read($socket, $in, 1) && $in ne " "){
		$len .= $in;
	}
#	print "Looking for $len bytes\n";
	#
	# Grab the rest of the data...
	#
	$bytes = read($socket, $in, $len);
	#
	# Check to see if there's an error.
	#
#	print "Got $in for a response...\n";
	if ($in =~ /^.error/){
		close $socket;
		return(-1);
	}
	return(0);
}

# ----------------------------------------------------------------------------
# $boolean = register();
# ----------------------------------------------------------------------------

# Add location to the Service Directory
sub register
{
  my ($self) = @_;
  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  # Return false if Gold has not been configured to use the service directory
  if ($config->get_property("service.directory", $SERVICE_DIRECTORY) !~ /true/i)
  { 
    if ($log->is_debug())
    {
      $log->debug("Not registering with the service directory");
    }
    return 0;
  }

  my $serviceDirectoryHost = $config->get_property("service.directory.host", $SERVICE_DIRECTORY_HOST);
  my $serviceDirectoryPort = $config->get_property("service.directory.port", $SERVICE_DIRECTORY_PORT);
  my $serviceDirectoryKey = $config->get_property("service.directory.key", "foo");
  my $serverHost = $config->get_property("server.host", $SERVER_HOST);
  my $serverPort = $config->get_property("server.port", $SERVER_PORT);

  # Build XML Payload
  my $addLocation = "<add-location><location><component>allocation-manager</component><host>$serverHost</host><port>$serverPort</port><protocol>basic</protocol><schema_version>1234</schema_version><tier>1</tier></location></add-location> ";
  if ($log->is_debug())
  {
    $log->debug("Registering with the service directory ($serviceDirectoryHost:$serviceDirectoryPort): $addLocation");
  }
  my $ret = &challengeSend($serviceDirectoryHost, $serviceDirectoryPort, $serviceDirectoryKey, $addLocation);
  if ($ret){
      throw Gold::Exception("246", "Unexpected end of file while reading challenge from service directory: $!");
  }

  return 0;
}

# ----------------------------------------------------------------------------
# $boolean = remove();
# ----------------------------------------------------------------------------

# Remove location from the Service Directory
sub remove
{
  my ($self) = @_;
  if ($log->is_trace())
  {
    $log->trace("invoked with arguments: (" , join(', ',@_[1..$#_]) , ")");
  }

  # Return false if Gold has not been configured to use the service directory
  if ($config->get_property("service.directory", $SERVICE_DIRECTORY) !~ /true/i)
  { 
    if ($log->is_debug())
    {
      $log->debug("Not registering with the service directory");
    }
    return 0;
  }

  my $serviceDirectoryHost = $config->get_property("service.directory.host", $SERVICE_DIRECTORY_HOST);
  my $serviceDirectoryPort = $config->get_property("service.directory.port", $SERVICE_DIRECTORY_PORT);
  my $serviceDirectoryKey = $config->get_property("service.directory.key", "foo");
  my $serverHost = $config->get_property("server.host", $SERVER_HOST);
  my $serverPort = $config->get_property("server.port", $SERVER_PORT);

  # Build XML Payload
  my $delLocation = "<del-location><location><component>allocation-manager</component><host>$serverHost</host><port>$serverPort</port></location></del-location>";
  if ($log->is_debug())
  {
    $log->debug("Unregistering from the service directory ($serviceDirectoryHost:$serviceDirectoryPort): $delLocation");
  }

  my $ret = &challengeSend($serviceDirectoryHost, $serviceDirectoryPort, $serviceDirectoryKey, $delLocation);
  if ($ret){
      throw Gold::Exception("246", "Unexpected end of file while while unregistering: $!");
  }
  return 0;
}

1;
