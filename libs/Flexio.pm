package Flexio;
use utf8;
use Text::Unaccent::PurePerl qw(unac_string);



# Genera el plural a partir del singular.
# En alguns casos cal saber el gènere.
sub plural {
    #my $senseaccents = "[^àèéíòóú]";
    my $paraula=$_[0];
    my $genere_resultat = defined $_[1] ? $_[1] : 'M';
    my $genere_origen = defined $_[2] ? $_[2] : 'M';

    #depenen del gènere: les foxs, les sequaces, infelices, ingúixes, 
    # però: unes contrabaixos, unes guardaboscs/guardaboscos, unes malvapeixos
    if ($genere_resultat =~ /^F$/ && $paraula !~ /bosc$/) {
	if ($genere_origen =~ /^F$/) {
	    $paraula=~s/^([^àèéíòóú]+[çx])$/$1s/; # falçs calçs larinxs (paraula aguda)
	}
	if ($genere_origen =~ /^M$/) {
	    $paraula=~s/^([^àèéíòóú]+)ç$/$1ces/; # sequaç sequaces (paraula aguda)
	    $paraula=~s/^([^àèéíòóú]+)([aeou]ix|tx)$/$1$2os/; # malvapeixos, contrabaixos,orotxos
	}
	$paraula=~s/^([^àèéíòóú]+x)$/$1s/; # les floxs (paraula aguda)
    } else {
	$paraula=~s/([^àèéíòóú]s)$/$1os/; # quars quarsos, tens tensos
	$paraula=~s/^([^àèéíòóú]+[çx])$/$1os/; # annex annexos (paraula aguda)
    }

    $paraula=~s/([çx])$/$1s/; # índex índexs (plana o esdrúixola)
    $paraula=~s/(\d+)a$/$1es/; #ordinals amb xifres
    $paraula=~s/^([^àéèíòóúïüaeiou]+[aeiou])$/$1ns/;     #monosíl·labs acabats amb vocal: blens, bruns...
    $paraula=~s/gua$/gües/;
    $paraula=~s/qua$/qües/;
    $paraula=~s/ca$/ques/;
    $paraula=~s/ga$/gues/;
    $paraula=~s/ça$/ces/;
    $paraula=~s/ja$/ges/;
    $paraula=~s/([^qg][aeou])ís$/$1ïsos/; #país països
    $paraula=~s/([aeo])ús$/$1üsos/;
    $paraula=~s/([^qg][aeou])í$/$1ïns/; #babuí babuïns
    $paraula=~s/([aeo])ú$/$1üns/;
    if ($paraula=~ /^.*([àéèíóòú])n?$/) { # cançó cançons
	my $terminacio=&unac_string($1)."ns";
	$paraula=~s/[àéèíóòú]n?$/$terminacio/;
    }
    if ($paraula=~ /^.*([àéèíóòú])s$/) { #abús abusos
	my $terminacio=&unac_string($1)."sos";
	$paraula=~s/[àéèíóòú]s$/$terminacio/;
    }
    $paraula=~s/([qrtpdfgjklbmhieoucvwzy])$/$1s/; 
    $paraula=~s/([^ei]n)$/$1s/; 

    #excepcions paraules planes -en -in
    $paraula=~s/^([^àéèíòóú]*)u([^àéèíòóúïüaeiou]+[ie])n$/$1ú$2ns/; #acúfens drúmlins, però espècimen(s)
    $paraula=~s/^([^àéèíòóú]*)e([^àéèíòóúïüaeiou]+)en$/$1è$2ens/; #al·lergen al·lèrgens 
    $paraula=~s/^([^àéèíòóú]*)o([^àéèíòóúïüaeiou]+)en$/$1ò$2ens/; #open òpens
    $paraula=~s/^([^àéèíòóú]*)a([^àéèíòóúïüaeiou]+[ie])n$/$1à$2ns/;
    $paraula=~s/^([^àéèíòóú]*)i(qu|[^àéèíòóúïüaeiou]+)en$/$1í$2ens/; #líquens hímens

    # -en -in agudes
    $paraula=~s/([aeiou][ie]n)$/$1s/; # ain ains, green greens
    $paraula=~s/^([^àéèíòóúïüaeiou]+[ei]n)$/$1s/;   #monosíl·labs acabats amb -en -in: nens, nins, skins, 

    # -en -in esdrúixoles: espècimens
    $paraula=~s/([àéèíòóú].*[aeiou][^àéèíòóúïüaeiou]+[ie]n)$/$1s/;

    $paraula=~s/a$/es/;
    return $paraula;
}

# General el masculí plural a partir del femení

sub pluralMasc_del_fem {
    my $paraula=$_[0];
    $paraula =~ s/xa$/xos/;    
    $paraula =~ s/sa$/sos/;
    $paraula =~ s/na$/ns/;
    $paraula =~ s/a$/es/;
    return $paraula;
}

# Genera el singular a partir del plural.
# Només per a alguns casos.
sub singular {
    my $paraula=$_[0];
    $paraula=~s/gües$/gua/;
    $paraula=~s/qües$/qua/;
    $paraula=~s/ques$/ca/;
    $paraula=~s/gues$/ga/;
    $paraula=~s/ces$/ça/;
    $paraula=~s/ges$/ja/;
    $paraula=~s/es$/a/; #ha d'anar el primer
    $paraula=~s/s$//;
    return $paraula;
}

# Genera masculí plural a partir de dues formes
sub mascplural_partintdeduesformes {
    my $ms=$_[0];
    my $fs=$_[1];

    if ($ms =~ /^$fs$/) {
	$mp=Flexio::plural($ms); # aborigen
    }
    elsif ($ms =~ /.+([àéèíóòú]|[aàeéèiíoóòuú][sn]|ix)$/) {
	$mp=Flexio::pluralMasc_del_fem($fs);
    } else {
	$mp=Flexio::plural($ms);
    }
    return $mp;
}

# A partir de "aalenià -ana" torna "aaleniana"

sub desplega_femeni_amb_guionet {
    my $mot_masc = $_[0];
    my $term_fem = $_[1];

    my $arrel = $mot_masc;
    my $mot_fem = $term_fem;  # Si no hi ha guionet, serà la forma definitiva
    my $trobat = 1;
    
    if ($term_fem =~ /^-/) {
	$term_fem =~ s/-//;
	if ( $term_fem =~ /^a$/ ) {
	    $arrel=~s/[eoa]$//;
	    $mot_fem=$arrel.$term_fem;
	    $found=1;
	}
	else {
	    my $nTerm_fem=&unac_string($term_fem);
	    my $nMot_masc=&unac_string($mot_masc);
	    $nTerm_fem =~ /^(.).*$/;
	    my $firstLetterTerm=$1;
            #La terminació femenina s'ha d'afegir a partir de la vocal tònica.
            #Fem que la forma femenina varie entre 0 i 2 caràcters més que la masculina.
            #És un pegat per a no haver de calcular la síl·laba tònica.
            #A voltes fins i tot és més efectiu (sensoriomotor -motriu, tracofrigi -frígia).
	    my $lenTerm1=length($nTerm_fem)-1; if ($lenTerm1<0) {$lenTerm1=0;}
	    my $lenTerm2=length($nTerm_fem)-3; if ($lenTerm2<0) {$lenTerm2=0;}
	    $nMot_masc =~ /^(.+)$firstLetterTerm.{$lenTerm2,$lenTerm1}$/;
	    my $lenArrel=length($1);
	    $mot_masc =~ /^(.{$lenArrel}).*$/; #recupera alguna dièresi (caïnià)
	    $arrel=$1;
	    $mot_fem=$arrel.$term_fem;	    
	    $found=1;
            #Si la diferència entre masculí i femení és de més de dos caràcters.
            #Error probable.
	    if ( abs(length($mot_fem)-length($mot_masc))>2) {
		$trobat = 0; 
	    }
	}
    }
    return ($mot_fem, $trobat);
}

# Retorna 1 si un mot masculí s'ha d'apostrofar
sub apostrofa_masculi {
    my $mot = $_[0];
    if ($mot =~ /^h?[aeiouàèéíòóú]/ && $mot !~ /^(h?[ui][aeioàèéóòu].+|[aeio]|host)$/) {
	return 1;
    }
    return 0;
}



# Retorna 1 si un mot femení s'ha d'apostrofar amb "l'"
sub apostrofa_femeni {
    my $mot = $_[0];
    if ($mot =~ /^(h?[aeoàèéíòóú].*|h?[ui][^aeiouàèéíòóúüï]+([aeiou]s?|[ei]n)|urbs|URSS|UJI|11a)$/ && $mot !~ /^(ouija|host|ira|inxa|[aeiou]|efa|hac|ela|ema|en|ena|ene|er|erra|erre|essa|una)$/) {
	return 1;
    }
    return 0;
}


1;
