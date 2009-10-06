#!/usr/bin/perl -w 
open(WDFILE, `$ENV{WDHOME}/wdscheme.pl`);
@lines=<WDFILE>;
close WDFILE;
$dir = $lines[$ARGV[0]];
if ($dir =~ /^\s*$/) {
		print ".";
} else {
		print $dir;
}
