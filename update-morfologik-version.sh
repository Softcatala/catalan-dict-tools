dictVers=2.27
unzip ~/.m2/repository/org/softcatala/catalan-pos-dict/${dictVers}/catalan-pos-dict-${dictVers}.jar
cp org/languagetool/resource/ca/* morfologik-lt/
rm -rf org/
rm -rf META-INF/