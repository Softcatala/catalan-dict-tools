use strict;
use warnings;
use autodie;
use utf8;

binmode( STDOUT, ":utf8" );

my $f1 = "/home/jaume/diccionaris/catalan-dict-lt/diccionari.txt";
my $noms = "noms.txt";
my $adjectius = "adjectius.txt";
my $verbs = "verbs.txt";
my $adv_ment = "adverbis-ment.txt";
my $adverbis = "adverbis.txt";
my $nomspropis = "nomspropis.txt";
my $resta = "resta.txt";

open( my $fh_input, "<:encoding(UTF-8)", $f1 );

open( my $fh_noms, ">:encoding(UTF-8)", $noms );
open( my $fh_adjectius, ">:encoding(UTF-8)", $adjectius );
open( my $fh_verbs, ">:encoding(UTF-8)", $verbs );
open( my $fh_adv_ment, ">:encoding(UTF-8)", $adv_ment );
open( my $fh_nomspropis, ">:encoding(UTF-8)", $nomspropis );
open( my $fh_adverbis, ">:encoding(UTF-8)", $adverbis );
open( my $fh_resta, ">:encoding(UTF-8)", $resta );


while(my $line = <$fh_input>){  
    chomp($line);
    if ($line =~ /^([^ +]+) ([^ +]+) (NC.+)$/)
    { 
	print $fh_noms "$1 $2 $3\n" 
    }
    elsif ($line =~ /^([^ ]+) ([^ ]+) (A.+)$/)
    { 
	print $fh_adjectius "$1 $2 $3\n" 
    }
    elsif ($line =~ /^([^ ]+) ([^ ]+) (V.+)$/)
    { 
	print $fh_verbs "$1 $2 $3\n" 
    }
    elsif ($line =~ /^([^ ]+ment) ([^ ]+) (RG)$/)
    { 
	print $fh_adv_ment "$1 $2 $3\n" 
    }
    elsif ($line =~ /^([^ ]+) ([^ ]+) (RG)$/)
    { 
	print $fh_adverbis "$1 $2 $3\n" 
    }
    elsif ($line =~ /^([^ ]+) ([^ ]+) (NP.+)$/)
    { 
	print $fh_nomspropis "$1 $2 $3\n" 
    } 
    elsif ($line =~ /^([^ ]+) ([^ ]+) (.+)$/)
    {
	print $fh_resta "$1 $2 $3\n" 
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
