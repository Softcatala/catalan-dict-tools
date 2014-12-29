#!/bin/perl
use strict;
use warnings;
use autodie;
use utf8;

binmode( STDOUT, ":utf8" );

my $f1   = "../lt-to-fdic/verbs-fdic.txt";
my $out  = "verbs-hunspell.txt";
my $modelsdir = "../lt-to-fdic/models-verbals/";


my $modelsdir = "../lt-to-fdic/models-verbals/";
my @files = glob($modelsdir."*.model");
my $modelscount = 0;
my %sufixos = ();
#llegeix nom dels models i assigna sufix hexadeximal 01..9B
open( my $ofh, ">:encoding(UTF-8)", $afffile );
foreach my $file (@files) {
    next if ($file !~ /\.model$/);
    $modelscount++;
    my $sufix= sprintf ("%02X", $modelscount);
    my $infinitiu=decode("utf8",$file);
    $infinitiu =~ s/$modelsdir(.*)\.model/$1/;
    $sufixos{$infinitiu} = $sufix;
}


open( $fh,  "<:encoding(UTF-8)", $f1 );
open( my $ofh, ">:encoding(UTF-8)", $out );
my %formes = ();
while (my $line = <$fh>) {
    chomp($line);

#    if ($line =~ /^(.+)(er|er|ar)=categories:(.+?);model:(.+?);/) { #er|re
    if ($line =~ /^(.+)(er|re|ir|ar|r)=categories:(.+?);model:(.+?);/) { 
	my $infinitiu = $1.$2;
	my $terminacio = $2;
	my $categoria = $3;
	my $model = $4;
	my @entradesHunspell;
	
	print $ofh "$infinitiu/$sufixos{$infinitiu}\n";
    }
}

# |.*c?obrir|.*[tv]enir|pruir|.*imprimir|.*eixir|.*cosir|.*argüir|.*morir|.*fugir|.*dir|.*sortir|.*collir|.*dormir|ajupir|.*bullir|.*sentir|.*munyir|grunyir|funyir|punyir|retrunyir|tossir|.*cruixir|pudir|.*omplir|escopir
	if ($infinitiu =~ /^(anar|estar|dar|donar|poder|merèixer|desmerèixer|.*córrer|.*n[àé]ixer|saber|.*créixer|.*fer|.*voler|péixer|irèixer)$/) {
	    next;
	}
	open( my $modelfh,  "<:encoding(UTF-8)", $modelsdir.$model.".model" );
	my $incoatiu=0;
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
		} elsif ($terminacio =~ /^ir$/) { #3a conjugació
		    if ($postag =~ /VMIF1S00/) { push(@entradesHunspell, $forma."/M"); } #compartiré/MN
		    if ($incoatiu && ($postag =~ /VMIF1S00/)) { push(@entradesHunspell, $forma."/N"); } #compartiré/MN
		    if ($postag =~ /VMIP3S0./) { 
			if ($forma !~ /ix$/) { push(@entradesHunspell, $forma."/U"); } # cus/U, sent/U
			else {$incoatiu=1;}
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
