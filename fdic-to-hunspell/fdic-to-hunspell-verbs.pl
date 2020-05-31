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

#llegeix nom dels models i assigna sufix hexadeximal 01..9B
foreach my $file (@files) {
    $file = decode( "utf8", $file );
    next if ( $file !~ /^$modelsdir$selectedmodels\.model$/ );
    $modelscount++;
    my $sufix = sprintf( "%02X", $modelscount );
    my $infinitiu = $file;
    $infinitiu =~ s/$modelsdir(.*)\.model/$1/;
    $sufixos{$infinitiu} = $sufix;
}

open( my $fh,  "<:encoding(UTF-8)", $f1 );
open( my $ofh, ">:encoding(UTF-8)", $out );
my %formes = ();
while ( my $line = <$fh> ) {
    chomp($line);
    next if ($line =~ /^#/);
    if ( $line =~ /^([^#]+)(er|re|ir|ar|r)=categories:(.+?);model:(.+?);/ ) {
        my $infinitiu  = $1 . $2;
        my $terminacio = $2;
        my $categoria  = $3;
        my $model      = $4;

        if ($infinitiu =~ /^aguar$/) { #exclòs: forma secundària i molt problemàtica
            next;
        }

        if ($model =~ /^$selectedmodels$/ && $infinitiu !~ /^hackejar$/) {   #models més freqüents

            if ( $model =~ /^cantar$/ && !Flexio::apostrofa_masculi($infinitiu) ) {
                print $ofh "$infinitiu/00\n";   # model especial sense apostrofació: cantar, iodar, halar, etc. No serveix per a "hackejar", perquè no és del model "cantar" sinó "envejar"
            }
            else {
                print $ofh "$infinitiu/$sufixos{$model}\n"; #$apostrofainfinitiu\n";
            }

            # participi femení singular amb l'
            if ( $infinitiu =~ /^h?[aeo]/ ) {
                open( my $modelfh, "<:encoding(UTF-8)", $modelsdir . $model . ".model" );
                while ( my $modelline = <$modelfh> ) {
                    next if ($modelline =~ /^#/);
                    if ( $modelline =~ /^(.+) (.+) (.+) (.+) #.*$/ ) {
                        my $forma   = $infinitiu;
                        my $trau    = $1;
                        my $afegeix = $2;
                        my $postag  = $4;
                        if ( $forma =~ /^(.*)$trau$/ ) {
                            $forma = $1;
                        } else {
                            print $ofh "!!!!ERROR 2 en $forma: $modelline\n";
                        }
                        if ( $afegeix !~ /^0$/ ) {
                            $forma .= $afegeix;
                        }
                        if ( $postag =~ /^V.P..SF.$/ && Flexio::apostrofa_femeni($forma) && $forma !~ /espesa/ )
                        {
                            print $ofh "$forma/_V_Y\n";
                        }
                    }
                }
                close($modelfh);
            }
        } else {  # DESPLEGA EL VERB AMB TOTES LES SEVES FORMES
            open( my $modelfh, "<:encoding(UTF-8)", $modelsdir . $model . ".model" );
                LINE: while ( my $modelline = <$modelfh> ) {
                    next if ($modelline =~ /^#/);
                    if ( $modelline =~ /^(.+) (.+) (.+) (.+) #.*$/ ) {
                        my $forma   = $infinitiu;
                        my $trau    = $1;
                        my $afegeix = $2;
                        my $postag  = $4;
                        if ( $forma =~ /^(.*)$trau$/ ) {
                            $forma = $1;
                        } else {
                            print $ofh "!!!!ERROR 3 en $forma: $modelline\n";
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
                                $afixos .= "_v_Y"; 
                            } elsif ( $postag =~ /^(V.P..P..)$/ ) {
                                $afixos .= "_Y"; 
                            } elsif ( $postag =~ /^V.P..SF.$/ ) {
                                if (Flexio::apostrofa_femeni($forma)) {
                                    $afixos .= "_v_Y";
                                } else {
                                    $afixos .= "_Y";
                                }

                            } elsif ( $postag =~ /^(V.[SI].*)$/ ) {
                                $afixos .= "_Z";
                            }
                        }


                        # ENCLÍTICS 
                        if ( $postag =~ /^V.N.*$/ ) {
                            if ( $forma =~ /[^e]$/ ) {
                                $afixos .= "_C";    #infinitiu acabat en consonant
                            }
                            else {
                                $afixos .= "_D";    #infinitiu acabat en vocal
                            }
                        }
                        elsif ( $postag =~ /^V.G.*$/ ) {
                            $afixos .= "_C";            #gerundi
                        }
                        elsif ( $postag =~ /^V.M.*$/ ) {
                            if ( $forma =~ /[aeiï]$/ ) {
                                $afixos .= "_D";    #imperatiu acabat en vocal: a, e, i, ï
                            }
                            else {
                                $afixos .= "_C";    #imperatiu acabat en consonat o u
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
