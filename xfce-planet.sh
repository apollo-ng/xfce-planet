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

check_dep () {
    echo -n "Checking for $1 ... "
    type -P $1 &>/dev/null && continue || {
        echo "NOT INSTALLED";
        exit 1
    }
    echo "OK"
}

if [ -r ${BASEDIR}/xfce-planet.conf ];
then
    # Load config
    . ${BASEDIR}/xfce-planet.conf
else
    # Likely to be a new install - check deps
    echo "Hmm, it seems, I have made it to another box... sweet :)"
    echo "Let me just check if we've got everything we'll need..."
    check_dep find
    check_dep awk
    check_dep grep
    check_dep dos2unix
    check_dep wget
    check_dep unzip
    check_dep convert
    check_dep xplanet

    # Deploy config file from sample and load it
    cp xfce-planet.conf.sample xfce-planet.conf
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

TLE_COUNT=0

for tle_file in $(find ${BASEDIR}/satellites/ -name "*.tle");
do
    FILE=$(basename "${tle_file}")
    if [ "${FILE%.*}" != "iss" ];
    then
        AR_TLE[$TLE_COUNT]=${FILE%.*}
        TLE_COUNT=TLE_COUNT+1
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
        MONTH_OF_FILE=$(echo $LINK | awk '{ string=substr($0, 1, 2); print string;}')
        
        if [ "${MONTH}" != "$MONTH_OF_FILE" ];
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
            DELAY_COUNT=DELAY_COUNT+1
        else
            COUNTER=COUNTER+1
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
