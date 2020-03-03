#!/bin/bash
# Search query
URLS="$(googler $1 --np -C | grep http | sed '/^[[:space:]]*$/d')"
# Dump plaintext
> texts.txt
for url in $URLS;
do
 #Detect file type
 MIME=$(curl -s -I $url | grep options -v --ignore-case | grep Content-Type --ignore-case)
 echo $MIME
 if [[ $MIME == *"html"* ]]; then
   echo "Dumping $url"
   rm -f tmp.txt tmp2.txt
   links -dump $url > tmp.txt
   echo "To UTF"
   CHARSET="$(file -bi "tmp.txt"|awk -F "=" '{print $2}')"
   iconv -f "$CHARSET" -t utf8 tmp.txt -o tmp2.txt
   cat tmp2.txt >> texts.txt
 fi
done
# Try regexp
declare -a KEYWORDS=("MTBF" "отказ" "Mean time between failures")
for w in "${KEYWORDS[@]}"
do
 cat texts.txt | grep --ignore-case "$w" | grep -Eo '[+-]?[0-9]+([,.][0-9]+)?'
done
#Cleanup
rm -f tmp.txt tmp2.txt
