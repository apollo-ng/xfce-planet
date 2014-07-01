#!/bin/sh

BASEDIR="${HOME}/.xplanet"

################################################################################
# INIT                                                                         #
################################################################################

if [ -r ${BASEDIR}/xfce-planet.conf ];
then
    source ${BASEDIR}/xfce-planet.conf
else
    echo "Hmm, it seems, I have made it to another new box... sweet :)"
    echo "Let me just check your system if we got everything we'll need"
    # FIXME: We should have a quick check for utils like
    #     dos2unix
    #     wget
    #     convert
    #     xplanet
    #     unzip
    # here...
    cp xfce-planet.conf.sample xfce-planet.conf
    source ${BASEDIR}/xfce-planet.conf
    echo "I've copied the sample config file to xfce-planet.conf"
fi

# Download new TLE package if local elements are older than 24h ################

if [ ! -e ${BASEDIR}/satellites/.last_updated ] || test "$(find ${BASEDIR}/satellites/.last_updated -mmin +1440)";
then
    cd ${BASEDIR}/satellites/
    ${BASEDIR}/satellites/download-tle.sh
    cd ..
fi

# Pick up the TLEs prepared by download-tle.sh in satellites/ ##################

TLE_COUNT=0

for tle_file in $(find ${BASEDIR}/satellites/ -name "*.tle");
do
    FILE=$(basename "${tle_file}")
    if [ "${FILE%.*}" != "iss" ];
    then
        AR_TLE[$TLE_COUNT]=${FILE%.*}
        let TLE_COUNT=TLE_COUNT+1
    fi
done

COUNTER=0
DELAY_COUNT=0

################################################################################
# MAIN                                                                         #
################################################################################

while true
do
    # Download weather image if local copy is older than 1h ####################

    if [ ! -e ${BASEDIR}/world/clouds.jpg ] || test "$(find ${BASEDIR}/world/clouds.jpg -mmin +60)";
    then
        cd ${BASEDIR}/world/
        ${BASEDIR}/world/download-clouds.sh
        cd ..
    fi

    # Download new TLE package if local elements are older than 24h ############

    if test "$(find ${BASEDIR}/satellites/.last_updated -mmin +1440)";
    then
        cd ${BASEDIR}/satellites/
        ${BASEDIR}/satellites/download-tle.sh
        cd ..
    fi

    # Check/Link the appropriate VE/BM texture for this month ##################

    MONTH=$(date +%m)
    cd ${BASEDIR}/world/

    if [ -e ${BASEDIR}/world/earth.jpg ];
    then
        LINK=$(ls -al ${BASEDIR}/world/earth.jpg | awk {'print $11;'})
        if [ "${MONTH}" != "${LINK:0:2}" ];
        then
            rm earth.jpg
            ln -s ${MONTH}.jpg earth.jpg
        fi
    else
        ln -s ${MONTH}.jpg earth.jpg
    fi

    cd ..

    # Prep xplanets default config for this run ################################

    echo "satellite_file=${BASEDIR}/satellites/iss" > ${BASEDIR}/default
    echo "satellite_file=${BASEDIR}/satellites/${AR_TLE[${COUNTER}]}" >> ${BASEDIR}/default
    echo "${DEFCFG}" >> ${BASEDIR}/default

    # Switch between available tle files with a defined delay ##################

    if [ ${COUNTER} -lt $TLE_COUNT ];
    then
        if [ ${DELAY_COUNT} -lt ${DELAY} ];
        then
            let DELAY_COUNT=DELAY_COUNT+1
        else
            let COUNTER=COUNTER+1
            DELAY_COUNT=0
        fi
    else
        COUNTER=0
    fi

    # Call xplanet #############################################################

    nice -n 19 xplanet                                                         \
            -latitude ${LAT} -longitude ${LON}                                 \
            -geometry ${RES}                                                   \
            -radius ${RAD}                                                     \
            -quality 90                                                        \
            -font ${FONT}                                                      \
            -fontsize ${FONTSIZE}                                              \
            -starmap ${BASEDIR}/stars/BSC                                      \
            -searchdir ${BASEDIR}                                              \
            -output ${OUTPUT}                                                  \
            -pango                                                             \
            -num_times 1                                                       \
            -verbosity -1

    # Tell the window manager to update the background image (if needed) #######

    if [ "${WM_RELOAD_CMD}" != "" ];
    then
        ${WM_RELOAD_CMD}
    fi

    # Go to sleep - The timeout is dynamically changed based on ACPI state
    # so that a system running on battery automatically decreases the update
    # frequency (longer SLEEP) to enhance battery endurance when off-grid.

    if [ -r /sys/class/power_supply/AC/online ];
    then
        if [ $(cat /sys/class/power_supply/AC/online) -eq 1 ];
        then
            sleep ${SLEEP_ON_AC}
        fi
    else
        sleep ${SLEEP_ON_BAT}
    fi

done
