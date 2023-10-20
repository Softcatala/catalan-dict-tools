#!/usr/local/bin/perl
use strict;
#use warnings;
use autodie;
use utf8;

binmode( STDOUT, ":utf8" );

my %words;
my %wordsUpper;
my %words_to_ignore;


#open( my $fh,  "<:encoding(UTF-8)", "words-to-ignore.txt");
#while (my $line = <$fh>) {
#	chomp($line);
#	$words_to_ignore{$line}=1;
#}

my $timeinit = time;

#close($fh);
my $i=0;

foreach my $fp (glob("$ARGV[0]")) {
print "file: $fp\n";
open(my $fh,  "<:encoding(UTF-8)",$fp);
while (my $line = <$fh>) {
    $i = $i +1;
    if ($i % 100000 == 0) {
	print "$i\t";
        print time-$timeinit;
	print " s";
	print "\n";
    }
   chomp($line);                                                           # Remove line returns
   $line = lc($line);                                                     # Change to lower case
   #$line = ' ' . $line . ' ';                                              # Add spaces
   #print "$line\n";
   #$line =~ s/[…`´‘\(\),\.:;!\?„“\"¡¿\s\—\=\*\/\d«»“”\[\]%_\{\}]+/ /g;                # Remove punctuation
   $line =~ s/’/'/g; 
   $line =~ s/[^a-zA-ZàáèéìíòóùúïüÀÁÈÉÌÍÒÓÙÚÏÜ·'\-]+/ /g;                # Remove punctuation
   
   #print "$line\n";
   my @tokens = split (" ", $line );                                       # Put words into an array
      foreach my $word (@tokens) {
      	 #if ($word =~ /^\*/) {
      	 	#if ($word =~ /^.[A-Z]/) {
      	 	#	$wordsUpper{$word} = $wordsUpper{$word} + 1;                             # Put word and word frequency in hash
      	 	#} else {
            $word =~ s/^['\-]+(.*)$/$1/;
            $word =~ s/^(.*)['\-]+$/$1/;
	         #$word = lc $word;
            if ($word =~ /['\-]/) {
               $words{$word} = $words{$word} + 1;                             # Put word and word frequency in hash   
            }
      	   
      	 	#}
         #}
      }
}
close ($fh);
}

# Display the results
 
open(my $fh,  ">>:encoding(UTF-8)", $ARGV[1]);
foreach my $word (sort { $words{$b} <=> $words{$a} } keys %words) {                          # Sort the word hash
   print $fh "$word, $words{$word}.\n";                         # Print word and frequency
}
close ($fh);

#open(my $fh,  ">:encoding(UTF-8)", "concordance-upper");
#foreach my $word (sort { $wordsUpper{$b} <=> $wordsUpper{$a} } keys %wordsUpper) {                          # Sort the word hash
#   print $fh "$word, $wordsUpper{$word}.\n";                         # Print word and frequency
#}
#close ($fh);
