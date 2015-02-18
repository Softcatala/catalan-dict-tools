use strict;
use warnings;
use autodie;
use utf8;
require "libs/Flexio.pm";

binmode(STDOUT, ":utf8");

my $diccionarifile="resultats/wordlist/wordlist.txt";
my $directory="/home/jaume/diccionaris/corpus-sense-seleccio/";

my $outerrors = "ngrams/errors.txt";
my $out1 = "ngrams/unigrams.txt";
my $out2 = "ngrams/bigrams.txt";
my $out3 = "ngrams/trigrams.txt";

my $outsql = "ngrams/database_ca.sql";

my %unigrams = ();
my %bigrams = ();
my %trigrams = ();
my $word;
my $word2;
my $line;
my @matches;
my $wordcount=0;
my @docs;
my $file;

my %diccionari =();
my %errors =();
open(my $fh, "<:encoding(UTF-8)", $diccionarifile )  or die "cannot open file";
    while($line = <$fh>)
    {
	chomp($line);
        if ($line =~ /^([^ ]+)$/)
        {
	    my $mot=$1;
            if (!exists($diccionari{$mot}))
            {
                $diccionari{$mot}=1;
            }
        }
    }
close($fh);

opendir(DIR, $directory ) or die "cannot open directory";
@docs = grep(/\.txt$/,readdir(DIR));

my $numlines=0;

foreach $file (@docs) {
    open(my $fh, "<:encoding(UTF-8)", $directory.$file);
    print "Analitzant: ".$directory.$file."\n";
    while($line = <$fh>){

	$numlines++;
	if ($numlines % 100000 == 0) {
	    print "Línies analitzades: $numlines\n";
	}
	#if ($numlines==1000000) {
	#    last;
	#}

	$line =~ s/\[\[[a-z]{2,6}:.*?\]\]//g;
	$line =~ s/\[http.*? (.+)\]/$1/g;
	$line =~ s/\[\[:?(Category|Categoria|Categoría|Catégorie|Kategorie):.*?\]\]//g;
	$line =~ s/(File|Fitxer|Fichero|Ficheiro|Fichier|Datei):.*?\.(png|jpg|svg|jpeg|tiff|gif|PNG|JPG|SVG|JPEG|TIFF|GIF)\|((thumb|miniatur)\|)?((right|left)\|)?//g;

	$line =~ s/\[\[.*?\|(.+)\]\]/$1/g;

	$line =~ s/\{\{(.*?)\}\}//g;
	$line =~ s/\[\[(.*?)\]\]/$1/g;

	#Canvia apòstrof tipogràfic per apòstrof recte
	$line =~ s/’/'/g;
	$line =~ s/ŀ/l·/g;
	$line =~ s/Ŀ/L·/g;
	$line =~ s/l•l/l·l/g;
	$line =~ s/L•L/L·L/g;
	#print "LINIA $line\n";
	my @sentences = split(/[\.!?,;\(\)\[\]]/, $line);

	for my $sentence (@sentences) {
	    #print "FRASE $sentence\n";
	    my $prevWord="";
	    my $prevPrevWord="";
	    @matches = ($sentence =~ /$Flexio::carac+/g);
#	    my $sentencepos=0;
	    for $word (@matches)
	    {
		$wordcount++;
#		$sentencepos++;
		#print "PARAULA $word\n";
		$word =~ s/^['\-]+//;
		$word =~ s/['\-]+$//; 
		$word2=$word;
		if (!exists($diccionari{$word2}) && exists($diccionari{lc($word2)})) {
		    $word2=lc($word2);
		}
		
		if (exists($diccionari{$word2})) {
		    if (exists($unigrams{$word2})) {
			$unigrams{$word2}++;
		    } else {
			$unigrams{$word2}=1;
		    }
		    # bigram
		    if ($prevWord =~ /.+/) {
			if (exists($bigrams{$prevWord." ".$word2})) {
			    $bigrams{$prevWord." ".$word2}++;
			} else {
			    $bigrams{$prevWord." ".$word2}=1;
			}
			# trigram
			if ($prevPrevWord =~ /.+/) {
			    if (exists($trigrams{$prevPrevWord." ".$prevWord." ".$word2})) {
				$trigrams{$prevPrevWord." ".$prevWord." ".$word2}++;
			    } else {
				$trigrams{$prevPrevWord." ".$prevWord." ".$word2}=1;
			    }
			}
			
		    }
		    $prevPrevWord=$prevWord;
		    $prevWord=$word2;
		} else {   
		    if (exists($errors{$word})) {
			$errors{$word}++;
		    } else {
			$errors{$word}=1;
		    }
		    $prevPrevWord="";
		    $prevWord="";
		}
	    }
	}
    }
    close($fh);
}
closedir (DIR);

print "Analitzades $wordcount paraules.\n";
print "Escrivint els resultats...\n";
#Escriu els resultats

my $k;
my $ofh;
my $escaped;

open(my $ofhsql, ">:encoding(UTF-8)", $outsql);
print $ofhsql "PRAGMA foreign_keys=OFF;\n";
print $ofhsql "BEGIN TRANSACTION;\n";
print $ofhsql "CREATE TABLE _1_gram (word TEXT, count INTEGER, UNIQUE(word) );\n";
print $ofhsql "CREATE TABLE _2_gram (word_1 TEXT, word TEXT, count INTEGER, UNIQUE(word_1, word) );\n";
print $ofhsql "CREATE TABLE _3_gram (word_2 TEXT, word_1 TEXT, word TEXT, count INTEGER, UNIQUE(word_2, word_1, word) );\n";

open($ofh, ">:encoding(UTF-8)", $out1);
foreach $k (sort {$unigrams{$b} <=> $unigrams{$a} } keys %unigrams) {
    print $ofh "$k\t$unigrams{$k}\n";
    $escaped = $k;
    $escaped =~ s/'/''/g;
    print $ofhsql "INSERT INTO \"_1_gram\" VALUES('$escaped',$unigrams{$k});\n";
}
close($ofh);

open($ofh, ">:encoding(UTF-8)", $outerrors);
foreach $k (sort {$errors{$b} <=> $errors{$a} } keys %errors) {
    print $ofh "$k\t$errors{$k}\n";
}
close($ofh);

open($ofh, ">:encoding(UTF-8)", $out2);
foreach $k (sort {$bigrams{$b} <=> $bigrams{$a} } keys %bigrams) {
    print $ofh "$k\t$bigrams{$k}\n" if $bigrams{$k}>1;
    $escaped = $k;
    $escaped =~ s/'/''/g;
    $escaped =~ s/ /','/g;
    print $ofhsql "INSERT INTO \"_2_gram\" VALUES('$escaped',$bigrams{$k});\n" if $bigrams{$k}>5;
}
close($ofh);

open($ofh, ">:encoding(UTF-8)", $out3);
foreach $k (sort {$trigrams{$b} <=> $trigrams{$a} } keys %trigrams) {   
    print $ofh "$k\t$trigrams{$k}\n" if $trigrams{$k}>2;
    $escaped = $k;
    $escaped =~ s/'/''/g;
    $escaped =~ s/ /','/g;
    print $ofhsql "INSERT INTO \"_3_gram\" VALUES('$escaped',$trigrams{$k});\n" if $trigrams{$k}>6;
}
close($ofh);

print $ofhsql "COMMIT;\n";

close($ofhsql);

print "Acabat.\n";
exit 0;
