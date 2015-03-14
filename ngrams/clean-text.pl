use strict;
use warnings;
use autodie;
use utf8;
require "../libs/Flexio.pm";

binmode(STDOUT, ":utf8");

my $diccionarifile="../resultats/wordlist/wordlist.txt";
#my $directory="/home/jaume/diccionaris/corpus-sense-seleccio/";
my $directory = $ARGV[0]; #"/home/jaume/diccionaris/wikipedia/";

#my $outerrors = "ngrams/errors.txt";
my $out = "wikipedia-seleccio-net.txt";
#my $out2 = "ngrams/bigrams.txt";
#my $out3 = "ngrams/trigrams.txt";

#my $outsql = "ngrams/database_ca.sql";

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


opendir(DIR, $directory ) or die "cannot open directory";
@docs = grep(/\.txt$/,readdir(DIR));

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

open(my $ofh, ">:encoding(UTF-8)", $out);

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

	FRASE: for my $sentence (@sentences) {
	    #print "FRASE $sentence\n";
	    my $prevWord="";
	    my $prevPrevWord="";
	    @matches = ($sentence =~ /$Flexio::carac+/g);
	    for $word (@matches) {
		#$word=~ /../ &&
		if (!exists($diccionari{$word}) && !exists($diccionari{lc($word)}) ) {
		    next FRASE;
		}  
	    }
	    print $ofh "$sentence\n";
	}
    }
    close($fh);
}
closedir (DIR);

print "Acabat.\n";

