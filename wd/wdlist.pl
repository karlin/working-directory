#!/usr/bin/perl -w
open(WDFILE, `$ENV{WDHOME}/wdscheme.pl`);
while(<WDFILE>) {
		$n = $. - 1;
		if ($n < 10) {
				print "$n $_";
		}
}
close WDFILE;
