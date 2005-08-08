#! /usr/bin/perl -wT
################################################################################
#
# Gold Service Directory object
#
# File   :  ServiceDirectory.pm
# History:  25 MAR 2005 [Scott Jackson] initial implementation
#
################################################################################
#                                                                              #
#                              Copyright (c) 2005                              #
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

Scott Jackson, Scott.Jackson@pnl.gov

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
  my $addLocation = "<add-location><location component=\"allocation-manager\" host=\"$serverHost\" port=\"$serverPort\" protocol=\"SSSRMAP\"/></add-location>";
  if ($log->is_debug())
  {
    $log->debug("Registering with the service directory ($serviceDirectoryHost:$serviceDirectoryPort): $addLocation");
  }

  # Create the socket to the service directory
  my $socket = IO::Socket::INET->new("$serviceDirectoryHost:$serviceDirectoryPort") or throw Gold::Exception("200", "Connection to service directory failed: $!");

  # Service Directory uses challenge protocol
  # Read in the challenge string
  my $challenge = "";
#  while (1) 
#  {
#    my $bytes_read = sysread($socket, my $byte, 1);
#    if (defined($bytes_read))
#    {
#      if ($bytes_read == 1)
#      {
#        if ($byte eq "\n")
#        {
#          last;
#        }
#        else
#        {
#          $challenge .= $byte;
#        }
#      }
#      else
#      {
#        throw Gold::Exception("246", "Unexpected end of file while reading challenge from service directory: $!");
#      }
#    }
#    else
#    {
#      throw Gold::Exception("226", "Error reading from service directory: $!");
#    }
#  }
  if ($challenge = <$socket>)
  {
    chomp($challenge);
  }
  else
  {
    throw Gold::Exception("246", "Error while reading challenge from service directory: $!");
  }
  if ($log->is_trace())
  {
    $log->trace("Read service directory challenge: $challenge");
  }
 
  # Append service directory key, and create a hex encoded md5 digest
  my $challengeResponse = md5_hex($challenge . $serviceDirectoryKey);

  # Send the challenge response to the service directory
  print $socket "$challengeResponse\n";
  $socket->flush();
  if ($log->is_trace())
  {
    $log->trace("Sent service directory challenge response: $challengeResponse");
  }

  # Read from the server whether the challenge succeeded or failed
  my $byte_read = read($socket, my $rc, 1);
  if ($rc != 1)
  {
    throw Gold::Exception("242", "Authentication with Service Directory failed: ($rc)");
  }
  if ($log->is_trace())
  {
    $log->trace("Read service directory challenge status: $rc");
  }

  # Write out int message length and a space delimiter
  print $socket length($addLocation) . " ";

  # Write out payload
  print $socket $addLocation;
  $socket->flush();
  if ($log->is_trace())
  {
    $log->trace("Sent service directory register request: $addLocation");
  }

  # Peel off response size
  my $responseSize = "";
  while (1) 
  {
    my $bytes_read = read($socket, my $byte, 1);
    if (defined($bytes_read))
    {
      if ($bytes_read == 1)
      {
        if ($byte eq " ")
        {
          last;
        }
        else
        {
          $responseSize .= $byte;
        }
      }
      else
      {
        throw Gold::Exception("246", "Unexpected end of file while reading response size from service directory: $!");
      }
    }
    else
    {
      throw Gold::Exception("226", "Error reading from service directory: $!");
    }
  }
  if ($log->is_trace())
  {
    $log->trace("Read service directory response size: $responseSize");
  }

  # Read in reply chunk
  my $bytes_remaining = $responseSize;
  my $payload = "";
  my $offset = 0;
  my $bytes_read = read($server, $payload, $bytes_remaining, $offset);
  if (defined($bytes_read))
  {
    $bytes_remaining -= $bytes_read;
    $offset += $bytes_read;
  }
  else
  {
    throw Gold::Exception("226", "Error reading response from service directory: $!");
  }
  if ($log->is_trace())
  {
    $log->trace("Read response from service directory: $payload");
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
  my $delLocation = "<del-location><location component=\"allocation-manager\" host=\"$serverHost\" port=\"$serverPort\" protocol=\"SSSRMAP\"/></del-location>";
  if ($log->is_debug())
  {
    $log->debug("Unregistering from the service directory ($serviceDirectoryHost:$serviceDirectoryPort): $delLocation");
  }

  # Create the socket to the service directory
  my $socket = IO::Socket::INET->new("$serviceDirectoryHost:$serviceDirectoryPort") or throw Gold::Exception("200", "Connection to service directory failed: $!");

  # Service Directory uses challenge protocol
  # Read in the challenge string
  my $challenge = "";
#  while (1) 
#  {
#    my $bytes_read = sysread($socket, my $byte, 1);
#    if (defined($bytes_read))
#    {
#      if ($bytes_read == 1)
#      {
#        if ($byte eq "\n")
#        {
#          last;
#        }
#        else
#        {
#          $challenge .= $byte;
#        }
#      }
#      else
#      {
#        throw Gold::Exception("246", "Unexpected end of file while reading challenge from service directory: $!");
#      }
#    }
#    else
#    {
#      throw Gold::Exception("226", "Error reading from service directory: $!");
#    }
#  }
  if ($challenge = <$socket>)
  {
    chomp($challenge);
  }
  else
  {
    throw Gold::Exception("246", "Error while reading challenge from service directory: $!");
  }
  if ($log->is_trace())
  {
    $log->trace("Read service directory challenge: $challenge");
  }
 
  # Append service directory key, and create a hex encoded md5 digest
  my $challengeResponse = md5_hex($challenge . $serviceDirectoryKey);

  # Send the challenge response to the service directory
  print $socket "$challengeResponse\n";
  $socket->flush();
  if ($log->is_trace())
  {
    $log->trace("Sent service directory challenge response: $challengeResponse");
  }

  # Read from the server whether the challenge succeeded or failed
  my $byte_read = read($socket, my $rc, 1);
  if ($rc != 1)
  {
    throw Gold::Exception("242", "Authentication with Service Directory failed: ($rc)");
  }
  if ($log->is_trace())
  {
    $log->trace("Read service directory challenge status: $rc");
  }

  # Write out int message length and a space delimiter
  print $socket length($addLocation) . " ";

  # Write out payload
  print $socket $delLocation;
  $socket->flush();
  if ($log->is_trace())
  {
    $log->trace("Sent service directory unregister request: $delLocation");
  }

  # Peel off response size
  my $responseSize = "";
  while (1) 
  {
    my $bytes_read = read($socket, my $byte, 1);
    if (defined($bytes_read))
    {
      if ($bytes_read == 1)
      {
        if ($byte eq " ")
        {
          last;
        }
        else
        {
          $responseSize .= $byte;
        }
      }
      else
      {
        throw Gold::Exception("246", "Unexpected end of file while reading response size from service directory: $!");
      }
    }
    else
    {
      throw Gold::Exception("226", "Error reading from service directory: $!");
    }
  }
  if ($log->is_trace())
  {
    $log->trace("Read service directory response size: $responseSize");
  }

  # Read in reply chunk
  my $bytes_remaining = $responseSize;
  my $payload = "";
  my $offset = 0;
  my $bytes_read = read($server, $payload, $bytes_remaining, $offset);
  if (defined($bytes_read))
  {
    $bytes_remaining -= $bytes_read;
    $offset += $bytes_read;
  }
  else
  {
    throw Gold::Exception("226", "Error reading response from service directory: $!");
  }
  if ($log->is_trace())
  {
    $log->trace("Read response from service directory: $payload");
  }

  return 0;
}

1;
