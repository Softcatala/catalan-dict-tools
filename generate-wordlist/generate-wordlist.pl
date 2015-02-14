use strict;
use warnings;
use autodie;
use utf8;
use Switch;
#require "libs/Flexio.pm";

binmode( STDOUT, ":utf8" );

my $fitxer_afixos=$ARGV[0];
my $fitxer_diccionari=$ARGV[1];
my $fitxer_eixida=$ARGV[2];

#Llegeix afixos
my $regles = [];
my %hashregles;
my %hashrecombinable;
my $regla ="";
my $numtotal=0;
my $num=0;
open( my $fh,  "<:encoding(UTF-8)", $fitxer_afixos );
while (my $line = <$fh>) {
    chomp($line);
    $line =~ s/\r//g;
    if ($line =~ /^([SP]FX) (..) (.+) (.+) (.+)$/) {
	$regla = $line;
	my $codiregla = $2;
	my $afegeix=$4;
	if ($afegeix !~ /^[Ss]'.*$/) {  #Elimina l'article salat
	    push (@$regles, $regla);
	}
	$num++;
	if ($num==$numtotal) {
	    $hashregles{$codiregla}= $regles;
	}
    } elsif ($line =~ /^[SP]FX (..) ([YN]) (\d+)$/) {
	$regles = [];
	$hashrecombinable{$1}=$2; 
	$numtotal = $3;
	$num=0;
    } 
}
close ($fh);

#Llegeix diccionari i escriu resultats
open(my $ofh,  ">:encoding(UTF-8)", $fitxer_eixida);
open($fh,  "<:encoding(UTF-8)", $fitxer_diccionari );
my $line = <$fh>; #ignora la primera línia
my $paraula="";
while ($line = <$fh>) {
    chomp ($line);
    $line =~ s/\r//g;
    if ($line =~/^(.+)\/(.+)$/) {
	$paraula = $1;
	print $ofh "$paraula\n";
	my $toteslesreglesaaplicar=$2;
#	print "$paraula\n";
	if ($toteslesreglesaaplicar =~ /ZZ/) {
	    next;  #paraules que cal excloure
	}
	my @regles_a_aplicar = unpack("(A2)*", $toteslesreglesaaplicar);
	for my $reglaaaplicar (@regles_a_aplicar) {
	    #print $ofh "$paraula $reglaaaplicar\n";
	    my $restaregles = "";
	    if ($hashrecombinable{$reglaaaplicar} =~ /^Y$/ && length($toteslesreglesaaplicar)>=4) {
		$restaregles = $toteslesreglesaaplicar;
		$restaregles =~ s/$reglaaaplicar//;
	    }
	    for $regla (@{$hashregles{$reglaaaplicar}}) {
		# print $ofh "$regla\n";
		if ($regla =~ /^SFX $reglaaaplicar (.+) (.+) (.+)$/) {
		    #print $ofh "$regla\n";
		    my $lleva=$1;
		    my $afegeix=$2;
		    my $condicio=$3;
		    my $forma=$paraula;
		    if ($afegeix =~ /^0$/) {
			$afegeix="";
		    }
		    if ($afegeix =~ /^0(\/.*)$/) {
			$afegeix=$1;
		    }
		    if ($paraula =~ /$condicio$/) {
			if ($lleva !~ /^0$/) {
			    $forma =~ s/$lleva$/$afegeix/;
			} else {
			    $forma .= $afegeix;
			}
			if ($restaregles =~ /../) {
			    if ($forma !~ /\//) {$forma .= "/"; }
			    $forma .= $restaregles;
			}
			$forma =~ s/\/$//; # Elimina / al final 
			print $ofh "$forma\n";
		    }
		}
		if ($regla =~ /^PFX $reglaaaplicar (.+) (.+) (.+)$/) {
		    #print $ofh "$regla\n";
		    my $lleva=$1;
		    my $afegeix=$2;
		    my $condicio=$3;
		    my $forma=$paraula;
		    if ($afegeix =~ /^0$/) {
			$afegeix="";
		    }
		    if ($afegeix =~ /^0(\/.*)$/) {
			$afegeix=$1;
		    }
		    if ($paraula =~ /^$condicio/) {
			if ($lleva !~ /^0$/) {
			    $forma =~ s/^$lleva/$afegeix/;
			} else {
			    $forma = $afegeix . $forma ;
			}
			if ($restaregles =~ /../) {
			    if ($forma !~ /\//) {$forma .= "/"; }
			    $forma .= $restaregles;
			}
			$forma =~ s/\/$//; # Elimina / al final 
			print $ofh "$forma\n";
		    }
		}

	    }
	}

    } elsif ($line =~/^(.+)\/?$/) {
	$paraula=$1;
	chomp($paraula);
	print $ofh "$paraula\n";
    }
}
close ($fh);
close ($ofh);
