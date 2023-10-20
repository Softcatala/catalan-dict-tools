use strict;
use warnings;
use autodie;
use utf8;
use Switch;
require "../libs/Flexio.pm";

binmode( STDOUT, ":utf8" );

my $fitxer_afixos=$ARGV[1];
my $fitxer_diccionari=$ARGV[0];
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

#Llegeix exclusions
my $fitxer_exclusions ="../fdic-to-hunspell/dades/exclusions.txt";
my %exclusions = ();
open($fh,  "<:encoding(UTF-8)", $fitxer_exclusions );
my $fesexclusio=0;
my $formaolema="";
while (my $line = <$fh>) {
    if ($line =~ /^#EXCLOU (FORMA|LEMA) DE (.*)$/) {
	$formaolema = $1;
	my $mydiccionari =$2;
	if ($mydiccionari =~ /^(TOTS|tots|catalan|catalan-valencia)$/) { # fes exclusió
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

#Llegeix diccionari i escriu resultats
open(my $ofh,  ">:encoding(UTF-8)", $fitxer_eixida);
open($fh,  "<:encoding(UTF-8)", $fitxer_diccionari );
my $line = <$fh>; #ignora la primera línia
my $forma="";
my $postag="";
my $afixos="";
while ($line = <$fh>) {
    chomp ($line);
    if ($line =~/^(.+) (.+) (.+)$/) {
	$forma = $1;
	my $lema = $2;
	$postag = $3;
	if ($forma =~/^['-]/ || $forma =~/['-]$/) { next;}
	if (exists($exclusions{$forma})) {
	    if ( $exclusions{$forma} =~ /^(FORMA|LEMA)$/) {   #cas de Chiva/Xiva
		next;
	    }
	}	
	if (exists($exclusions{$lema})) {
	    if ( $exclusions{$lema} =~ /^LEMA$/) {
		next;
	    }
	}	

	#print $ofh "$forma\n";

	if ($postag =~ /^V.N.*$/) {
	    if ($forma =~ /[^e]$/) {
		$afixos="_C"; #infinitiu acabat en consonant
	    } else {
		$afixos="_D"; #infinitiu acabat en vocal
	    }
	    &aplica_afixos($forma, $afixos, $lema, $postag);
	    if (Flexio::apostrofa_masculi($forma)) {
		print $ofh "l'".$forma."\n";
		print $ofh "d'".$forma."\n";
		&aplica_afixos("l'".$forma, $afixos, $lema, $postag);
		&aplica_afixos("d'".$forma, $afixos, $lema, $postag);
	    }
	} elsif ($postag =~ /^V.G.*$/) {
	    $afixos="_C"; 
	    &aplica_afixos($forma, $afixos, $lema, $postag);
	} elsif ($postag =~ /^V.M.*$/) {
	    if ($forma =~ /[aeiï]$/) {
		$afixos="_D"; #imperatiu acabat en vocal: a, e, i, ï 
	    } else {
		$afixos="_C"; #imperatiu acabat en consonat o u
	    }
	    &aplica_afixos($forma, $afixos, $lema, $postag);
	} elsif ($postag =~ /^V.P.*$/) {
	    if (Flexio::apostrofa_masculi($forma)) {
		print $ofh "d'".$forma."\n";
		if ($postag =~ /^V.P.*SM.$/) {
		    print $ofh "l'".$forma."\n";
		}
	    }
	    if ($postag =~ /^V.P.*SF.$/ && Flexio::apostrofa_femeni($forma)) {
		print $ofh "l'".$forma."\n";
	    }
	} elsif ($postag =~ /^V.[SI].*$/ && Flexio::apostrofa_masculi($forma)) {
	    print $ofh "m'".$forma."\n";
	    print $ofh "t'".$forma."\n";
	    print $ofh "s'".$forma."\n";
	    print $ofh "l'".$forma."\n";
	    print $ofh "n'".$forma."\n";
	} elsif ($postag =~ /^[NA].*$/) {
	    if (Flexio::apostrofa_masculi($forma)) {
		print $ofh "d'".$forma."\n";
		if ($postag =~ /^(A..[MC][SN].|N.[MC][SN].*)$/) {
		    print $ofh "l'".$forma."\n";
		} elsif ($postag =~ /^(A..[FC][SN].|N.[FC][SN].*)$/ && Flexio::apostrofa_femeni($forma)) {
		    print $ofh "l'".$forma."\n";
		}

	    }
	} elsif ($postag =~ /^(RG.*|D[DI].*|PD0NS000|PI.*|PP3[MF][SP]000|SPS00)$/) {
	    if (Flexio::apostrofa_masculi($forma)) {
		print $ofh "d'".$forma."\n";
		if ($postag =~ /^RG$/) {
		    print $ofh "l'".$forma."\n";
		}
	    }
	}
    }
}
close ($fh);
close ($ofh);


sub aplica_afixos {
    my $paraula=$_[0];
    my $codiregla=$_[1];
    my $lema=$_[2];
    my $postag=$_[3]; 

    for $regla (@{$hashregles{$codiregla}}) {
	if ($regla =~ /^SFX $codiregla (.+) (.+) (.+)$/) {
	    my $forma=$paraula;
	    my $lleva=$1;
	    my $afegeix=$2;
	    my $condicio=$3;
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
		$forma =~ s/\/$//; # Elimina / al final 
		print $ofh "$forma\n";
	    }
	}
    }


}
