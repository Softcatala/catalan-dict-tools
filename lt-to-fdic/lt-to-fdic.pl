use strict;
use warnings;
use autodie;
use utf8;
use Switch;
require "./libs/Flexio.pm";

binmode( STDOUT, ":utf8" );

my $arxiucategoria = $ARGV[0];    # adjectius, noms
my $dir_entrada    = $ARGV[1];

my $f1 = $dir_entrada . "/ordenats-" . $arxiucategoria . ".txt";

#my $out = "models_flexio_nominal.txt";
my $out2 = $dir_entrada . "/mots_no_processats.txt";
my $out3 = $dir_entrada . "/" . $arxiucategoria . "-fdic.txt";

my $lemma     = "";
my $prevLemma = "";
my $lemmaMasc = "";
my $lemmaFem  = "";
my $model     = "";
my $modeltag  = "";
my $word;
my $wordAux;
my $arrel      = "";
my $terminacio = "";
my $sufix;
my $postag;
my $error               = 1;
my %models              = ();
my %modeltags           = ();
my %verbs_no_processats = ();
my %model               = ();
my $posicions_radical   = 0;
my $i                   = 0;
my $j                   = 0;
my $l                   = 0;
my @words;
my @postags;
my @sufixos;
my @sufixos_esborrats;
my $count       = 0;
my $numAccepcio = "";

#quatre formes amb possibilitat d'una segona opció: MS,FS,MP,FP,MS2,FS2,MP2,FP2
my @forma;
for ( $count = 0 ; $count < 8 ; $count++ ) {
    $forma[$count]             = "";
    $sufixos[$count]           = "";
    $sufixos_esborrats[$count] = "";
}
my @case;
$case[0] = "MS";
$case[1] = "FS";
$case[2] = "MP";
$case[3] = "FP";
$case[4] = "MS";
$case[5] = "FS";
$case[6] = "MP";
$case[7] = "FP";

open( my $fh,  "<:encoding(UTF-8)", $f1 );
open( my $ofh, ">:encoding(UTF-8)", $out3 );
while ( my $line = <$fh> ) {
    chomp($line);
    if ( $line =~ /^([^ ]+) (A.+|N.+) ([^ ]+)$/ ) {
        $lemma  = $1;
        $word   = $3;
        $postag = $2;

        if ( $lemma !~ /^$prevLemma$/ ) {    #s'acaba el lema

            $numAccepcio = "";
            if ( $prevLemma !~ /^MP3|A[345]|goma-2|4x4$/ )
            {    #Excepcions: el número forma part de la paraula
                if ( $prevLemma =~ /([0-9])$/ ) {
                    $numAccepcio = $1;
                }
            }

            escriuFormatDiccionari();

            #comença un verb nou
            $model     = "";
            $modeltag  = "";
            $error     = 0;
            $i         = 0;
            $lemmaMasc = "";

            $lemmaFem = "";
            for ( $count = 0 ; $count < 9 ; $count++ ) {  # La posició 9 és per al superlatium
                $forma[$count]   = "";
                $sufixos[$count] = "";
            }

            #if ($lemma =~ /^(.+)(.)$/)
            #{
            #	$terminacio=$2;
            #}
            $terminacio = ".";
        }

        #afegeix forma
        $words[$i]   = $word;
        $postags[$i] = $postag;
        $i++;
        $modeltag .= $postag . ",";

        if ($forma[0] !~ /^$/ && $postag =~ /AQA/) {
        	if ( $postag =~ /MS/ ) {
        		$forma[8] = $word; #és superlatiu, ja existeix el lema
        	}
        } 
        else {
            if ( $postag =~ /[MC][SN]/ ) {
	            $lemmaMasc = $word;
	            if ( $forma[0] =~ /^$/ ) { $forma[0] = $word; }
	            elsif ( ( $forma[4] =~ /^$/ ) && ( $word !~ /^$forma[0]$/ ) ) {
	                $forma[4] = $word;
	            }
	            elsif ( ( $word !~ /^$forma[0]$/ ) && ( $word !~ /^$forma[4]$/ ) ) {
	                print "error en 1: $word $lemma $postag $modeltag\n";
	            }
	        }
	        if ( $postag =~ /[FC][SN]/ ) {
	            $lemmaFem = $word;
	            if ( $forma[1] =~ /^$/ ) { $forma[1] = $word; }
	            elsif ( ( $forma[5] =~ /^$/ ) && ( $word !~ /^$forma[1]$/ ) ) {
	                $forma[5] = $word;
	            }
	            elsif ( ( $word !~ /^$forma[1]$/ ) && ( $word !~ /^$forma[5]$/ ) ) {
	                print "error en 2: $word $lemma $postag $modeltag\n";
	            }
	        }
	        if ( $postag =~ /[MC][PN]/ ) {
	            if ( $forma[2] =~ /^$/ ) { $forma[2] = $word; }
	            elsif ( ( $forma[6] =~ /^$/ ) && ( $word !~ /^$forma[2]$/ ) ) {
	                $forma[6] = $word;
	            }
	            elsif ( ( $word !~ /^$forma[2]$/ ) && ( $word !~ /^$forma[6]$/ ) ) {
	                print "error en 3: $word $lemma $postag $modeltag\n";
	            }
	        }
	        if ( $postag =~ /[FC][PN]/ ) {
	            if ( $forma[3] =~ /^$/ ) { $forma[3] = $word; }
	            elsif ( ( $forma[7] =~ /^$/ ) && ( $word !~ /^$forma[3]$/ ) ) {
	                $forma[7] = $word;
	            }
	            elsif ( ( $word !~ /^$forma[3]$/ ) && ( $word !~ /^$forma[7]$/ ) ) {
	                print "error en 4: $word $lemma $postag $modeltag\n";
	            }
	        }
        }

        $prevLemma = $lemma;
    }
}
escriuFormatDiccionari();    #última paraula
close($fh);
close($ofh);

=pod
open($ofh, ">:encoding(UTF-8)", $out );
my $key;
my $value;
my $myPostag;
my $k;
my $v;
my $modelFem     = "";
my $modelGeneral = "";
$count = 0;
while ( ( $key, $value ) = each %models ) {
    $count++;
    print $ofh "############\n# MODEL: $count\n";
    print $ofh "# $key\n";
    print $ofh "# MOTS: $value\n";
    print $ofh "\n";
}
$count = 0;

while ( ( $key, $value ) = each %modeltags ) {
    $count++;
    print $ofh "############\n# *MODEL: $count\n";
    print $ofh "# $key\n";
    print $ofh "# MOTS: $value\n";
    print $ofh "\n";
}
close($ofh);

=cut

### Escriu en format de diccionari
sub escriuFormatDiccionari {

=pod
    if ($forma[0] =~ /^sèu$/ ) {
	for ( $count = 0; $count < 8; $count++ ) 
	{
	    print "$forma[$count] ";
	}
	print Flexio::plural($forma[0]);
    }
=cut

    if (
        $modeltag =~ /(NC|AQ0|AQA|AO0)/ ) # És nom, adjectiu o adjectiu ordinal
    {
        my $originTag = $1;

        #nom masculí
        if (
            $modeltag !~ /(NC|AQ0|AQA|AO0)[FC]/
            && (
                $modeltag =~ /(NC|AQ0|AQA|AO0)MN/
                || (   $modeltag =~ /(NC|AQ0|AQA|AO0)MS/
                    && $modeltag =~ /(NC|AQ0|AQA|AO0)MP/ )
            )
          )
        {

            if ( $forma[4] =~ /^$/ ) {
                print $ofh "$forma[0]$numAccepcio";
            }
            elsif ( $forma[0] =~ /è[sn]?$/
              )    # entre bebè i bebé tria només l'accentuació general
            {
                print $ofh "$forma[0]$numAccepcio";
            }
            else {
                print $ofh "$forma[0]$numAccepcio ($forma[4])";
            }

#dues formes de plural (desig/desitjos, mig/mitjos, enuigs/enutjos)
#però no cal "textos/texts, balancejos/balanceigs, assaigs/assajos, puigs/pujos"
#excepte invariables
            if (
                $forma[0] !~ /^$forma[2]$/
                && !(
                    $forma[2] =~ /(st|xt|sc)os$/ && $forma[6] =~ /(st|xt|sc)s$/
                )
                && !( $forma[2] =~ /[aeou]igs$/ && $forma[6] =~ /[aeou]jos$/ )
              )
            {
                if ( $forma[6] =~ /^.+$/ ) {
                    if ( $forma[2] =~ /ès$/ ) {
                        print $ofh " [pl. $forma[2]]";    #bebès
                    }
                    else {
                        print $ofh " [pl. $forma[2] o $forma[6]]";
                    }
                }

                # plural amb dues esses: afàs afassos
                # o excepcional: coipú/coipús
                # més excepcions: amfiox amfioxs
                # invariables no
                elsif ( Flexio::plural( $forma[0] ) !~ /^$forma[2]$/ ) {
                    if ( $forma[6] =~ /ès$/ ) {
                        print $ofh " [pl. $forma[6]]";
                    }
                    else {
                        print $ofh " [pl. $forma[2]]";
                    }
                }
                elsif ( $forma[2] =~ /(st|xt|sc)s$/ && $forma[6] =~ /^$/ ) {
                    print $ofh " [pl. $forma[2]]";   # twists (però no twistos)
                }
            }

            print $ofh "=categories: ";

            switch ($originTag) {
                case "NC"  { print $ofh "M"; }
                case "AQ0" { print $ofh "AM"; }
                case "AO0" { print $ofh "AOM"; }     #???
                case "AQA" { print $ofh "AAM"; }     #???
            }

            # invariable
            if ( $forma[0] =~ /^$forma[2]$/ ) {
                print $ofh "I";
            }

        }

        #nom femení
        elsif (
            $modeltag !~ /(NC|AQ0|AQA|AO0)[MC]/
            && (
                $modeltag =~ /(NC|AQ0|AQA|AO0)FN/
                || (   $modeltag =~ /(NC|AQ0|AQA|AO0)FS/
                    && $modeltag =~ /(NC|AQ0|AQA|AO0)FP/ )
            )
          )
        {

            if ( $forma[5] =~ /^$/ ) {
                print $ofh "$forma[1]$numAccepcio";
            }
            elsif ( $forma[1] =~ /è[sn]?$/
              )    # entre bebè i bebé tria només l'accentuació general
            {
                print $ofh "$forma[1]$numAccepcio";
            }
            else {
                print $ofh "$forma[1]$numAccepcio ($forma[5])";
            }

#dues formes de plural (desig/desitjos, mig/mitjos, enuigs/enutjos)
#però no cal "textos/texts, balancejos/balanceigs, assaigs/assajos, puigs/pujos"
#excepte invariables
            if (   $forma[7] =~ /^.+$/
                && $forma[1] !~ /^$forma[3]$/ )
            {
                if ( $forma[3] =~ /ès$/ ) {
                    print $ofh " [pl. $forma[3]]";
                }
                else {
                    print $ofh " [pl. $forma[3] o $forma[7]]";
                }
            }

            # plural amb dues esses: afàs afassos
            # o excepcional: coipú/coipús
            # invariables no
            elsif (( $forma[1] !~ /^$forma[3]$/ )
                && ( Flexio::plural( $forma[1], "F", "F" ) !~ /^$forma[3]$/ ) )
            {
                print $ofh " [pl. $forma[3]]";
            }

            print $ofh "=categories: ";
            switch ($originTag) {
                case "NC"  { print $ofh "F"; }
                case "AQ0" { print $ofh "AF"; }
                case "AO0" { print $ofh "AOF"; }    #???
                case "AQA" { print $ofh "AAF"; }    #???
            }

            # invariable
            if ( $forma[1] =~ /^$forma[3]$/ ) {
                print $ofh "I";
            }

        }

        #nom masculí i femení
        elsif (
            $modeltag =~ /(NC|AQ0|AQA|AO0)C/
            || (   $modeltag =~ /(NC|AQ0|AQA|AO0)F/
                && $modeltag =~ /(NC|AQ0|AQA|AO0)M/ )
          )
        {
            if ( $forma[4] =~ /^$/ ) {
                if ( $forma[1] =~ /^$/ || $forma[0] =~ /^$forma[1]$/ ) {
                    print $ofh "$forma[0]$numAccepcio";
                }
                else {
                    print $ofh "$forma[0]$numAccepcio $forma[1]";
                }
            }
            elsif ( $forma[0] =~ /è[sn]?$/
              )    # entre bebè i bebé tria només l'accentuació general
            {
                if ( $forma[1] =~ /^$/ || $forma[0] =~ /^$forma[1]$/ ) {
                    print $ofh "$forma[0]$numAccepcio";
                }
                else {
                    print $ofh
                      "$forma[0]$numAccepcio $forma[1]";    #agarè agarena
                }
            }
            else {
                print $ofh
                  "$forma[0]$numAccepcio $forma[1] [masc. $forma[4]]";    # bon
            }
            if ( $forma[5] =~ /^.+$/ && $forma[5] !~ /^.+[èé][sn]?$/ ) # oboè
            {    #segona forma de femení
                print $ofh " [fem. $forma[5]]";
            }

#dues formes de plural (desig/desitjos, mig/mitjos, enuigs/enutjos)
#però no cal "textos/texts, balancejos/balanceigs, assaigs/assajos, puigs/pujos"
#excepte invariables
            if (
                $forma[0] !~ /^$forma[2]$/
                && !(
                    $forma[2] =~ /(st|xt|sc)os$/ && $forma[6] =~ /(st|xt|sc)s$/
                )
                && !( $forma[2] =~ /[aeou]igs$/ && $forma[6] =~ /[aeou]jos$/ )
              )
            {

                if ( $forma[6] =~ /^.+$/ ) {
                    if ( $forma[2] =~ /ès$/ ) {
                        print $ofh " [pl. $forma[2]]";
                    }
                    else {
                        print $ofh " [pl. $forma[2] o $forma[6]]";
                    }
                }

                # plural amb dues esses: afàs afassos
                # o excepcional: coipú/coipús
                # invariables no
                elsif (
                    Flexio::mascplural_partintdeduesformes( $forma[0],
                        $forma[1] ) !~ /^$forma[2]$/
                  )
                {
                    if ( $forma[6] =~ /ès$/ ) {
                        print $ofh " [pl. $forma[6]]";
                    }
                    else {
                        print $ofh " [pl. $forma[2]]";
                    }
                }
            }

            # superlatiu
            if ( $forma[8] =~ /^.+$/ ) {
                print $ofh " [sup. $forma[8]]";
            }

            print $ofh "=categories: ";
            switch ($originTag) {
                case "NC"  { print $ofh "MF"; }
                case "AQ0" { print $ofh "A"; }
                case "AO0" { print $ofh "AO"; }
                case "AQA" { print $ofh "AA"; }
            }

            # invariable
            if ( $forma[0] =~ /^$forma[2]$/ ) {
                print $ofh "I";
            }
        }

        #nom masculí singular
        elsif ($modeltag !~ /(NC|AQ0|AQA|AO0)[FC]/
            && $modeltag =~ /(NC|AQ0|AQA|AO0)MS/
            && $modeltag !~ /(NC|AQ0|AQA|AO0)M[NP]/ )
        {

            if ( $forma[4] =~ /^$/ ) {
                print $ofh "$forma[0]$numAccepcio";
            }
            elsif ( $forma[0] =~ /è[sn]?$/
              )    # entre bebè i bebé tria només l'accentuació general
            {
                print $ofh "$forma[0]$numAccepcio ???";
            }
            else {
                print $ofh "$forma[0]$numAccepcio ($forma[4]) ???";
            }

            print $ofh "=categories: ";
            switch ($originTag) {
                case "NC"  { print $ofh "MS"; }
                case "AQ0" { print $ofh "AMS"; }
                case "AO0" { print $ofh "AOMS"; }    #???
                case "AQA" { print $ofh "AAMS"; }    #???
            }

        }

        #nom masculí plural
        elsif ($modeltag !~ /(NC|AQ0|AQA|AO0)[FC]/
            && $modeltag =~ /(NC|AQ0|AQA|AO0)MP/
            && $modeltag !~ /(NC|AQ0|AQA|AO0)M[NS]/ )
        {

            if ( $forma[6] =~ /^$/ ) {
                print $ofh "$forma[2]$numAccepcio";
            }
            elsif ( $forma[2] =~ /è[sn]?$/
              )    # entre bebè i bebé tria només l'accentuació general
            {
                print $ofh "$forma[2]$numAccepcio ???";
            }
            else {
                print $ofh "$forma[2]$numAccepcio ($forma[6]) ???";
            }

            print $ofh "=categories: ";
            switch ($originTag) {
                case "NC"  { print $ofh "MP"; }
                case "AQ0" { print $ofh "AMP"; }
                case "AO0" { print $ofh "AOMP"; }    #???
                case "AQA" { print $ofh "AAMP"; }    #???
            }

        }

        #nom femení singular
        elsif ($modeltag !~ /(NC|AQ0|AQA|AO0)[MC]/
            && $modeltag =~ /(NC|AQ0|AQA|AO0)FS/
            && $modeltag !~ /(NC|AQ0|AQA|AO0)F[NP]/ )
        {

            if ( $forma[5] =~ /^$/ ) {
                print $ofh "$forma[1]$numAccepcio";
            }
            elsif ( $forma[1] =~ /è[sn]?$/
              )    # entre bebè i bebé tria només l'accentuació general
            {
                print $ofh "$forma[1]$numAccepcio ???";
            }
            else {
                print $ofh "$forma[1]$numAccepcio ($forma[5]) ???";
            }

            print $ofh "=categories: ";
            switch ($originTag) {
                case "NC"  { print $ofh "FS"; }
                case "AQ0" { print $ofh "AFS"; }
                case "AO0" { print $ofh "AOFS"; }    #???
                case "AQA" { print $ofh "AAFS"; }    #???
            }

        }

        #nom femení plural
        elsif ($modeltag !~ /(NC|AQ0|AQA|AO0)[MC]/
            && $modeltag =~ /(NC|AQ0|AQA|AO0)FP/
            && $modeltag !~ /(NC|AQ0|AQA|AO0)F[NS]/ )
        {

            if ( $forma[7] =~ /^$/ ) {
                print $ofh "$forma[3]$numAccepcio";
            }
            elsif ( $forma[3] =~ /è[sn]?$/
              )    # entre bebè i bebé tria només l'accentuació general
            {
                print $ofh "$forma[3]$numAccepcio ???";
            }
            else {
                print $ofh "$forma[3]$numAccepcio ($forma[7]) ???";
            }

            print $ofh "=categories: ";
            switch ($originTag) {
                case "NC"  { print $ofh "FP"; }
                case "AQ0" { print $ofh "AFP"; }
                case "AO0" { print $ofh "AOFP"; }    #???
                case "AQA" { print $ofh "AAFP"; }    #???
            }

        }
        else {
            print $ofh "; per fer; ";
        }
        print $ofh ";fonts: LT;\n";
    }

}
