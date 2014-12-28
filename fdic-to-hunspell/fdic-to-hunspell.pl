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
my @regles;
my $spfx;
my $regla ="";
while (my $line = <$fh>) {
    chomp($line);
    if ($line =~ /^REGLA (.) ([SP]FX)/) {
	$regla = $1;
	$spfx =$2;
	$inregla = 1;
    } elsif ($line =~ /^\/REGLA/) {
	$inregla = 0;
    } elsif ($inregla) {
	if ($line =~ /^(...)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s*/) {
	    push (@regles, "$spfx $regla $2 $3 $4");
	}
    }
}
close ($fh);


open( $fh,  "<:encoding(UTF-8)", $f1 );
open( my $ofh, ">:encoding(UTF-8)", $out );
my %formes = ();
while (my $line = <$fh>) {
    chomp($line);

#    if ($line =~ /^(.+)(ar)=categories:(.+?);model:(.+?);/) { #er|re
    if ($line =~ /^(.+)(er|er|ar)=categories:(.+?);model:(.+?);/) { 
	my $infinitiu = $1.$2;
	my $terminacio = $2;
	my $categoria = $3;
	my $model = $4;
	my @entradesHunspell;
	if ($infinitiu =~ /^(anar|estar|dar|donar|poder|merèixer|desmerèixer|.*córrer|.*n[àé]ixer|saber|.*créixer|.*fer|.*voler|péixer|irèixer)$/) {
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
		if ($terminacio =~ /^ar$/) { # 1a conjugació
		    if ($postag =~ /VMII1S00/) { push(@entradesHunspell, $forma."/A"); } #cantava/A
		} elsif ($terminacio =~ /^(er|re)$/) { #2a conjugació
		    #if ($postag =~ /VMN00000/) { 
		#	if ($forma =~ /[aeiou]$/) { push(@entradesHunspell, $forma."/D"); } #batre/D
		#	else { push(@entradesHunspell, $forma."/C"); } #conèixer/C
		#    }
		    if ($postag =~ /VMII1S00/) { push(@entradesHunspell, $forma."/O"); } #batia/O
		    if ($postag =~ /VMIP3S00/) { push(@entradesHunspell, $forma."/S"); } #bat/O
		    if ($postag =~ /VMSI1S01/) { 
			if ($forma =~ /[qg]ués$/) { push(@entradesHunspell, $forma."/Q"); } #conegués/Q desmeresqués/Q
			else { push(@entradesHunspell, $forma."/P"); } #batés/P desmereixés/P
		    }
		    if ($postag =~ /VMG00000/) { push(@entradesHunspell, $forma."/R"); } #batent/R
		    if ($postag =~ /VMIF1S00/) { push(@entradesHunspell, $forma."/T"); } #batré/T
		    if ($postag =~ /VMP00SM0/) { 
			if ($forma =~ /ut$/) { push(@entradesHunspell, $forma."/B"); } #batut/B
			elsif ($forma =~ /et$/) { push(@entradesHunspell, $forma."/F"); } #estret/F
			else { push(@entradesHunspell, $forma."/J"); } #emès/J
		    }

		}

		if (!exists($formes{$forma})) {
		    $formes{$forma}="lt"; #existeix en LanguageTool
		}

		# print $ofh "$forma $infinitiu $postag\n";
	    }
	}
	close ($modelfh);
	# Crea les formes amb els afixos Hunspell i compara
	foreach (@entradesHunspell) {
	    print $ofh "$_\n";
	    $_ =~ /^(.+)\/(.)/;
	    my $formabase = $1;
	    my $lletraregla = $2;
	    for my $regla (@regles) {
		if ($regla =~ /^[SP]FX $lletraregla (.+) (.+) (.+)$/) {
		    my $acabaen = $3;
		    my $lleva = $1;
		    my $afig = $2;
		    my $afignet = $afig;
		    $lleva =~ s/0$//; # elimina 0
		    $afignet =~ s/\/.+$//;  # cantava/A > cantava
		    if ($formabase =~ /$acabaen$/) {
			my $forma = $formabase;
			if ($lleva =~ /.+/) {
			    $forma =~ s/$lleva$/$afignet/;
			} else {
			    $forma = $forma.$afignet;
			}
			if (exists($formes{$forma})) {
			    if ($formes{$forma} =~ /^lt/) {
				$formes{$forma}="lt-hunspell";
			    }
			} else {
			    #$formes{$forma}="hunspell ".$lleva." ".$afig." ".$acabaen;
			    $formes{$forma}="hunspell REGLA: ".$regla;
			}
		    }
		}
	    }
	}

	while ( my ($key, $value) = each(%formes) ) {
	    if ($value =~ /lt-hunspell/) {
		# Tot correcte
	    } elsif ($value =~ /^lt/) {
		# Falta en Hunspell
		print $ofh "$key/Z\n";       ### Però /C si és imperatiu!! O bé les dues coses.
		# Z si comença amb vocal, C infinitiu, gerundi, imperatiu??
	    } elsif ($value =~ /^hunspell/) {
		# Falta en LT !!! Error.
		print $ofh "$key $value FALTA EN LT!!!\n";
	    }
	}
	
	#Buida el hash
	for (keys %formes)
	{
	    delete $formes{$_};
	}
	@entradesHunspell = 0;
    }
}
close ($ofh);
close ($fh);
