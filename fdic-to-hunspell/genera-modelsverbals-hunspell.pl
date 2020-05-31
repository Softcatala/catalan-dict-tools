#!/bin/perl
use strict;
use warnings;
use autodie;
use utf8;
use Encode qw(decode);
require "./libs/Flexio.pm";
no locale;

binmode( STDOUT, ":utf8" );

my $general = 0;    #Si és 1, versió "general" del corrector
if ( grep( /^-catalan$/, @ARGV ) ) {
    $general = 1;
}

my $modelsdir = $ARGV[0] . "/";
my @files     = glob( $modelsdir . "*.model" );
my @regles;
@files = sort (@files);
my $modelscount = 0;
my $afffile     = $ARGV[1];

my $selectedmodels = "(abalisar|anul·lar|adossar|capbussar|anquilosar|acarnissar|adobassar|lligar|ofrenar|lloar|menjar|començar|traduir|abominar|pregar|crear|trencar|servir|envejar|cantar)";

open( my $ofh, ">:encoding(UTF-8)", $afffile );
foreach my $file (@files) {
    $file = decode( "utf8", $file );
    next if ( $file !~ /^$modelsdir$selectedmodels\.model$/ );
    $modelscount++;
    my $sufix = sprintf( "%02X", $modelscount );
    my $infinitiu = $file;
    $infinitiu =~ s/$modelsdir(.*)\.model/$1/;
    open( my $modelfh, "<:encoding(UTF-8)", $file );
    my $compta = 0;
  LINE: while ( my $modelline = <$modelfh> ) {
        next if ($modelline =~ /^#/);
        if (   $modelline =~ /^(.+) (.+) (.+) (.+) #.*$/
            && $modelline !~ /IGNOREHUNSPELL/ )
        {
            my $trau          = $1;
            my $afegeix       = $2;
            my $condiciofinal = $3;
            my $postag        = $4;
            my $forma         = $infinitiu;
            if ( $forma =~ /^(.*)$trau$/ ) {
                $forma = $1;
            }
            else {
                print $ofh "!!!!ERROR en $forma: $modelline\n";
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
            
            if ( $postag =~ /^(V.[NG].*|V.P..SM.)$/ ) {
                $afixos .= "_v_Y"; 
            } elsif ( $postag =~ /^(V.P..P..)$/ ) {
                $afixos .= "_Y"; 
            } elsif ( $postag =~ /^V.P..SF.$/ ) {
                $afixos .= "_Y"; # l'apostrofació l' (_v) es posa a part
            } elsif ( $postag =~ /^(V.[SI].*)$/ ) {
                $afixos .= "_Z";
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

            $compta++;
            push( @regles, "SFX $sufix $trau $afegeix/$afixos $condiciofinal" );
        }
    }

    print $ofh "\n# Model de conjugació: $infinitiu\n";
    print $ofh "SFX $sufix Y $compta\n";
    for my $liniaregla (@regles) {
        print $ofh "$liniaregla\n";
    }
    undef @regles;
    close($modelfh);

}

close($ofh);
