use strict;
use warnings;
use autodie;
use utf8;
require "./libs/Flexio.pm";


my $fitxer_exclusions = $ARGV[0];
my $fitxer_diccionari = $ARGV[1];
my $fitxer_diccionari_eixida = $ARGV[2];
my %exclusions = ();
my $variant=$fitxer_diccionari;
$variant =~ s/^.+\/([^\/]+)\.dic/$1/;
#print "Variant: $variant\n";
open( my $fh,  "<:encoding(UTF-8)", $fitxer_exclusions );
my $fesexclusio=0;
my $formaolema="";
while (my $line = <$fh>) {
    if ($line =~ /^EXCLOU (FORMA|LEMA) DE (.*)$/) {
	$formaolema = $1;
	my $mydiccionari =$2;
	if ($mydiccionari =~ /^(TOTS|tots|$variant)$/) { # fes exclusió
	    $fesexclusio=1;
	} else {
	    $fesexclusio=0;
	}
    } elsif ($fesexclusio && $line =~ /^.+$/) {
	chomp ($line);
	$exclusions{$line}=$formaolema;
    }
}
close($fh);
#print "EXCLUSIONS:\n";
#foreach my $clau (keys %exclusions) {
#    print "$clau $exclusions{$clau}\n";
#}


open( $fh,  "<:encoding(UTF-8)", $fitxer_diccionari );
open( my $ofh,  ">:encoding(UTF-8)", $fitxer_diccionari_eixida );
LINE: while (my $line = <$fh>) {
    chomp($line);
    my $tetags=0;
    my $word="";
    if ($line =~/^(.+)\/.+$/) {
	$tetags=1;
	$word=$1;
    } elsif ($line =~/^(.+)\/?$/) {
	$tetags=0;
	$word=$1;
    }

    if (exists($exclusions{$word}) && $exclusions{$word}=~/LEMA/) { #Exemple: composar/.., esta/_Y
	$exclusions{$word}.=" EXCLUSIO_USADA"; #exclusió usada
#	print "exclusió usada: $word $exclusions{$word}\n";
	next LINE; #Exclou tot el lema;
    }
    if (exists($exclusions{$word}) && $exclusions{$word}=~/FORMA/ && !$tetags) { #Exemple: graben
	$exclusions{$word}.=" EXCLUSIO_USADA"; #exclusió usada
#	print "exclusió usada: $word $exclusions{$word}\n";
	next LINE; #Exclou la forma;
    }
    print $ofh "$line\n";

}
close($fh);

#Exclusions no usades
foreach my $clau (keys %exclusions) {
    if ($exclusions{$clau}=~/EXCLUSIO_USADA/) {
	next;
    }
    if ($exclusions{$clau}=~/FORMA/) { 
	print $ofh "$clau/x\n";
#	print "exclusió usada: $clau/x $exclusions{$clau}\n";
    }
    if ($exclusions{$clau}=~/LEMA/) { 
	print "ATENCIÓ: Exclusió no usada (possible error!): $clau\n";
    }
}


close($ofh);
