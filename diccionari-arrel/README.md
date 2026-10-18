# Etiquetatge usat en el diccionari

Les etiquetes són, en general, les definides en el projecte Freeling.
Vegeu: https://freeling-user-manual.readthedocs.io/en/latest/tagsets/tagset-ca/

Per exemple, "cap" tindrà aquestes etiquetes:

wordform lemma postag 

cap cabre VMIP1S0Z
cap cabre VMIP3S00
cap cabre VMM02S00
cap cap DI0CS0
cap cap NCCS000
cap cap PI0CS000
cap cap SPS00
cap capar VMIP1S0B

## Marques dialectals en els verbs

La vuitena posició de les etiquetes verbals no és definida en Freeling. És un afegit per a diferenciar variants dialectals. El significat és:

0 = totes
C = central
V = valencià
B = balear
X = central + valencià
Y = central + balear
Z = balear + valencià,

dígits 1-7: jocs de terminacions de l'imperfet de subjuntiu
1 = -és (cantés)
2 = -essis, -éssim, éssiu, -essin; -issis, -íssim, -íssiu, -issin
3 = -ara, -ares, -àrem, -àreu, -aren; -era, -eres, -érem, -éreu, -eren ; -era, -eres, -érem, -éreu, -eren; -ira, -ires, -írem, -íreu, -iren
4 = -assis, -àssim, -àssiu, -assin
5 = -esses, -éssem, -ésseu, -essen
6 = -asses, -àssem, -àsseu, -assen
7 = -às

Aquesta és una possible distribució de formes per a les principals variants geogràfiques. Diferents llibres d'estil poden recomanar diferents solucions.  

central: [0CXY12]
valencià: [0VXZ13567]
balear: [0BYZ1247]