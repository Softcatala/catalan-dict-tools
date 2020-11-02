git commit -a -m "$1"
git pull --rebase
git push origin master
#cp resultats/lt/diccionari.txt resultats/lt/diccionari.old
cd morfologik-lt
./extrau-novetats.sh