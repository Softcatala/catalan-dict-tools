use strict;
use warnings;
use autodie;
use utf8;
require "libs/Flexio.pm";

binmode(STDOUT, ":utf8");

my $diccionarifile="resultats/wordlist/wordlist.txt";

my $directory="/media/OS/Users/jaume/Documents/Llengua_catalana/Corpus/arreglat/";


#my $f1 = "tot.txt";
#my $f2 = "adjectius.txt";
#my $f1 = "toponims_sense_comuns.txt";
my $out = "ngrams/unigrams.txt";
my $out2 = "ngrams/errors.txt";
my $out3 = "formes_trigrams.txt";
my %unigrams = ();
my %bigrams = ();
my %trigrams = ();
my $word;
my $word2;
my $line;
my @matches;

my $currentPos="";
my $prevPos="";
my $prevPrevPos="";

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
	#print "LINIA $line\n";
	my @sentences = split(/[\.!?,;\(\)\[\]]/, $line);

	for my $sentence (@sentences) {
	    #print "FRASE $sentence\n";
	    @matches = ($sentence =~ /$Flexio::carac+/g);
	    for $word (@matches)
	    {
		#print "PARAULA $word\n";
		$word =~ s/^['\-]+//;
		$word =~ s/['\-]+$//; 
		$word2=$word;
		if (!exists($diccionari{$word2}) && exists($diccionari{lc($word2)}))
		{
		    $word2=lc($word2);
		}
		
		if (exists($diccionari{$word2}))
		{
		    if (exists($unigrams{$word2}))
		    {
			$unigrams{$word2}++;
		    }
		    else
		    {
			$unigrams{$word2}=1;
		    }
		}
		else 
		{   
		    if (exists($errors{$word}))
		    {
			$errors{$word}++;
		    }
		    else
		    {
			$errors{$word}=1;
		    }
		}
		
=pod
            if (exists($bigrams{$prevPos." ".$currentPos}))
            {
            $bigrams{$prevPos." ".$currentPos}++;
            }
            else
            {
            $bigrams{$prevPos." ".$currentPos}=1;
            }
            if (exists($trigrams{$prevPrevPos." ".$prevPos." ".$currentPos}))
            {
            $trigrams{$prevPrevPos." ".$prevPos." ".$currentPos}++;
            }
            else
            {
            $trigrams{$prevPrevPos." ".$prevPos." ".$currentPos}=1;
            }


            $prevPrevPos=$prevPos;
            $prevPos=$currentPos;
=cut
        }
	}

    }

    close($fh);
}
my $k;
my $ofh;

open($ofh, ">:encoding(UTF-8)", $out);
foreach $k (sort {$unigrams{$b} <=> $unigrams{$a} } keys %unigrams)
{
    print $ofh "$k\t$unigrams{$k}\n";
}
close($ofh);


open($ofh, ">:encoding(UTF-8)", $out2);
foreach $k (sort {$errors{$b} <=> $errors{$a} } keys %errors)
{
    print $ofh "$k\t$errors{$k}\n";
}
close($ofh);

closedir (DIR);

=pod
open($ofh, ">:encoding(UTF-8)", $out2);
foreach $k (sort {$bigrams{$a} <=> $bigrams{$b} }
keys %bigrams)
{
print $ofh "$k $bigrams{$k}\n";
}
close($ofh);

open($ofh, ">:encoding(UTF-8)", $out3);
foreach $k (sort {$trigrams{$a} <=> $trigrams{$b} }
keys %trigrams)
{
print $ofh "$k $trigrams{$k}\n";
}
close($ofh);

=cut

