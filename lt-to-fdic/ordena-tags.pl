use strict;
use warnings;
use autodie;
use utf8;

binmode(STDOUT, ":utf8");

my $dir_entrada = "./" ;#$ARGV[0];
my $dir_eixida = "./"  ;#$ARGV[1];

my $f1 = $dir_entrada."/verbal_tags.txt";
my $out = $dir_eixida."/verbal_tags_ordenats.txt";


open(my $fh, "<:encoding(UTF-8)", $f1);
open(my $ofh, ">:encoding(UTF-8)", $out);

my %scores;

while(my $line = <$fh>){
    chomp($line);
    my $type = substr $line, 1, 1;
    my $mode = substr $line, 2, 1;
    my $tense= substr $line, 3, 1;
    my $persona = substr $line, 4, 1;
    my $number = substr $line, 5, 1;
    my $gender = substr $line, 6, 1;
    my $points = 0;

    if ($type =~ /A/) { $points += 300000}
    if ($type =~ /S/) { $points += 200000}
    if ($type =~ /M/) { $points += 100000}


	if ($mode =~ /N/) { $points += 60000}
	if ($mode =~ /G/) { $points += 50000}
	if ($mode =~ /P/) { $points += 40000}
    if ($mode =~ /I/) { $points += 30000}
    if ($mode =~ /S/) { $points += 20000}
    if ($mode =~ /M/) { $points += 10000}

    if ($tense =~ /P/) { $points += 5000}
    if ($tense =~ /I/) { $points += 4000}
    if ($tense =~ /S/) { $points += 3000}
    if ($tense =~ /F/) { $points += 2000}
    if ($tense =~ /C/) { $points += 1000}

    if ($number =~ /S/) { $points += 200}
    if ($number =~ /P/) { $points += 100}

    if ($persona =~ /1/) { $points += 30}
    if ($persona =~ /2/) { $points += 20}
    if ($persona =~ /3/) { $points += 10}

    if ($gender =~ /M/) { $points += 5}
    if ($gender =~ /F/) { $points += 4}

    $scores{$line} = $points;
}

    foreach my $name (sort { $scores{$b} <=> $scores{$a} } keys %scores) {
        printf $ofh "$name\n";
    }
