ID="dev.dictionaries.addons.mozilla.org"
TAG="-test"
VERSION="9.9.9"
current_time=$(date "+%Y%m%d%H%M%S")

DEV=".dev.$current_time"



while getopts "pv:" opt; do
    case "$opt" in
    p)  ID="dictionaries.addons.mozilla.org"; TAG=""; DEV="";
        ;;
    v)  VERSION=$OPTARG;
        ;;
    esac
done

echo $ID
echo $TAG
echo $VERSION

cd xpi/ca

cp config_build.sh.pre config_build.sh
cp install.rdf.pre install.rdf

sed -i -e s/\#\#VERSION\#\#/$VERSION/g config_build.sh
sed -i -e s/\#\#DEV\#\#/$DEV/g config_build.sh

sed -i -e s/\#\#ID\#\#/$ID/g install.rdf
sed -i -e s/\#\#TAG\#\#/$TAG/g install.rdf
sed -i -e s/\#\#VERSION\#\#/$VERSION/g install.rdf

rm -rf dictionaries
mkdir dictionaries
cp -rf ../../resultats/hunspell/catalan.aff dictionaries/ca.aff
cp -rf ../../resultats/hunspell/catalan.dic dictionaries/ca.dic
../../build-xpi.sh config_build.sh
rm -rf dictionaries
rm -rf install.rdf config_build.sh

# Valencia
cd ../ca-valencia

cp config_build.sh.pre config_build.sh
cp install.rdf.pre install.rdf

sed -i -e s/\#\#VERSION\#\#/$VERSION/g config_build.sh
sed -i -e s/\#\#DEV\#\#/$DEV/g config_build.sh

sed -i -e s/\#\#ID\#\#/$ID/g install.rdf
sed -i -e s/\#\#TAG\#\#/$TAG/g install.rdf
sed -i -e s/\#\#VERSION\#\#/$VERSION/g install.rdf

rm -rf dictionaries
mkdir dictionaries
cp -rf ../../resultats/hunspell/catalan-valencia.aff dictionaries/ca-ES-valencia.aff
cp -rf ../../resultats/hunspell/catalan-valencia.dic dictionaries/ca-ES-valencia.dic
../../build-xpi.sh config_build.sh
rm -rf dictionaries

rm -rf install.rdf config_build.sh

