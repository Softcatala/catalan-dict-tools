use strict;
use warnings;
use autodie;
use utf8;

binmode( STDOUT, ":utf8" );


my $regles = $ARGV[0]; # paradigmes Apertium
my $dict_entrada=$ARGV[1];
my $dict_entrada2=$ARGV[2];

open( my $fh,  "<:encoding(UTF-8)", $regles );

my $inregla = 0;
my @regles;
my %nomsregles;
my $spfx;
my $regla ="";
while (my $line = <$fh>) {
    chomp($line);
    if ($line =~ /<pardef n="(.*_n)".*>/) {
        $regla = $1;
        #$spfx =$2;
        $inregla = 1;
        my $sufix = "";
        if ($regla =~ /\/(.*)__n/) {
            $sufix = $1;
        }
        $nomsregles{$regla} = $sufix;
    } elsif ($line =~ /^<\/pardef>/) {
        $inregla = 0;
    } elsif ($inregla) {
        if ($line =~ /<e(.*?)>.*?<p><l>(.*?)<\/l>.*<r>(.*?)(<.*>)<\/r><\/p><\/e>/) {
            my $etiquetes=$4;
            my $lleva=$3;
            my $afig=$2;
            my $nombre = "S";
            if ($etiquetes =~ /"pl"/) { $nombre= "P";}
            if ($etiquetes =~ /"sp"/) { $nombre= "N";}
            my $genere = "M";
            if ($etiquetes =~ /"mf"/) { $genere= "C";}
            if ($etiquetes =~ /"f"/) { $genere= "F";}
            my $categoria = "NC";
            #if ($etiquetes =~ /"sup"/) { $categoria= "AQA";}
            my $postag= $categoria.$genere.$nombre."000";
            push (@regles, "$regla $postag $afig");
            
        }
    }
}
close ($fh);

@regles = sort @regles;

my %regles_unalinia;

my $linia = "";
my $nomregla = "";
my $prevnomregla = "-1";
for my $linia_regla (@regles) {     
    if ($linia_regla =~ /(.*) (.*) (.*)/) {
        $nomregla = $1; 
        my $postag = $2;
        my $afig = $3;
        if ($nomregla !~ /^$prevnomregla$/) {
            $regles_unalinia{$prevnomregla} = $linia;
            # Comença nou adjectiu
            $linia = "$postag <r>$afig";
        } else {
            $linia = $linia." $postag <r>$afig";
        }
        $prevnomregla = $nomregla;
    }
}
$regles_unalinia{$prevnomregla} = $linia;



my %dict1;
my %dict1_regla;
open($fh,  "<:encoding(UTF-8)", $dict_entrada );
while (my $line = <$fh>) {
    chomp($line);
    
    if ($line =~ /<e lm="(.*)".*>.*<i>(.*)<\/i><par n="(.*__n)"\/><\/e>/) {
        my $lema=$1;
        my $nomregla=$3;
        my $arrel=$2;

        my $flexio_ap = $regles_unalinia{$nomregla};
        $flexio_ap =~ s/<r>/$arrel/g;
        $dict1{$lema} = $flexio_ap;
        $dict1_regla{$lema} = $nomregla;
    }
}
close ($fh);

my %dict2;
open($fh,  "<:encoding(UTF-8)", $dict_entrada2 );
while (my $line = <$fh>) {
    chomp($line);
    
    if ($line =~ /<e lm="(.*)".*>.*<i>(.*)<\/i><par n="(.*__n)"\/><\/e>/) {
        my $lema=$1;
        my $nomregla=$3;
        my $arrel=$2;
        if (exists $dict1{$lema}) {
            if (exists $regles_unalinia{$nomregla}) {
                my $flexio_ap = $regles_unalinia{$nomregla};
                $flexio_ap =~ s/<r>/$arrel/g;
                if ( $dict1{$lema} !~ /^$flexio_ap$/) {
                    print "APERTIUM: $lema FORMES: $dict1{$lema} $dict1_regla{$lema}\n";
                    print "SOFTCATA: $lema FORMES: $flexio_ap $nomregla\n\n";
                }
            } else {
                print "No existeix regla: $nomregla per al lema $lema.\n\n";
            }    
        }
    }
}
close ($fh);

