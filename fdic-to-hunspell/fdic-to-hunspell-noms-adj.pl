use strict;
use warnings;
use autodie;
use utf8;
use Switch;
require "libs/Flexio.pm";

binmode( STDOUT, ":utf8" );

my $general=0; #Si és 1, versió "general" del corrector
if ( grep( /^-catalan$/, @ARGV ) ) {
  $general=1;
}

my $dir_entrada=$ARGV[0];
my $dir_eixida=$ARGV[1];

# Llegeix afixos 
my $regles = $ARGV[2]; #"regles.hunspell";
open( my $fh,  "<:encoding(UTF-8)", $regles );
my $inregla = 0;
my @regles;
my $spfx;
my $regla ="";
while (my $line = <$fh>) {
    chomp($line);
    if ($line =~ /^REGLA (_[EIiGFBHJKL]) ([SP]FX)/) {
	$regla = $1;
	$spfx =$2;
	$inregla = 1;
    } elsif ($line =~ /^\/REGLA/) {
	$inregla = 0;
    } elsif ($inregla) {
	if ($line =~ /^(...)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s*/) {
	    my $etiqueta=$1;
	    if (!($general && $etiqueta =~ /^2/)) {  #ignora les regles que generen accentuació valenciana
		push (@regles, "$spfx $regla $2 $3 $4");
	    }
	}
    }
}
close ($fh);


#my $arxiucategoria = $ARGV[0];  # adjectius, noms
my @categories = ('adjectius', 'noms');

for my $arxiucategoria (@categories) {

    my $f1   = $dir_entrada."/".$arxiucategoria."-fdic.txt";
    my $out  = $dir_eixida."/".$arxiucategoria.".dic";
    my $out2 = $dir_eixida."/"."mots_no_processats.txt";

    my $mot_masc;
    my $mot_fem;
    my $numAccepcio;
    my $tagbefore;
    my $tagafter;
    my $excepcions;

    open( $fh,  "<:encoding(UTF-8)", $f1 );
    open( my $ofh, ">:encoding(UTF-8)", $out );

    while ( my $line = <$fh> ) {
	chomp($line);
	my $categoria;
	my $found = 0;

	my $resultat="";
	
	#
	# A partir de dues formes, masculí i femení. Ex.: valencià -ana. 
	#
	
	if ( $line =~ /^($Flexio::carac+) ($Flexio::carac+)(.*)=categories: (.+?);/ ) {
	    $mot_masc=$1;
	    $excepcions=$3;
	    $categoria=$4;
	    
	    ($mot_fem, $found) = Flexio::desplega_femeni_amb_guionet($mot_masc, $2);

	    if (!$found) {
		print $ofh "***POSSIBLE ERROR*** $line\n";
		next;
	    }

	    $numAccepcio = "";
	    if ($mot_masc !~ /^(MP3|A[345]|goma-2)$/) { # Excepció: el número forma part del mot
		if ($mot_masc =~ /^(.+)([0-9])$/) {
		    $mot_masc = $1;
		    $numAccepcio = $2;
		}
	    }

	    my $fp="";
	    my $mp=""; my $ms2=""; my $mp2="";
	    my $fs2=""; my $fp2="";
	    
	    
	    $mp=Flexio::plural($mot_masc, "M");
	    if ($excepcions =~ /\[pl\. ([^ ]+)\]/ ) {
		$mp=$1;
	    }
	    elsif ($excepcions  =~ /\[pl\. (.+) o (.+)\]/ ) {
		$mp=$1;
		$mp2=$2;
	    }
	    # plural a partir del femení
	    elsif ($mot_masc =~ /.+([àéèíóòú]|[aàeéèiíoóòuú][sn]|ix)$/) {
		$mp=Flexio::pluralMasc_del_fem($mot_fem);
	    }
	    else {
		# dobles formes de plural
		if ($mp =~ /^(.+s)([tc])s$/ ) {
		    $mp2=$1.$2."os";
		}
		elsif ($mp =~ /^(.+xt)s$/ ) {
		    $mp2=$1."os";
		}     
		# roigs rojos
		elsif ($mp =~ /^(.+[aeou])igs$/ ) {
		    $mp2=$1."jos";
		}     
	    }


	    if ($excepcions  =~ /\[fem\. (.+)\]/ ) { #forma extra de femení
		$fs2=$1;
	    }
	    if ($excepcions  =~ /\[masc\. (.+)\]/ ) { #forma extra de masculí (bon)
		$ms2=$1;
	    }

	    $fp=Flexio::plural($mot_fem, "F"); 
	    #accentuació valenciana
	    if ($mot_masc =~ /^(.+)è([sn]?)$/ && !$general) {
		$ms2=$1."é".$2;
	    }
	    

	    #print "$mot_masc $mot_fem $mp $mp2 $fp\n";

	    #Imprimir formes etiquetades
	    $tagbefore = "";
	    $tagafter = "";
	    switch ($categoria) {
		case "MF" {  $tagbefore="NC"; $tagafter="000";}
		case "A" { $tagbefore="AQ0"; $tagafter="0";}
		case "AA" { $tagbefore="AQA"; $tagafter="0";}
		case "AO" { $tagbefore="AO0"; $tagafter="0";}
	    }


	    #print $ofh "$mot_masc $mot_masc$numAccepcio $tagbefore"."MS"."$tagafter\n";
	    $resultat.=$mot_masc;
	    if ( $ms2 =~ /.+/) {
		#print $ofh "$ms2 $mot_masc$numAccepcio $tagbefore"."MS"."$tagafter\n";
		$resultat.=" ".$ms2;
	    }
	    #print $ofh "$mot_fem $mot_masc$numAccepcio $tagbefore"."FS"."$tagafter\n";
	    $resultat.=" ".$mot_fem;
	    
	    $resultat.=" ".$mp;
	    if ( $mp2 =~ /.+/) {
		#print $ofh "$mp2 $mot_masc$numAccepcio $tagbefore"."MP"."$tagafter\n";
		$resultat.=" ".$mp2;
	    }
	    $resultat.=" ".$fp;
	    
	    # forma femenina extra
	    if ($fs2 =~ /.+/) {
		#print $ofh "$fs2 $mot_masc$numAccepcio $tagbefore"."FS"."$tagafter\n";
		$resultat.=" ".$fs2;
		$fp2=Flexio::plural($fs2,"F");
		$resultat.=" ".$fp2;
		#print $ofh "$fp2 $mot_masc$numAccepcio $tagbefore"."FP"."$tagafter\n";
	    }

	    # ?????
	    if ($mot_masc =~/^$mp$/ || $mot_fem =~/^$fp$/) {
		#print $ofh "***POSSIBLE ERROR*** $line\n";
		$resultat.=" ***POSSIBLE ERROR*** $line\n";
	    }
	    
	    my @lletresregla = ("_F","_B","_H", "_J", "_K", "_L");
	    my $trobat=0;
	    foreach my $lletraregla (@lletresregla) {
		if (&genera_formes_regla_hunspell($mot_masc, $lletraregla) =~ /^$resultat$/) {
		    my $apostrofacions="";
		    if (Flexio::apostrofa_masculi($mot_masc)) {
			$apostrofacions="_V_Y";
		    }
		    print $ofh "$mot_masc/$lletraregla$apostrofacions\n";
		    # Apostrofació del femení singular
		    if (Flexio::apostrofa_femeni($mot_fem)) {
			print $ofh "$mot_fem/_V_Y\n";
		    }
		    if (Flexio::apostrofa_femeni($fs2)) {
			print $ofh "$fs2/_V_Y\n";
		    }
		    $trobat=1;
		    last;
		}
	    }
	    if (!$trobat) {
		#print $ofh "NO TROBAT: $resultat\n";
		#Escriu totes les formes una per una $mot_masc, $mot_fem, $ms2, $fs2, $mp1, $mp2, $fp1, $fp2
		# MS1
		if (Flexio::apostrofa_masculi($mot_masc)) {
		    print $ofh "$mot_masc/_V_Y\n";
		} else {
		    print $ofh "$mot_masc\n";
		}
		# MS2
		if ($ms2 =~ /.+/) {
		    if (Flexio::apostrofa_masculi($ms2)) {
			print $ofh "$ms2/_V_Y\n";
		    } else {
			print $ofh "$ms2\n";
		    }
		}
		# FS1
		if (Flexio::apostrofa_femeni($mot_fem)) {
		    print $ofh "$mot_fem/_V_Y\n";
		} elsif (Flexio::apostrofa_masculi($mot_fem)) {
		    print $ofh "$mot_fem/_Y\n";
		} else {
		    print $ofh "$mot_fem\n";
		}
		# FS2
		if ($fs2 =~ /.+/) {
		    if (Flexio::apostrofa_femeni($fs2)) {
			print $ofh "$fs2/_V_Y\n";
		    } elsif (Flexio::apostrofa_masculi($fs2)) {
			print $ofh "$fs2/_Y\n";
		    } else {
			print $ofh "$fs2\n";
		    }
		}
		# MP
		if ($mp =~ /.+/) {
		    if (Flexio::apostrofa_masculi($mp)) {
			print $ofh "$mp/_Y\n";
		    } else {
			print $ofh "$mp\n";
		    }
		}
		# MP2
		if ($mp2 =~ /.+/) {
		    if (Flexio::apostrofa_masculi($mp2)) {
			print $ofh "$mp2/_Y\n";
		    } else {
			print $ofh "$mp2\n";
		    }
		}
		# FP
		if ($fp =~ /.+/) {
		    if (Flexio::apostrofa_masculi($fp)) {
			print $ofh "$fp/_Y\n";
		    } else {
			print $ofh "$fp\n";
		    }
		}
		# FP2
		if ($fp2 =~ /.+/) {
		    if (Flexio::apostrofa_masculi($fp2)) {
			print $ofh "$fp2/_Y\n";
		    } else {
			print $ofh "$fp2\n";
		    }
		}
	    }

	}
	
	#
	# Una única forma. Ex.: taula.
	#

	elsif ( $line =~ /^([^#].*)=categories: (.+?);/ ) {

	    $categoria = $2;
	    my $entrada = $1;
	    my $singular = "";
	    my $plural = "";
	    my $plural2 = "";
	    my $singular2 = "";
	    my $femeniplural = "";
	    my $femenisingular2 = "";
	    my $femeniplural2 = "";
	    $numAccepcio = "";

	    #forma bàsica primera
	    if ($entrada =~ /^($Flexio::carac+)/)
	    {
		$singular = $1;
		$numAccepcio = "";
		if ($singular !~ /^(MP3|A[345]|goma-2)$/) { # Excepció: el número forma part del mot
		    if ($singular =~ /^(.+)([0-9])$/) {
			$singular = $1;
			$numAccepcio = $2;
		    }
		}
	    }
	    if ($categoria !~ /S/) {
		if ($categoria =~ /F/ && $categoria !~ /M/) {
		    $plural=Flexio::plural($singular, "F", "F");  #les larinxs, falçs, calçs
		} else {
		    $plural=Flexio::plural($singular, "M");
		}
	    }
	    if ($categoria =~ /I$/) 	#Invarible
	    {
		$plural=$singular;
	    }
	    elsif ($entrada =~ /\[pl\. ([^ ]+)\]/) { #una excepció de plural
		$plural=$1;
		$femeniplural=$1;
	    }
	    elsif ($entrada =~ /\[pl\. (.+) o (.+)\]/) { # dues excepcions de plural
		$plural=$1;
		$femeniplural=$1;
		$plural2=$2;
	    }
	    else {
		# dobles formes de plural, si no existeixen com a excepció
		# Evita forestos (correcte: la forest, les forests)
		if ($categoria =~ /M/) { 
		    if ($plural2 =~ /^$/) {
			if ($plural =~ /^(.+s[tc])s$/ ) {
			    $plural2=$1."os";
			}
			elsif ($plural =~ /^(.+xt)s$/ ) {
			    $plural2=$1."os";
			}     
			# assaigs assajos
			elsif ($plural =~ /^(.+[aeou])igs$/ ) {
			    $plural2=$1."jos";
			}     
		    }
		}
	    }


	    if ($entrada =~ /\[fem\. (.+)]/) { # una forma extra femení
		$femenisingular2=$1;
	    }
	    
	    #accentuació valenciana
	    if ($singular !~ /^perquè$/ && !$general) {
		if ($singular =~ /^(.+)è([sn]?)$/ ) {
		    $singular2=$1."é".$2;
		    # print "$singular $singular2\n";
		}
		if ($plural =~ /^(.+)è([sn]?)$/ ) {
		    $plural2=$1."é".$2;
		    # print "$singular $singular2\n";
		}
	    }

	    $tagbefore = "";
	    $tagafter = "";
	    if ($categoria =~ /^[MF]/) {
		$tagbefore="NC"; $tagafter="000";
	    } elsif ($categoria =~ /^AO/) {
		$tagbefore="AO0"; $tagafter="0";
	    } elsif ($categoria =~ /^AA/) {
		$tagbefore="AQA"; $tagafter="0";
	    } elsif ($categoria =~ /^A/) {
		$tagbefore="AQ0"; $tagafter="0";
	    }

	    #noms
	    if ( $categoria =~ /I$/ ) {
		$resultat.= $singular;
		if ($singular2 =~ /.+/) {
		    $resultat.= " ".$singular2;
		}
=pod
		    if ($categoria =~ /MF/) {
		print $ofh "$singular $singular$numAccepcio $tagbefore"."CN"."$tagafter\n";
		if ($singular2 =~ /.+/) {
		print $ofh "$singular2 $singular$numAccepcio $tagbefore"."CN"."$tagafter\n";
		}
	    }
		elsif ($categoria =~ /F/) {
		print $ofh "$singular $singular$numAccepcio $tagbefore"."FN"."$tagafter\n";
		if ($singular2 =~ /.+/) {
		print $ofh "$singular2 $singular$numAccepcio $tagbefore"."FN"."$tagafter\n";
		}
	} elsif ($categoria =~ /M/) {
		print $ofh "$singular $singular$numAccepcio $tagbefore"."MN"."$tagafter\n";
		if ($singular2 =~ /.+/) {
		print $ofh "$singular2 $singular$numAccepcio $tagbefore"."MN"."$tagafter\n";
	}
    } else {
		print $ofh "$singular $singular$numAccepcio $tagbefore"."CN"."$tagafter\n";
		if ($singular2 =~ /.+/) {
		print $ofh "$singular2 $singular$numAccepcio $tagbefore"."CN"."$tagafter\n";
		}
		}
=cut
	    }
	    elsif ( $categoria =~ /^(MF|A|AA|AO)$/ ) {
		if ( $singular =~ $plural ) {
		    $resultat.= $singular;
		    #print $ofh "$singular $singular$numAccepcio $tagbefore"."CN"."$tagafter\n";
		}
		else {
		    $resultat.= $singular;
		    #print $ofh "$singular $singular$numAccepcio $tagbefore"."CS"."$tagafter\n";
		    if ($singular2 =~ /.+/) {
			#print $ofh "$singular2 $singular$numAccepcio $tagbefore"."CS"."$tagafter\n";
			$resultat.= " ".$singular2;
		    }
		    if ($femeniplural =~ /^$/) {
			$femeniplural = Flexio::plural($singular, "F");
		    }
		    if ($plural =~ /$femeniplural/) {
			#print $ofh "$plural $singular$numAccepcio $tagbefore"."CP"."$tagafter\n";
			$resultat.= " ".$plural;
			if ($plural2 =~ /.+/) {
			    $resultat.= " ".$plural2;
			    #print $ofh "$plural2 $singular$numAccepcio $tagbefore"."CP"."$tagafter\n";
			}
		    } else {
			#print $ofh "$plural $singular$numAccepcio $tagbefore"."MP"."$tagafter\n";
			#print $ofh "$femeniplural $singular$numAccepcio $tagbefore"."FP"."$tagafter\n"; #sequaces
			$resultat.= " ".$plural;
			$resultat.= " ".$femeniplural;
		    }
		    # forma femenina extra
		    if ($femenisingular2 =~ /.+/) {
			#print $ofh "$femenisingular2 $singular$numAccepcio $tagbefore"."FS"."$tagafter\n";
			$resultat.= " ".$femenisingular2;
			my $femeniplural2=Flexio::plural($femenisingular2,"F");
			$resultat.= " ".$femeniplural2;
			#print $ofh "$femeniplural2 $singular$numAccepcio $tagbefore"."FP"."$tagafter\n";
		    }
		}
	    } 
	    elsif ( $categoria =~ /MS/ ) {
		#print $ofh "$singular $singular$numAccepcio $tagbefore"."MS"."$tagafter\n";
		$resultat.= $singular;
		if ($singular2 =~ /.+/) {
		    #print $ofh "$singular2 $singular$numAccepcio $tagbefore"."MS"."$tagafter\n";
		    $resultat.= " ".$singular2;
		}
	    }
	    elsif ( $categoria =~ /MP/ ) {
		$resultat.= $singular;
		#print $ofh "$singular $singular$numAccepcio $tagbefore"."MP"."$tagafter\n";
		if ($plural2 =~ /.+/) {
		    $resultat.= " ".$plural2;
		    #print $ofh "$plural2 $singular$numAccepcio $tagbefore"."MP"."$tagafter\n"; ## ???
		}
	    }
	    elsif ( $categoria =~ /FS/ ) {
		$resultat.= $singular;
		#print $ofh "$singular $singular$numAccepcio $tagbefore"."FS"."$tagafter\n";
	    }
	    elsif ( $categoria =~ /FP/ ) {
		$resultat.= $singular;
		#print $ofh "$singular $singular$numAccepcio $tagbefore"."FP"."$tagafter\n";
	    }
	    elsif ( $categoria =~ /MI/ ) {
		$resultat.= $singular;
		#print $ofh "$singular $singular$numAccepcio $tagbefore"."MN"."$tagafter\n";
		if ($singular2 =~ /.+/) {
		    $resultat.= " ".$singular2;
		    #print $ofh "$singular2 $singular$numAccepcio $tagbefore"."MN"."$tagafter\n";
		}
	    }
	    elsif ( $categoria =~ /M/ ) {
		$resultat.= $singular;		 
		#print $ofh "$singular $singular$numAccepcio $tagbefore"."MS"."$tagafter\n";
		#print $ofh "$plural $singular$numAccepcio $tagbefore"."MP"."$tagafter\n";		
		if ($singular2 =~ /.+/) {
		    #print $ofh "$singular2 $singular$numAccepcio $tagbefore"."MS"."$tagafter\n";
		    $resultat.= " ".$singular2;
		}	    
		$resultat.= " ".$plural;
		if ($plural2 =~ /.+/) {
		    #print $ofh "$plural2 $singular$numAccepcio $tagbefore"."MP"."$tagafter\n";
		    $resultat.= " ".$plural2;
		}
	    }
	    elsif ( $categoria =~ /FI/ ) {
		$resultat.= $singular;		
		#print $ofh "$singular $singular$numAccepcio $tagbefore"."FN"."$tagafter\n";
	    }
	    elsif ( $categoria =~ /F/ ) {
		$resultat.= $singular;		 
		#print $ofh "$singular $singular$numAccepcio $tagbefore"."FS"."$tagafter\n";
		if ($singular2 =~ /.+/) {
		    #print $ofh "$singular2 $singular$numAccepcio $tagbefore"."FS"."$tagafter\n";
		    $resultat.= " ".$singular2;
		}
#		if ($femeniplural !~ /.+/) {
#		    $femeniplural = Flexio::plural($singular, "F"); #Atenció: forests (no forestos)
#		}
		#print $ofh "$plural $singular$numAccepcio $tagbefore"."FP"."$tagafter\n";
		$resultat.= " ".$plural;
		if ($plural2 =~ /.+/) {
		    #print $ofh "$plural2 $singular$numAccepcio $tagbefore"."FP"."$tagafter\n";
		    $resultat.= " ".$plural2;
		} elsif ($singular2 =~ /.+/) {
		    $femeniplural2=Flexio::plural($singular2, "F", "F");
		    #print $ofh "$femeniplural2 $singular2$numAccepcio $tagbefore"."FP"."$tagafter\n"; #???
		    $resultat .= " ".$femeniplural2;
		}		
	    }

	    if ($resultat =~ / /) {
		my @lletresregla = ("_E", "_I", "_G", "_i", "_F");
		my $trobat=0;
		foreach my $lletraregla (@lletresregla) {
		    if (&genera_formes_regla_hunspell($singular, $lletraregla) =~ /^$resultat$/) {
			my $apostrofacions="";
			if ($categoria =~ /F/ && $categoria !~ /M/) {
			    if (Flexio::apostrofa_femeni($singular)) {
				$apostrofacions.="_V";
			    }
			    if (Flexio::apostrofa_masculi($singular)) {
				$apostrofacions.="_Y";
			    }
			} elsif (Flexio::apostrofa_masculi($singular)) {
			    $apostrofacions="_V_Y";
			}
			print $ofh "$singular/$lletraregla$apostrofacions\n";
			$trobat=1;
			last;
		    }
		}

		if (!$trobat) {
		    #print $ofh "NO TROBAT: $resultat\n";
                    # my $singular = "";  my $plural = ""; my $plural2 = ""; my $singular2 = ""; my $femeniplural = ""; my $femenisingular2 = ""; my $femeniplural2 = "";
		    # escriu totes les formes una per una
		    # SINGULAR
		    my $apostrofacions="";
		    if ($categoria =~ /F/ && $categoria !~ /M/) {
			if (Flexio::apostrofa_femeni($singular)) {
			    $apostrofacions.="_V";
			}
			if (Flexio::apostrofa_masculi($singular)) {
			    $apostrofacions.="_Y";
			}
		    } elsif (Flexio::apostrofa_masculi($singular)) {
			$apostrofacions="_V_Y";
		    }
		    $apostrofacions =~ s/(.+)/\/$1/;
		    print $ofh "$singular$apostrofacions\n";
		    # SINGULAR2
		    if ($singular2 =~ /.+/) {
			$apostrofacions="";
			if ($categoria =~ /F/ && $categoria !~ /M/) {
			    if (Flexio::apostrofa_femeni($singular2)) {
				$apostrofacions.="_V";
			    }
			    if (Flexio::apostrofa_masculi($singular2)) {
				$apostrofacions.="_Y";
			    }
			} elsif (Flexio::apostrofa_masculi($singular2)) {
			    $apostrofacions="_V_Y";
			}
			$apostrofacions =~ s/(.+)/\/$1/;
			print $ofh "$singular2$apostrofacions\n";
		    }
                    # FEMENI SINGULAR2
		    if ($femenisingular2 =~ /.+/) {
			$apostrofacions="";
			if (Flexio::apostrofa_femeni($femenisingular2)) {
			    $apostrofacions.="_V";
			}
			if (Flexio::apostrofa_masculi($femenisingular2)) {
			    $apostrofacions.="_Y";
			}
			$apostrofacions =~ s/(.+)/\/$1/;
			print $ofh "$femenisingular2$apostrofacions\n";
		    }
                    # PLURAL
		    if ($plural =~ /.+/) {
			$apostrofacions="";
			if (Flexio::apostrofa_masculi($plural)) {
			    $apostrofacions.="_Y";
			}
			$apostrofacions =~ s/(.+)/\/$1/;
			print $ofh "$plural$apostrofacions\n";
		    }
                    # PLURAL2
		    if ($plural2 =~ /.+/) {
			$apostrofacions="";
			if (Flexio::apostrofa_masculi($plural2)) {
			    $apostrofacions.="_Y";
			}
			$apostrofacions =~ s/(.+)/\/$1/;
			print $ofh "$plural2$apostrofacions\n";
		    }
		     # FEMENIPLURAL
		    if ($femeniplural =~ /.+/ && $femeniplural !~ /^$plural$/) {
			$apostrofacions="";
			if (Flexio::apostrofa_masculi($femeniplural)) {
			    $apostrofacions.="_Y";
			}
			$apostrofacions =~ s/(.+)/\/$1/;
			print $ofh "$femeniplural$apostrofacions\n";
		    }
                    # FEMENIPLURAL2
		    if ($femeniplural2 =~ /.+/) {
			$apostrofacions="";
			if (Flexio::apostrofa_masculi($femeniplural2)) {
			    $apostrofacions.="_Y";
			}
			$apostrofacions =~ s/(.+)/\/$1/;
			print $ofh "$femeniplural2$apostrofacions\n";
		    }
		}
	    } else { # Només hi ha una forma
		my $apostrofacions="";
		if ($categoria =~ /F/ && $categoria !~ /[MP]/) {
		    if (Flexio::apostrofa_femeni($singular)) {
			$apostrofacions.="_V";
		    }		
		} elsif (Flexio::apostrofa_masculi($singular) && $categoria !~ /P/) {
		    $apostrofacions.="_V";
		}
		if (Flexio::apostrofa_masculi($singular)) {
		    $apostrofacions.="_Y";
		}
		if ($apostrofacions =~ /.+/) {
		    $apostrofacions = "/".$apostrofacions;
		}
		print $ofh "$singular"."$apostrofacions\n";
	    }
	}
	else 
	{
	    print "$line\n";
	}

    }
    close($fh);
    close($ofh);
}


# Funció: torna les formes generades per una regla Hunspell
sub genera_formes_regla_hunspell {
    my $mot = $_[0];
    my $lletraregla = $_[1];

    my $formesresultants=$mot;
    for my $regla (@regles) {
	if ($regla =~ /^[SP]FX $lletraregla (.+) (.+) (.+)$/) {
	    my $acabaen = $3;
	    my $lleva = $1;
	    my $afig = $2;
	    my $afignet = $afig;
	    $lleva =~ s/0$//; # elimina 0
	    $afignet =~ s/\/.+$//;  # cantava/A > cantava
	    if ($mot =~ /$acabaen$/) {
		my $forma = $mot;
		if ($lleva =~ /.+/) {
		    $forma =~ s/$lleva$/$afignet/;
		} else {
		    $forma = $forma.$afignet;
		}
		$formesresultants.=" ".$forma;
	    }
	}
    }
    return $formesresultants;
}

