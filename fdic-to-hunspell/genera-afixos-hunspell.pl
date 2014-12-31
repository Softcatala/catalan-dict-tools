use strict;
use warnings;
use autodie;
use utf8;


# Llegeix afixos 
my $regles = "regles.hunspell";
my $fitxereixida = "afixos-no-verbs.aff";
open( my $ofh,  ">:encoding(UTF-8)", $fitxereixida );
open( my $fh,  "<:encoding(UTF-8)", $regles );
my $inregla = 0;
my @regles;
my $spfx;
my $regla ="";
my $combina ="";
my $compta = 0;
while (my $line = <$fh>) {
    chomp($line);
    if ($line =~ /^REGLA (_[EIiGFBHJKLCDYVWZ]) ([SP]FX)(\+?) /) {
	$regla = $1;
	$spfx =$2;
	$inregla = 1;
	$combina = $3;
	$combina =~ s/^$/N/;
	$combina =~ s/^\+$/Y/;
    } elsif ($line =~ /^\/REGLA/ && $inregla) {
	print $ofh "$spfx $regla $combina $compta\n";
	for my $liniaregla (@regles) {
	    print $ofh "$liniaregla\n";
	}
	undef @regles;
	$inregla = 0;
	$compta = 0;
    } elsif ($inregla) {
	if ($line =~ /^(...)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s*/) {
	    $compta++;	
	    push (@regles, "$spfx $regla $2 $3 $4");
	}
    }
}
close ($fh);
close ($ofh);
