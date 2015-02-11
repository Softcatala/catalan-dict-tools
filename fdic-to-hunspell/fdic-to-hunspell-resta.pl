use strict;
use warnings;
use autodie;
use utf8;
use Switch;
require "libs/Flexio.pm";

binmode( STDOUT, ":utf8" );


my $diccionariarrel = $ARGV[0]."/";
my @files = glob($diccionariarrel."*-lt.txt");

my $outputfile = $ARGV[1]; #"resta-mots.dic";
open( my $ofh,  ">:encoding(UTF-8)", $outputfile );

foreach my $file (@files) {
    open( my $fh,  "<:encoding(UTF-8)", $file );
    LINE: while (my $line = <$fh>) {
	if ($line =~ /^(.+) (.+) (.+)$/) {
	    my $forma = $1;
	    if ($forma =~ /^['-]|['-]$/) { next LINE; }
	    my $lema = $2;
	    my $postag = $3;
	    my $apostrofacions="";
	    # apostrofa d'
	    if ($postag =~ /^(RG.*|NP.*|D[DI].*|PD0NS000)$/) {
		if (Flexio::apostrofa_masculi($forma)) {
		    $apostrofacions.="_Y";
		}
	    }
	    if ($forma =~ /^(ell|ells|ella|elles|entre)$/) {
		    $apostrofacions.="_Y";
	    }
            # apostrofa el > l'
	    if ($postag =~ /^(NP[CM][SN].*|RG)$/) {
		if (Flexio::apostrofa_masculi($forma)) {
		    $apostrofacions.="_V";
		}
	    }
	    if ($forma =~ /^(un|una)$/) {
		if (Flexio::apostrofa_masculi($forma)) {
		    $apostrofacions.="_V";
		}
	    }
	    # apostrofa la > l'
	    if ($postag =~ /^(NPF[SN].*)$/) {
		if (Flexio::apostrofa_femeni($forma)) {
		    $apostrofacions.="_V";
		}
	    }
	    $apostrofacions =~ s/^(.+)$/\/$1/;
	    print $ofh "$forma$apostrofacions\n";
	}
    }
    close ($fh);
}
close ($ofh);
