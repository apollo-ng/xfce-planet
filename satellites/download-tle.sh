#!/bin/sh

# ISS (LEO) ####################################################################

wget http://www.celestrak.com/NORAD/elements/stations.txt --no-cache -q -O stations.txt > /dev/null 2>&1

if [ -s stations.txt ];
then
    dos2unix stations.txt > /dev/null 2>&1
    echo "$(cat stations.txt | grep -A2 ISS | tail -1 | awk '{print $2;}') \"  ISS\" image=satellites/iss.png transparent={0,0,0} color={255,255,255} altcirc=0 altcirc=45 trail={orbit,-15,5,1}" > iss
    cat stations.txt | grep --no-group-separator -A2 ISS > iss.tle
    rm stations.txt
fi

# Iridium (LEO) ################################################################

wget http://www.celestrak.com/NORAD/elements/iridium.txt --no-cache -q -O iridium.txt > /dev/null 2>&1

if [ -s iridium.txt ];
then
    dos2unix iridium.txt > /dev/null 2>&1
    mv iridium.txt iridium.tle
    cat iridium.tle | grep IRIDIUM > .iridium.tmp
    echo "" > iridium
    while read in;
    do
        SAT=$(cat iridium.tle | grep --no-group-separator -A2 "${in:0:10}" | tail -1 | awk '{print $2;}' )
        echo "${SAT} \"  ${in:8:10}\" image=satellites/sat.png transparent={0,0,0} color={117,137,12} fontsize=9 trail={orbit,-5,0,1}" >> iridium
    done < .iridium.tmp
    rm .iridium.tmp
fi


# Classified/Spy/Surveilance/Military (mostly LEO) #############################

get_sats_by_name () {

    IN_TLE=$1
    SAT_NAME=$2
    TLE_NAME=$3

    if [ -s ${TLE_NAME} ];
    then
        echo "" > ${TLE_NAME}
    fi

    cat ${IN_TLE} | grep --no-group-separator -A2 ${SAT_NAME} > ${TLE_NAME}.tle
    cat ${TLE_NAME}.tle | grep ${SAT_NAME} > .${SAT_NAME}.tmp

    while read in;
    do
        SAT=$(cat ${TLE_NAME}.tle | grep -A2 "$in" | tail -1 | awk '{print $2;}' )
        echo "${SAT} \"  $in\" image=satellites/sat.png transparent={0,0,0} color={117,137,12} fontsize=9 trail={orbit,-5,0,1}" >> ${TLE_NAME}
    done < .${SAT_NAME}.tmp

    rm .${SAT_NAME}.tmp
}

wget https://www.prismnet.com/~mmccants/tles/classfd.zip --no-cache -q -O classfd.zip > /dev/null 2>&1

if [ -s classfd.zip ];
then
    unzip -o classfd.zip > /dev/null 2>&1
    dos2unix classfd.tle > /dev/null 2>&1

    # Pick up all birds with USA* designators
    get_sats_by_name classfd.tle USA usa

    # Pick up all birds with NOSS* designators
    get_sats_by_name classfd.tle NOSS noss

    rm classfd.*

fi

# Geostationary (GEO) ##########################################################

wget http://www.celestrak.com/NORAD/elements/geo.txt --no-cache -q -O geo.txt > /dev/null 2>&1

if [ -s geo.txt ];
then
    dos2unix geo.txt > /dev/null 2>&1
    mv geo.txt geo.tle
    awk '{if (count++%3==0) print $0;}' geo.tle > .geo.tmp
    echo "" > geo
    while read in;
    do
        SAT=$(cat geo.tle | grep --no-group-separator -A2 "${in}" | tail -1 | awk '{print $2;}' )
        echo "${SAT} \"  ${in}\" image=satellites/sat.png transparent={0,0,0} color={117,137,12} fontsize=9 trail={orbit,-5,0,1}" >> geo
    done < .geo.tmp
    rm .geo.tmp
fi


echo "$(date +%Y%m%d-%h%m)" > .last_updated
