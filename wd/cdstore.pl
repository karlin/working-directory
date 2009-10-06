#!/usr/bin/perl -w

if (@ARGV == 2) {
		$stodir = $ARGV[1];
		$stodir .= "\n";
		$slot = $ARGV[0];
} elsif (@ARGV == 1) {
		$stodir = `pwd`;
		$slot = $ARGV[0];
}

$wdfile = `$ENV{WDHOME}/wdscheme.pl`;
open(WDFILE, $wdfile);
@lines=<WDFILE>;
close WDFILE;

$lines[$slot] = $stodir;
open(WDFILEOUT, ">".$wdfile);
for $i (0..9) {
		print WDFILEOUT (($lines[$i]) ? $lines[$i] : "\n");
}
close WDFILEOUT;

