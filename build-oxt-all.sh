ID="softcatala.catalan.dictionary.dev"
IDvalencian="softcatala.catalan.valencian.dictionary.dev"
TAG="-test"
VERSION="9.9.9"
YEAR=$(date "+%Y")
current_time=$(date "+%Y%m%d%H%M%S")

DEV=".dev.$current_time"



while getopts "pv:" opt; do
    case "$opt" in
    p)  ID="softcatala.catalan.dictionary"; IDvalencian="softcatala.catalan.valencian.dictionary"; TAG=""; DEV="";
        ;;
    v)  VERSION=$OPTARG;
        ;;
    esac
done

echo $ID
echo $TAG
echo $VERSION

# Catalan and Valencian, Thesaurus and Hyphenation. For LibO ('ca' and 'ca-valencia') and AAO ('ca' only)
cd oxt/ca

cp config_build.sh.pre config_build.sh
cp description.xml.pre description.xml
cp dictionaries.xcu.pre dictionaries.xcu
cp package-description.txt.pre package-description.txt
 
sed -i -e s/\#\#VERSION\#\#/$VERSION/g config_build.sh
sed -i -e s/\#\#DEV\#\#/$DEV/g config_build.sh

sed -i -e s/\#\#ID\#\#/$ID/g description.xml description.xml
sed -i -e s/\#\#VERSION\#\#/$VERSION/g description.xml description.xml
sed -i -e s/\#\#VERSION\#\#/$VERSION/g package-description.txt package-description.txt

cp -rf ../../resultats/hunspell/catalan.aff ca.aff
cp -rf ../../resultats/hunspell/catalan.dic ca.dic
cp -rf ../../resultats/hunspell/catalan-valencia.aff ca-ES-valencia.aff
cp -rf ../../resultats/hunspell/catalan-valencia.dic ca-ES-valencia.dic
cp -rf ../hyph/hyph_ca.dic hyph_ca.dic
cp -rf ../hyph/README_hyph_ca.txt README_hyph_ca.txt
cp -rf ../thes/th_ca_ES_v3.dat th_ca_ES_v3.dat
cp -rf ../thes/th_ca_ES_v3.idx th_ca_ES_v3.idx
cp -rf ../thes/README_thes_ca.txt README_thes_ca.txt
cp -rf root_files/LICENSES-en.txt LICENSES-en.txt
cp -rf root_files/LLICENCIES-ca.txt LLICENCIES-ca.txt
cp -rf root_files/SC-logo.png SC-logo.png
cp -rf ../../README.txt README.txt
sed -i -e s/\#\#VERSION\#\#/$VERSION/g README.txt README.txt
sed -i -e s/\#\#YEAR\#\#/$YEAR/g README.txt README.txt


../../build-oxt.sh config_build.sh
rm -rf config_build.sh config_build.sh description.xml dictionaries.xcu package-description.txt


# Valencian, for AOO only (using 'ca' locale)
echo $IDvalencian
echo $TAG
echo $VERSION

cd ../ca-valencia

cp config_build.sh.pre config_build.sh
cp description.xml.pre description.xml
cp dictionaries.xcu.pre dictionaries.xcu
cp package-description.txt.pre package-description.txt
cp -rf root_files/LICENSES-en.txt LICENSES-en.txt
cp -rf root_files/LLICENCIES-ca.txt LLICENCIES-ca.txt
cp -rf root_files/SV-logo.png SV-logo.png
cp -rf root_files/README.txt README.txt
sed -i -e s/\#\#VERSION\#\#/$VERSION/g README.txt README.txt
sed -i -e s/\#\#YEAR\#\#/$YEAR/g README.txt README.txt
 
sed -i -e s/\#\#VERSION\#\#/$VERSION/g config_build.sh
sed -i -e s/\#\#DEV\#\#/$DEV/g config_build.sh

sed -i -e s/\#\#ID\#\#/$IDvalencian/g description.xml description.xml
sed -i -e s/\#\#VERSION\#\#/$VERSION/g description.xml description.xml
sed -i -e s/\#\#VERSION\#\#/$VERSION/g package-description.txt package-description.txt


cp -rf ../../resultats/hunspell/catalan-valencia.aff ca.aff
cp -rf ../../resultats/hunspell/catalan-valencia.dic ca.dic

../../build-oxt.sh config_build.sh
rm -rf config_build.sh config_build.sh description.xml dictionaries.xcu package-description.txt

