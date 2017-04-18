use strict;
use warnings;
use autodie;
use utf8;
require "../libs/Flexio.pm";

binmode(STDOUT, ":utf8");

my $diccionarifile="resultats/wordlist/wordlist.txt";
#my $directory="/home/jaume/diccionaris/corpus-sense-seleccio/";
my $directory ="/mnt/mydata/test-corpus/corpus/";

my $outerrors = "errors.txt";
my $out1 = "unigrams.txt";
my $out2 = "bigrams.txt";
my $out3 = "trigrams.txt";

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

opendir(DIR, $directory ) or die "cannot open directory";
@docs = grep(/\.txt$/,readdir(DIR));

my $numlines=0;

FOO: {foreach $file (@docs) {
    open(my $fh, "<:encoding(UTF-8)", $directory.$file);
    print "Analitzant: ".$directory.$file."\n";
    while($line = <$fh>){

	$numlines++;
	if ($numlines % 100000 == 0) {
	    print "Línies analitzades: $numlines\n";
	}
#	if ($numlines==1000000) {
#	    last FOO;
#	}

	#Canvia apòstrof tipogràfic per apòstrof recte
	$line =~ s/’/'/g;
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

		    if (exists($unigrams{$word2})) {
			$unigrams{$word2}++;
		    } else {
			$unigrams{$word2}=1;
		    }
=pod
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
=cut
		    $prevPrevWord=$prevWord;
		    $prevWord=$word2;
	    }
	}
    }
    close($fh);
}
}
closedir (DIR);

print "Analitzades $wordcount paraules.\n";
print "Escrivint els resultats...\n";
#Escriu els resultats

my $k;
my $ofh;

my $n1grams = keys %unigrams;
my $n2grams = keys %bigrams;
my $n3grams = keys %trigrams;
print "Nombre d'1-grams: $n1grams \n";
print "Nombre de 2-grams: $n2grams \n";
print "Nombre de 3-grams: $n3grams \n";

open($ofh, ">:encoding(UTF-8)", $out1);
foreach $k (sort {$unigrams{$b} <=> $unigrams{$a} } keys %unigrams) {
    print $ofh "$k\t$unigrams{$k}\n"  if $unigrams{$k}>20;
}
close($ofh);

open($ofh, ">:encoding(UTF-8)", $outerrors);
foreach $k (sort {$errors{$b} <=> $errors{$a} } keys %errors) {
    print $ofh "$k\t$errors{$k}\n";
}
close($ofh);

open($ofh, ">:encoding(UTF-8)", $out2);
foreach $k (sort {$bigrams{$b} <=> $bigrams{$a} } keys %bigrams) {
    print $ofh "$k\t$bigrams{$k}\n" if $bigrams{$k}>20;
}
close($ofh);

open($ofh, ">:encoding(UTF-8)", $out3);
foreach $k (sort {$trigrams{$b} <=> $trigrams{$a} } keys %trigrams) {   
    print $ofh "$k\t$trigrams{$k}\n" if $trigrams{$k}>50;
}
close($ofh);

print "Acabat.\n";
exit 0;
