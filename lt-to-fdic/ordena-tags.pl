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
    my $variant = substr $line, 7, 1;
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

    if ($persona =~ /1/) { $points += 50}
    if ($persona =~ /2/) { $points += 40}
    if ($persona =~ /3/) { $points += 30}

    if ($gender =~ /M/) { $points += 20}
    if ($gender =~ /F/) { $points += 19}

    if ($variant =~ /0/) { $points += 15}
    if ($variant =~ /Z/) { $points += 14}
    if ($variant =~ /Y/) { $points += 13}
    if ($variant =~ /X/) { $points += 12}
    if ($variant =~ /C/) { $points += 11}
    if ($variant =~ /V/) { $points += 10}
    if ($variant =~ /B/) { $points += 9}
    if ($variant =~ /1/) { $points += 8}
    if ($variant =~ /2/) { $points += 7}
    if ($variant =~ /3/) { $points += 6}
    if ($variant =~ /4/) { $points += 5}
    if ($variant =~ /5/) { $points += 4}
    if ($variant =~ /6/) { $points += 3}

    $scores{$line} = $points;
}

    foreach my $name (sort { $scores{$b} <=> $scores{$a} } keys %scores) {
        printf $ofh "$name\n";
    }
