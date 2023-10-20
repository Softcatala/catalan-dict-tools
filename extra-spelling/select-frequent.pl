#!/usr/local/bin/perl
use strict;
#use warnings;
use autodie;
use utf8;

binmode( STDOUT, ":utf8" );

my %concordanceDict;

open(my $fh,  "<:encoding(UTF-8)","concordance");
while (my $line = <$fh>) {
	chomp($line);
	$concordanceDict{$line} = 1;
	
	
}
close $fh;

open(my $ofh,  ">:encoding(UTF-8)","extra-spelling.txt");

open(my $fh,  "<:encoding(UTF-8)","extra-spelling-2.txt");
while (my $line = <$fh>) {
	chomp($line);
	my $lcWord = lc $line;
	if (exists $concordanceDict{$lcWord}) {
		print $ofh "$line\n";
	} 
}
close $fh;
close $ofh;
