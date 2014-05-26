#!/bin/bash

OUT="combined"
rm ${OUT} "${OUT}.tle"

# Get latest Space Station TLEs

wget http://www.celestrak.com/NORAD/elements/stations.txt
dos2unix stations.txt
echo "$(cat stations.txt | grep -A2 ISS | tail -1 | awk '{print $2;}') \"  ISS\" image=iss.png transparent={0,0,0} color={255,255,255} trail={orbit,-15,5,0.1}" >> ${OUT}
cat stations.txt >> ${OUT}.tle

# Classified/Spy/Surveilance/Military

TLE="classfd.tle"

wget https://www.prismnet.com/~mmccants/tles/classfd.zip
unzip -o classfd.zip > /dev/null 2>&1
dos2unix ${TLE} > /dev/null 2>&1

cat ${TLE} | grep USA > .sat.tmp

while read in; do
    SAT=$(cat ${TLE} | grep -A2 "$in" | tail -1 | awk '{print $2;}' )
    echo "${SAT} \"  $in\" image=sat.png transparent={0,0,0} color={117,137,12} fontsize=9 trail={orbit,-5,0,1}" >> ${OUT}
done < .sat.tmp

cat ${TLE} | grep NOSS > .sat.tmp

while read in; do
    SAT=$(cat ${TLE} | grep -A2 "$in" | tail -1 | awk '{print $2;}' )
    echo "${SAT} \"  $in\" image=sat.png transparent={0,0,0} color={117,137,12} fontsize=9 trail={orbit,-5,0,1}" >> ${OUT}
done < .sat.tmp

cat ${TLE} >> ${OUT}.tle

rm .sat.tmp classfd.zip
