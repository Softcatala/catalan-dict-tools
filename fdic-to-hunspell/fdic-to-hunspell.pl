#!/bin/perl
use strict;
use warnings;
use autodie;
use utf8;

binmode( STDOUT, ":utf8" );

my $f1   = "../lt-to-fdic/verbs-fdic.txt";
my $out  = "verbs-hunspell.txt";
my $modelsdir = "../lt-to-fdic/models-verbals/";

my $regles = "regles.hunspell";

# Llegeix afixos 
open( my $fh,  "<:encoding(UTF-8)", $regles );
my $inregla = 0;
my @acabaen;
my @lleva;
my @afig;
my @afignet;

while (my $line = <$fh>) {
    chomp($line);
    if ($line =~ /^REGLA A /) {
	$inregla = 1;
    } elsif ($line =~ /^\/REGLA/) {
	$inregla = 0;
    } elsif ($inregla) {
	if ($line =~ /^(...)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s*/) {
	    push (@acabaen, $4);
	    push (@lleva, $2);
	    push (@afig, $3);
	    my $afig_net = $3;
	    $afig_net =~ s/\/.+$//; # aven/Z > aven
	    push (@afignet, $afig_net);
	}
    }
}
close ($fh);


open( $fh,  "<:encoding(UTF-8)", $f1 );
open( my $ofh, ">:encoding(UTF-8)", $out );
my %formes = ();
while (my $line = <$fh>) {
    chomp($line);

    if ($line =~ /^(.+ar)=categories:(.+?);model:(.+?);/) {
	my $infinitiu = $1;
	my $categoria = $2;
	my $model = $3;
	my $formabase = "";
	if ($infinitiu =~ /^(anar|estar|dar|donar)$/) {
	    next;
	}
	open( my $modelfh,  "<:encoding(UTF-8)", $modelsdir.$model.".model" );
	while (my $modelline = <$modelfh>) {
	    if ($modelline =~ /^(.+) (.+) (.+) (.+) #.*$/) {
		my $forma = $infinitiu;
		my $trau = $1;
		my $afegeix = $2;
		my $postag = $4;
		if ($forma =~ /^(.*)$trau$/) {
		    $forma = $1;
		}
		else {
		    print $ofh "ERROR ";
		}
		if ($afegeix !~ /^0$/) {
		    $forma .= $afegeix;
		}

		if ($postag =~ /VMII1S00/) {
		    $formabase = $forma;
		}
		if (!exists($formes{$forma})) {
		    $formes{$forma}="lt"; #existeix en LanguageTool
		}

		# print $ofh "$forma $infinitiu $postag\n";
	    }
	}
	close ($modelfh);
	# Crea les formes amb els afixos Hunspell i compara
	for my $i (0 .. $#acabaen)
	{
	    if ($formabase =~ /$acabaen[$i]$/) {
		my $forma = $formabase;
		$forma =~ s/$lleva[$i]$/$afignet[$i]/;
		if (exists($formes{$forma})) {
		    if ($formes{$forma} =~ /^lt/) {
			$formes{$forma}="lt-hunspell";
		    }
		} else {
		    $formes{$forma}="hunspell ".$lleva[$i]." ".$afig[$i]." ".$acabaen[$i];
		}

	    }
	}


	while ( my ($key, $value) = each(%formes) ) {
	    if ($formabase =~ /^aguava$/) {
		print $ofh "$key $value\n";
	    }
	    if ($value =~ /lt-hunspell/) {
		# Tot correcte
	    } elsif ($value =~ /^lt/) {
		# Falta en Hunspell
		print $ofh "$key/Z\n";
	    } elsif ($value =~ /^hunspell/) {
		# Falta en LT !!! Error.
		print $ofh "$key $value FALTA EN LT!!!\n";
	    }
	}
	print $ofh "$formabase/A\n";
	#Buida el hash
	for (keys %formes)
	{
	    delete $formes{$_};
	}

    }
}
close ($ofh);
close ($fh);
