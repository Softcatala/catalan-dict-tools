VERSION="9.9.9"
DATE=$(date "+%d/%m/%Y")
YEAR=$(date "+%Y")

while getopts "v:" opt; do
    case "$opt" in
    v)  VERSION=$OPTARG;
        ;;
    esac
done

echo $VERSION

mkdir -p resultats/release
rm -rf resultats/release/*

./build-lt.sh
./build-hunspell.sh -v "$VERSION" 
./build-oxt-all.sh -p -v "$VERSION"
./build-xpi-all.webext.sh "$VERSION" resultats/release/

cp LICENSE resultats/release/
cp README.txt resultats/release/
sed -i -e s/\#\#VERSION\#\#/$VERSION/g resultats/release/README.txt resultats/release/README.txt
sed -i -e s/\#\#YEAR\#\#/$YEAR/g resultats/release/README.txt resultats/release/README.txt

cp gpl-2.0.txt resultats/release/
cp lgpl-2.1.txt resultats/release/
cp release-notes_en.txt resultats/release/
cp resultats/hunspell/* resultats/release/

cp oxt/ca-valencia/ca-valencia.$VERSION.oxt resultats/release/
cp oxt/ca/ca.$VERSION.oxt resultats/release/

cd resultats/release
zip ca.$VERSION-all.zip *
zip ca.$VERSION-hunspell.zip catalan.aff catalan.dic LICENSE README.txt release-notes_en.txt gpl-2.0.txt lgpl-2.1.txt
cp ca.$VERSION-hunspell.zip ca-hunspell.zip 
zip ca-valencia.$VERSION-hunspell.zip catalan-valencia.aff catalan-valencia.dic LICENSE README.txt release-notes_en.txt gpl-2.0.txt lgpl-2.1.txt
cp ca-valencia.$VERSION-hunspell.zip ca-valencia-hunspell.zip

rm LICENSE
rm *.txt
rm *.dic
rm *.aff

cd ..
echo "Paquets per a release en resultats/release"
