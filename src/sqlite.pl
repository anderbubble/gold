#!/usr/bin/perl -wT

use strict;
use lib qw(/usr/local/gold/lib/perl5);
use DBI;

my $GOLD_HOME = "/usr/local/gold";
$ENV{PATH} = "/bin:/usr/bin";
delete @ENV{ 'IFS', 'CDPATH', 'ENV', 'BASH_ENV' }; 

my $dbh = DBI->connect("dbi:SQLite:dbname=${GOLD_HOME}/data/gold.db","","");
my $command = "";
print "SQLite> ";
while (<STDIN>)
{
	chomp;
	last if /^\s*qu?i?t?$/i;
	next if /^--/;
	next if /^\\/;
	next if /^\s*$/;
	$command .= $_;
	if (/;/)
	{
    print "$command\n" unless -t;
		my $sth = $dbh->prepare($command);
		my $rv = $sth->execute();
		if ($rv)
		{
			if ($command =~ /select/i)
			{
				$sth->dump_results(35, "\n", "|",);
			}
			else
			{
				print "$rv rows\n";
			}
		}
		else
		{
			print "WARN - '$_': ", $sth->errstr, "\n";
		}
		$command = "";
		print "SQLite> ";
	}
}


