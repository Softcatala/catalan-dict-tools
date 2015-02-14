cd xpi/ca
rm -rf dictionaries
mkdir dictionaries
cp -rf ../../resultats/hunspell/catalan.aff dictionaries/ca.aff
cp -rf ../../resultats/hunspell/catalan.dic dictionaries/ca.dic
../../build-xpi.sh config_build.sh

cd ../ca-valencia
rm -rf dictionaries
mkdir dictionaries
cp -rf ../../resultats/hunspell/catalan-valencia.aff dictionaries/ca-ES-valencia.aff
cp -rf ../../resultats/hunspell/catalan-valencia.dic dictionaries/ca-ES-valencia.dic
../../build-xpi.sh config_build.sh


