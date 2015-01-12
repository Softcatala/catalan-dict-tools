use strict;
use warnings;
use autodie;
use utf8;
require "libs/Flexio.pm";


my $fitxer_exclusions = $ARGV[0];
my $fitxer_diccionari = $ARGV[1];
my $fitxer_diccionari_eixida = $ARGV[2];
my %exclusions = ();
my $variant=$fitxer_diccionari;
$variant =~ s/^.+\/([^\/]+)\.dic/$1/;
print "Variant: $variant\n";
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
print "EXCLUSIONS:\n";
foreach my $clau (keys %exclusions) {
    print "$clau $exclusions{$clau}\n";
}


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

    if (exists($exclusions{$word}) && $exclusions{$word}=~/^LEMA$/) { #Exemple: composar/..
	$exclusions{$word}="USADA"; #exclusió usada
	print "exclusió usada: $word $exclusions{$word}\n";
	next LINE; #Exclou tot el lema;
    }
    if (exists($exclusions{$word}) && $exclusions{$word}=~/^FORMA$/ && !$tetags) { #Exemple: graben
	$exclusions{$word}="USADA"; #exclusió usada
	print "exclusió usada: $word $exclusions{$word}\n";
	next LINE; #Exclou la forma;
    }
    if (exists($exclusions{$word}) && $exclusions{$word}=~/^LEMA$/ && $tetags) { #Exemple: ??
	$exclusions{$word}="USADA"; #exclusió usada
	print "exclusió usada: $word/ZZ $exclusions{$word}\n";
	print $ofh "$word/ZZ\n";
    }

    print $ofh "$line\n";

}
close($fh);

#Exclusions no usades
foreach my $clau (keys %exclusions) {
    if ($exclusions{$clau}=~/^FORMA$/) { # És zero: exclusió de forma encara no usada
	print $ofh "$clau/ZZ\n";
	print "exclusió usada: $clau/ZZ $exclusions{$clau}\n";
    }
    if ($exclusions{$clau}=~/^LEMA$/) { # És u: exclusió de lema encara no usada, error
	print "Exclusió no usada (error!): $clau\n";
    }
}


close($ofh);
