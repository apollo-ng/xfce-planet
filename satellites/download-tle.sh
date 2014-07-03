#!/bin/sh

download_tle () {
    wget $1 -q -T 5 --no-cache -O $2 > /dev/null 2>&1
}

# ISS (LEO) ####################################################################

download_tle http://www.celestrak.com/NORAD/elements/stations.txt stations.txt

if [ -s stations.txt ];
then
    dos2unix stations.txt > /dev/null 2>&1
    echo "$(cat stations.txt | grep -A2 ISS | tail -1 | awk '{print $2;}') \"  ISS\" image=satellites/iss.png transparent={0,0,0} color={255,255,255} altcirc=0 color={0,255,0} altcirc=45 trail={orbit,-15,5,1}" > iss
    cat stations.txt | grep --no-group-separator -A2 ISS > iss.tle
    rm stations.txt
fi

# Iridium (LEO) ################################################################

download_tle http://www.celestrak.com/NORAD/elements/iridium.txt iridium.txt

if [ -s iridium.txt ];
then
    dos2unix iridium.txt > /dev/null 2>&1
    mv iridium.txt iridium.tle
    cat iridium.tle | grep IRIDIUM > .iridium.tmp
    echo "" > iridium
    while read in;
    do
        SAT=$(cat iridium.tle | grep --no-group-separator -A2 "$(echo "${in}" | awk '{print $1 " " $2;}' )" | tail -1 | awk '{print $2;}' )
        echo "${SAT} \"  $(echo "${in}" | awk '{print $2 " " $3;}')\" image=satellites/sat.png transparent={0,0,0} color={12,50,117} fontsize=9 trail={orbit,-5,0,1}" >> iridium
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
        SAT=$(cat ${TLE_NAME}.tle | grep -A2 "${in}" | tail -1 | awk '{print $2;}' )
        echo "${SAT} \"  ${in}\" image=satellites/sat.png transparent={0,0,0} color={117,137,12} fontsize=9 trail={orbit,-5,0,1}" >> ${TLE_NAME}
    done < .${SAT_NAME}.tmp

    rm .${SAT_NAME}.tmp
}

download_tle https://www.prismnet.com/~mmccants/tles/classfd.zip classfd.zip

if [ -s classfd.zip ];
then
    unzip -o classfd.zip > /dev/null 2>&1
    dos2unix classfd.tle > /dev/null 2>&1

    # Pick up all birds with USA* designators
    get_sats_by_name classfd.tle USA usa

    # Pick up all birds with NOSS* designators
    get_sats_by_name classfd.tle NOSS noss

    # Pick up all birds with DSP* designators
    get_sats_by_name classfd.tle DSP dsp

    # Pick up all birds with Milstar* designators
    get_sats_by_name classfd.tle Milstar milstar

    # Have a look at satellites/classfd.tle to
    # find more birds you may extract here as well

    rm classfd.zip
fi

# Geostationary (GEO) ##########################################################

# Remember that you need to zoom out your view (change RAD) to see these :)

download_tle http://www.celestrak.com/NORAD/elements/geo.txt geo.txt

if [ -s geo.txt ];
then
    dos2unix geo.txt > /dev/null 2>&1
    mv geo.txt geo.tle
    awk '{if (count++%3==0) print $0;}' geo.tle > .geo.tmp
    echo "" > geo
    while read in;
    do
        SAT=$(cat geo.tle | grep --no-group-separator -A2 "${in}" | tail -1 | awk '{print $2;}' )
        echo "${SAT} \"  ${in}\" image=satellites/sat.png transparent={0,0,0} color={117,137,12} fontsize=9}" >> geo
    done < .geo.tmp
    rm .geo.tmp
fi

echo "$(date +%Y%m%d-%h%m)" > .last_updated
