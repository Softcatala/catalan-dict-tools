# catalan-dict-tools

Aquest projecte té com a objectiu generar diccionaris en català per al format Hunspell i per al corrector gramatical LanguageTool. 

#### Diccionari arrel

El diccionari arrel (en el directori "diccionari-arrel") conté les dades bàsiques a partir de les quals es construeixen els altres diccionaris. Les paraules estan separades en fitxers per categories gramaticals. Per a aquests fitxers s'usen dos formats diferents segons els casos. 

* Extensió **-fdic.txt**: Per a adjectius, noms i verbs, es fa servir un format de pseudodiccionari que conté informació semblant a la que contenen els diccionaris d'ús comú (sense les deficions): categoria gramatical i les dades necessàries per a flexionar correctament la paraula (model verbal, forma femenina, excepcions de plurals, etc.).
* Extensió **-lt.txt**: Per a adverbis, noms propis i la resta de categories, la informació es manté en el format usat en LanguageTool, que és el mateix que s'usa en els diccionaris [Freeling](http://nlp.lsi.upc.edu/freeling/doc/tagsets/tagset-ca.html). 

#### Scripts
##### build-hunspell.sh

Construeix diccionaris Hunspell en variant general i valenciana a partir del diccionari arrel. 

##### build-lt.sh

Construeix el diccionari amb etiquetatge gramatical per al corrector Languagetool. 

##### make-test-lt-fdic.sh

És un test que converteix el fitxer de LT en format de diccionari; aquest es converteix de nou en format LT i es compara amb el fitxer inicial. 

##### buid-xpi-all.sh
Genera fitxers xpi (compatibles amb el Firefox) a partir dels resultats per al Hunspell.
* ./build-xpi-all.sh -> Genera paquets de desenvolupament (versió 9.9.9)
* ./build-xpi-all.sh -p -v '3.0.0' -> Genera paquets de producció (versió 3.0.0)

##### buid-morfologik-lt.sh
Genera la versió compilada (amb la llibreria Morfologik) del diccionari de LanguageTool. Requereix LanguageTool. 

##### buid-wordlist-from-lt.sh
Genera una llista de totes les paraules possibles, incloent-hi apostrofació i pronoms febles (ex. d'anar-se'n, l'esmentat). Genera ~12 milions de formes (~180 M). És necessari per a algunes aplicacions.

### Per fer
* En el diccionari arrel marcar les fonts d'origen de cada paraula. Això servirà per a comprovar la correcció de les dades.


