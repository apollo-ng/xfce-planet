#!/bin/sh
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

BASEDIR="${HOME}/.xplanet"

################################################################################
# INIT                                                                         #
################################################################################

if [ -r ${BASEDIR}/xfce-planet.conf ];
then
    # Load config
    . ${BASEDIR}/xfce-planet.conf
else
    # Likely to be a new install
    echo "Hmm, it seems, I have made it to another box... sweet :)"
    echo "Let me just check if we've got everything we'll need..."

    # Check Dependencies

    DEPENDENCIES="awk convert dos2unix find grep unzip wget xplanet"

    for i in $DEPENDENCIES;
    do
        echo -n "Checking for $i ... "
        LOC=$(type $i 2>&1 >/dev/null)
        if [ $? -eq 0 ];
        then
            echo "OK"
        else
            echo "NOT FOUND"
            exit 1
        fi
    done

    # Deploy config file from sample and load it
    cp ${BASEDIR}/xfce-planet.conf.sample ${BASEDIR}/xfce-planet.conf
    . ${BASEDIR}/xfce-planet.conf
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

TLE_LIST=$(find ${BASEDIR}/satellites/ -name "*.tle" | grep -v iss.tle)
TLE_COUNT=$(echo $TLE_LIST | wc -w)

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
        MONTH_OF_FILE=$(echo $LINK | awk '{ string=substr($0, 1, 2); print string;}')

        if [ "${MONTH}" != "${MONTH_OF_FILE}" ];
        then
            rm earth.jpg
            ln -s ${MONTH}.jpg earth.jpg
        fi
    else
        ln -s ${MONTH}.jpg earth.jpg
    fi

    cd ..

    # Prep xplanets default config for this run ################################

    LN=$(($COUNTER+1))
    ABS_SATFILE=$(echo $TLE_LIST | cut -d " " -f $LN)
    SATFILE=$(basename  -s .tle "${ABS_SATFILE}")

    echo "satellite_file=${BASEDIR}/satellites/iss" > ${BASEDIR}/default
    echo "satellite_file=${BASEDIR}/satellites/${SATFILE}" >> ${BASEDIR}/default
    echo "${DEFCFG}" >> ${BASEDIR}/default

    # Set viewing distance according to current sat class (leo/geo)

    SAT_TYPE=$(echo $SATFILE | cut -d "_" -f 2)

    if [ "${SAT_TYPE}" = "geo" ];
    then
        VIEW=10
    else
        VIEW=$RAD
    fi

    # Switch between available tle files with a defined delay ##################

    if [ ${COUNTER} -lt ${TLE_COUNT} ];
    then
        if [ ${DELAY_COUNT} -lt ${DELAY} ];
        then
            DELAY_COUNT=$(($DELAY_COUNT+1))
        else
            COUNTER=$((COUNTER+1))
            DELAY_COUNT=0
        fi
    else
        COUNTER=0
    fi

    # Call xplanet #############################################################

    nice -n 19 xplanet                                                         \
            -latitude ${LAT} -longitude ${LON}                                 \
            -geometry ${RES}                                                   \
            -radius ${VIEW}                                                    \
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

    if [ -r /sys/class/power_supply/AC/online -a $(cat /sys/class/power_supply/AC/online) -eq 1 ];
    then
        sleep ${SLEEP_ON_AC}
    else
        sleep ${SLEEP_ON_BAT}
    fi

done
