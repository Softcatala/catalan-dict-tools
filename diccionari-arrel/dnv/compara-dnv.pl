#!/bin/perl
use strict;
use warnings;
use autodie;
use utf8;
binmode( STDOUT, ":utf8" );

my $lt_dict="/home/jaume/github/catalan-dict-tools/resultats/lt/diccionari.txt";
my $dnv_dict="/home/jaume/github/catalan-dict-tools/diccionari-arrel/dnv/LemesDNV.csv";

my %lt;
my %dnv;
open( my $lt_fh,  "<:encoding(UTF-8)", $lt_dict );
open( my $dnv_fh,  "<:encoding(UTF-8)", $dnv_dict );

#open( my $ofh, ">:encoding(UTF-8)", $out3 );

while ( my $line = <$lt_fh> ) {
    chomp($line);
    if ($line =~ /(.+) (.+) (.+)/) {
    	my $lemma = $1;
    	if (!exists $lt{$lemma}) {
    		$lt{$lemma}=1;
    	}
    }
}
#my $size = scalar keys %lt;
#print "El diccionari LT té ". $size . " formes\n";

while ( my $line = <$dnv_fh> ) {
    chomp($line);
    if ($line =~ /(.*);(.*);(.*);(.*);(.*);(.*);/) {
    	my $lemma = $1;
    	if (!exists $dnv{$lemma}) {
    		$dnv{$lemma}=1;
    	}
    	$lemma =~ s/^(.+)(-se|'s)$/$1/;
    	if (!exists $lt{$lemma} && $lemma !~ /^-/ && $lemma !~ /-$/) {
    		print $line . "\n";
    	}
    }
}
#$size = scalar keys %dnv;
#print "El diccionari DNV té ". $size . " lemes\n";

