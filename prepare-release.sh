VERSION="9.9.9"
DATE=$(date "+%d/%m/%Y")

while getopts "v:" opt; do
    case "$opt" in
    v)  VERSION=$OPTARG;
        ;;
    esac
done

echo $VERSION

./build-lt.sh
./build-hunspell.sh -v "$VERSION" 
./build-oxt-all.sh -p -v "$VERSION"
./build-xpi-all.sh -p -v "$VERSION"

mkdir resultats/release
rm -rf resultats/release/*

cp LICENSE resultats/release/
cp release-notes_en.txt resultats/release/
cp resultats/hunspell/* resultats/release/

cp oxt/ca-valencia/ca-valencia.$VERSION.oxt resultats/release/
cp oxt/ca/ca.$VERSION.oxt resultats/release/
cp xpi/ca-valencia/ca-valencia.$VERSION.xpi resultats/release/
cp xpi/ca/ca.$VERSION.xpi resultats/release/

cd resultats/release
zip ca.$VERSION-all.zip *
zip ca.$VERSION-hunspell.zip catalan.aff catalan.dic LICENSE release-notes_en.txt
zip ca-valencia.$VERSION-hunspell.zip catalan-valencia.aff catalan-valencia.dic LICENSE release-notes_en.txt

rm LICENSE
rm release-notes_en.txt
rm *.dic
rm *.aff

cd ..
echo "Paquets per a release en resultats/release"
