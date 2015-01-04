use strict;
use warnings;
use autodie;
use utf8;

binmode( STDOUT, ":utf8" );

my $f1 = $ARGV[0];
my $dir_eixida = $ARGV[1]."/";
open( my $fh_input, "<:encoding(UTF-8)", $f1 );

my $noms = "noms.txt";
my $adjectius = "adjectius.txt";
my $verbs = "verbs.txt";
my $adv_ment = "adverbis-ment.txt";
my $adverbis = "adverbis.txt";
my $nomspropis = "nomspropis.txt";
my $resta = "resta.txt";

my $o_noms = "ordenats-noms.txt";
my $o_adjectius = "ordenats-adjectius.txt";
my $o_verbs = "ordenats-verbs.txt";
my $o_adv_ment = "ordenats-adverbis-ment.txt";
my $o_adverbis = "ordenats-adverbis.txt";
my $o_nomspropis = "ordenats-nomspropis.txt";
my $o_resta = "ordenats-resta.txt";

open( my $fh_o_noms, ">:encoding(UTF-8)", $dir_eixida.$o_noms );
open( my $fh_o_adjectius, ">:encoding(UTF-8)", $dir_eixida.$o_adjectius );
open( my $fh_o_verbs, ">:encoding(UTF-8)", $dir_eixida.$o_verbs );
open( my $fh_o_adv_ment, ">:encoding(UTF-8)", $dir_eixida.$o_adv_ment );
open( my $fh_o_nomspropis, ">:encoding(UTF-8)", $dir_eixida.$o_nomspropis );
open( my $fh_o_adverbis, ">:encoding(UTF-8)", $dir_eixida.$o_adverbis );
open( my $fh_o_resta, ">:encoding(UTF-8)", $dir_eixida.$o_resta );

open( my $fh_noms, ">:encoding(UTF-8)", $dir_eixida.$noms );
open( my $fh_adjectius, ">:encoding(UTF-8)", $dir_eixida.$adjectius );
open( my $fh_verbs, ">:encoding(UTF-8)", $dir_eixida.$verbs );
open( my $fh_adv_ment, ">:encoding(UTF-8)", $dir_eixida.$adv_ment );
open( my $fh_nomspropis, ">:encoding(UTF-8)", $dir_eixida.$nomspropis );
open( my $fh_adverbis, ">:encoding(UTF-8)", $dir_eixida.$adverbis );
open( my $fh_resta, ">:encoding(UTF-8)", $dir_eixida.$resta );


while(my $line = <$fh_input>){  
    chomp($line);
    if ($line =~ /^([^ +]+) ([^ +]+) (NC.+)$/)
    { 
	print $fh_noms "$1 $2 $3\n"; 
	print $fh_o_noms "$2 $3 $1\n"; 
    }
    elsif ($line =~ /^([^ ]+) ([^ ]+) (A.+)$/)
    { 
	print $fh_adjectius "$1 $2 $3\n";
	print $fh_o_adjectius "$2 $3 $1\n"; 
    }
    elsif ($line =~ /^([^ ]+) ([^ ]+) (V.+)$/)
    { 
	print $fh_verbs "$1 $2 $3\n"; 
	print $fh_o_verbs "$2 $3 $1\n"; 
    }
    elsif ($line =~ /^([^ ]+ment) ([^ ]+) (RG)$/)
    { 
	print $fh_adv_ment "$1 $2 $3\n"; 
	print $fh_o_adv_ment "$2 $3 $1\n"; 
    }
    elsif ($line =~ /^([^ ]+) ([^ ]+) (RG)$/)
    { 
	print $fh_adverbis "$1 $2 $3\n"; 
	print $fh_o_adverbis "$2 $3 $1\n"; 
    }
    elsif ($line =~ /^([^ ]+) ([^ ]+) (NP.+)$/)
    { 
	print $fh_nomspropis "$1 $2 $3\n"; 
	print $fh_o_nomspropis "$2 $3 $1\n"; 
    } 
    elsif ($line =~ /^([^ ]+) ([^ ]+) (.+)$/)
    {
	print $fh_resta "$1 $2 $3\n"; 
	print $fh_o_resta "$2 $3 $1\n"; 
    }
}
close($fh_input); 

close($fh_noms);
close($fh_adjectius);
close($fh_verbs);
close($fh_adv_ment);
close($fh_nomspropis);
close($fh_adverbis);
close($fh_resta);

close($fh_o_noms);
close($fh_o_adjectius);
close($fh_o_verbs);
close($fh_o_adv_ment);
close($fh_o_nomspropis);
close($fh_o_adverbis);
close($fh_o_resta);
