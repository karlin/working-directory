#!/usr/bin/perl -w
$MAXLINES = 10;
$wdscheme = $ENV{WDSCHEME};
$wdhome = $ENV{WDHOME};
if (! $wdscheme || ! -f "$wdhome/$wdscheme.scheme" ) {
		$wdscheme = `cat $wdhome/currentscheme`;
		chomp $wdscheme;
}

$wdfile = "$wdhome/$wdscheme.scheme";
if ( ! -f "$wdfile" ) {
		print STDERR "wdscheme file $wdfile was missing.\nUsing default scheme.\n";
		$wdfile = "$wdhome/default.scheme";
		if ( ! -s $wdfile) {
				print STDERR "default scheme not found.\n";
				exit(1);
		}
		`echo 'default' > $wdhome/currentscheme`;

} 

# now pad newlines to $MAXLINES
$lines = `cat $wdfile | wc -l`;
if ($lines < $MAXLINES) {
		$pad = "\n"x($MAXLINES-$lines);
		system("echo '$pad' >> $wdfile");
}

print $wdfile;
