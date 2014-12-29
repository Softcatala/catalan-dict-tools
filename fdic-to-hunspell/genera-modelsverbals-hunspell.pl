#!/bin/perl
use strict;
use warnings;
use autodie;
use utf8;
use Encode qw(decode);


binmode( STDOUT, ":utf8" );


my $modelsdir = "../lt-to-fdic/models-verbals/";
my @files = glob($modelsdir."*.model");
my $modelscount = 0;
my $afffile = "modelsverbals.aff";
open( my $ofh, ">:encoding(UTF-8)", $afffile );
foreach my $file (@files) {
    next if ($file !~ /\.model$/);
    $modelscount++;
    my $sufix= sprintf ("%02X", $modelscount);

    open( my $modelfh,  "<:encoding(UTF-8)", $file );
    my $infinitiu=decode("utf8",$file);
    $infinitiu =~ s/$modelsdir(.*)\.model/$1/;
    my @lines = <$modelfh>;
    my $numlines = @lines;
    close ($modelfh);
    print $ofh "# Model de conjugació: $infinitiu\n";
    print $ofh "SFX $sufix Y $numlines\n";
    open( $modelfh,  "<:encoding(UTF-8)", $file );
    while (my $modelline = <$modelfh>) {
	if ($modelline =~ /^(.+) (.+) (.+) (.+) #.*$/) {
	    my $trau = $1;
	    my $afegeix = $2;
	    my $condiciofinal = $3;
	    my $postag = $4;
	    my $afixos="";
	    my $forma=$infinitiu;
	    if ($forma =~ /^(.*)$trau$/) {
		$forma = $1;
	    }
	    else {
		print $ofh "!!!!ERROR en $forma\n";
	    }
	    if ($afegeix !~ /^0$/) {
		$forma .= $afegeix;
	    }
	    if ($postag =~ /^V.N.*$/) {
		if ($forma =~ /[^e]$/) {
		    $afixos="_C_Y_V"; #infinitiu acabat en consonant
		} else {
		    $afixos="_D_Y_V"; #infinitiu acabat en vocal
		}
	    } elsif ($postag =~ /^V.G.*$/) {
		$afixos="_C"; #gerundi
	    } elsif ($postag =~ /^V.P..SM.$/) {
		$afixos="_V_Y"; #participi MS
	    } elsif ($postag =~ /^V.P..SF.$/) {
		$afixos="_Y"; #participi FS **** Falta afegir l'apostrofació l' (_V) en la forma evitant les excepcions. 
	    } elsif ($postag =~ /^V.P..P..$/) {
		$afixos="_Y"; #participi P
	    } elsif ($postag =~ /^V.M.*$/) {
		if ($forma =~ /[aeiï]$/) {
		    $afixos="_D"; #imperatiu acabat en vocal: a, e, i, ï 
		} else {
		    $afixos="_C"; #imperatiu acabat en consonat o u
		}		
	    }
	    else {
		$afixos="_Z";
	    }
	    print $ofh "SFX $sufix $trau $afegeix/$afixos $condiciofinal\n";
	}
    }
    close ($modelfh);

}

close ($ofh);
