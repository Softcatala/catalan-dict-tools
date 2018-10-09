#!/bin/perl
use strict;
use warnings;
use autodie;
use utf8;
no locale;
use Encode qw(decode);
require "./libs/Flexio.pm";

binmode( STDOUT, ":utf8" );

my $f1        = $ARGV[0];          #"diccionari-arrel/verbs-fdic.txt";
my $out       = $ARGV[1];          #"verbs-hunspell.dic";
my $modelsdir = $ARGV[2] . "/";    #"diccionari-arrel/models-verbals/";

my $general = 0;    #Si és 1, versió "general" del corrector
if ( grep( /^-catalan$/, @ARGV ) ) {
    $general = 1;
}

my @files = glob( $modelsdir . "*.model" );
@files = sort(@files);
my $modelscount = 0;
my %sufixos     = ();

my $selectedmodels = "(abalisar|anul·lar|adossar|capbussar|anquilosar|acarnissar|adobassar|lligar|ofrenar|lloar|menjar|començar|traduir|abominar|pregar|crear|trencar|servir|envejar|cantar)";
my @modelnames = ("1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f", "g", "h", "j", "k", "l");

#llegeix nom dels models i assigna un nom
foreach my $file (@files) {
    $file = decode( "utf8", $file );
    next if ( $file !~ /^$modelsdir$selectedmodels\.model$/ );  
    my $infinitiu = $file;
    $infinitiu =~ s/$modelsdir(.*)\.model/$1/;
    $sufixos{$infinitiu} = $modelnames[$modelscount];
    $modelscount++;
}

open( my $fh,  "<:encoding(UTF-8)", $f1 );
open( my $ofh, ">:encoding(UTF-8)", $out );
my %formes = ();
while ( my $line = <$fh> ) {
    chomp($line);
    if ( $line =~ /^([^#]+)(er|re|ir|ar|r)=categories:(.+?);model:(.+?);/ ) {
        my $infinitiu  = $1 . $2;
        my $terminacio = $2;
        my $categoria  = $3;
        my $model      = $4;

        if ($model =~ /^$selectedmodels$/ && $infinitiu !~ /^hackejar$/) {   #models més freqüents

            if ( $model =~ /^cantar$/ && !Flexio::apostrofa_masculi($infinitiu) ) {
                print $ofh "$infinitiu/0\n";   # model especial sense apostrofació: cantar, iodar, halar, etc. No serveix per a "hackejar", perquè no és del model "cantar" sinó "envejar"
            }
            else {
                print $ofh "$infinitiu/$sufixos{$model}\n"; #$apostrofainfinitiu\n";
            }

            # participi femení singular amb l'
            if ( $infinitiu =~ /^h?[aeo]/ ) {
                open( my $modelfh, "<:encoding(UTF-8)", $modelsdir . $model . ".model" );
                while ( my $modelline = <$modelfh> ) {
                    if ( $modelline =~ /^(.+) (.+) (.+) (.+) #.*$/ ) {
                        my $forma   = $infinitiu;
                        my $trau    = $1;
                        my $afegeix = $2;
                        my $postag  = $4;
                        if ( $forma =~ /^(.*)$trau$/ ) {
                            $forma = $1;
                        } else {
                            print $ofh "!!!!ERROR en $forma\n";
                        }
                        if ( $afegeix !~ /^0$/ ) {
                            $forma .= $afegeix;
                        }
                        if ( $postag =~ /^V.P..SF.$/ && Flexio::apostrofa_femeni($forma) && $forma !~ /espesa/ )
                        {
                            print $ofh "$forma/vY\n";
                        }
                    }
                }
                close($modelfh);
            }
        } else {  # DESPLEGA EL VERB AMB TOTES LES SEVES FORMES
            open( my $modelfh, "<:encoding(UTF-8)", $modelsdir . $model . ".model" );
                LINE: while ( my $modelline = <$modelfh> ) {
                    if ( $modelline =~ /^(.+) (.+) (.+) (.+) #.*$/ ) {
                        my $forma   = $infinitiu;
                        my $trau    = $1;
                        my $afegeix = $2;
                        my $postag  = $4;
                        if ( $forma =~ /^(.*)$trau$/ ) {
                            $forma = $1;
                        } else {
                            print $ofh "!!!!ERROR en $forma\n";
                        }
                        if ( $afegeix !~ /^0$/ ) {
                            $forma .= $afegeix;
                        }

                        my $afixos = "";

                        #Elimina accentuació valenciana del diccionari general
                        if ($general) {
                            next LINE if ( $postag =~ /^V.P.*$/ && $forma =~ /és$/ );
                            next LINE if ( $postag =~ /^V.N.*/ && $forma =~ /é(ixer|nyer|ncer)$/ && $forma !~ /^(cr|acr|decr|n|p|recr|ren|sobrecr|sobren)éixer$/ );
                            next LINE if ( $forma =~ /éie[mu]$/ );
                            next LINE if ( $forma =~ /^(apreh|apr|carv|compr|corpr|def|dep|desapr|desp|despr|depr|empr|exp|malpr|malv|mampr|of|repr|retrov|rev|salpr|sobrepr|sorpr|susp|ullpr)én$/  );
                            #<!-- Cas molt rar que no es té en compte: "revén" és vàlid en accentuació general com a imperatiu de revenir. No és vàlid si ve de revendre.  -->
                        }


                       
                        # PROCLÍTICS
                        if (Flexio::apostrofa_masculi($forma)) {
                            if ( $postag =~ /^(V.[NG].*|V.P..SM.)$/ ) {
                                $afixos .= "vY"; 
                            } elsif ( $postag =~ /^(V.P..P..)$/ ) {
                                $afixos .= "Y"; 
                            } elsif ( $postag =~ /^V.P..SF.$/ ) {
                                if (Flexio::apostrofa_femeni($forma)) {
                                    $afixos .= "vY";
                                } else {
                                    $afixos .= "Y";
                                }

                            } elsif ( $postag =~ /^(V.[SI].*)$/ ) {
                                $afixos .= "Z";
                            }
                        }


                        # ENCLÍTICS 
                        if ( $postag =~ /^V.N.*$/ ) {
                            if ( $forma =~ /[^e]$/ ) {
                                $afixos .= "C";    #infinitiu acabat en consonant
                            }
                            else {
                                $afixos .= "D";    #infinitiu acabat en vocal
                            }
                        }
                        elsif ( $postag =~ /^V.G.*$/ ) {
                            $afixos .= "C";            #gerundi
                        }
                        elsif ( $postag =~ /^V.M.*$/ ) {
                            if ( $forma =~ /[aeiï]$/ ) {
                                $afixos .= "D";    #imperatiu acabat en vocal: a, e, i, ï
                            }
                            else {
                                $afixos .= "C";    #imperatiu acabat en consonat o u
                            }
                        }

                        print $ofh "$forma/$afixos\n";
                    }
                }
                close($modelfh);



        }
    }
}
close($ofh);
close($fh);
