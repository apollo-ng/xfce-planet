#!/bin/bash

BASEDIR="${HOME}/.xplanet"

# Default Configuration
# Create your own .local.cfg to override these

OUTPUT="${BASEDIR}/xplanet_output.png"

# View

RES="1600x1200"
RAD="41"

# Observer position (Eurocentric View)

LAT="35"
LON="11"

# Window Manager background image reload trigger

WM_RELOAD_CMD="xfdesktop --reload"

# FIXME: On laptops, the timeout should be dynamically changed based on
# the ACPI state - so that a system running on battery automatically
# decreases the update frequency (SLEEP) to enhance battery endurance
# when off-grid.

SLEEP=5

# Load local config (.local.cfg) to override above settings

if [ -e ${BASEDIR}/.local.cfg ];
then
    source ${BASEDIR}/.local.cfg
fi

########################################################################
# Main Loop

while true
do
    # Download weather image if local copy is older than 3h ############

    if test "$(find ${BASEDIR}/world/clouds.jpg -mmin +180)";
    then
        cd ${BASEDIR}/world/
        ${BASEDIR}/world/download-clouds.sh
        cd ..
    fi

    # Download new TLE package if local elements are older than 24h ####

    if test "$(find ${BASEDIR}/satellites/combined -mmin +1440)";
    then
        cd ${BASEDIR}/satellites/
        ${BASEDIR}/satellites/download-tle.sh
        cd ..
    fi

    # Check/Link the appropriate VE/BM texture for this month ##########

    MONTH=$(date +%m)
    LINK=$(ls -al ${BASEDIR}/world/earth.jpg | awk {'print $11;'})

    if [ ${MONTH} != ${LINK:0:2} ];
    then
        cd ${BASEDIR}/world/
        rm earth.jpg
        ln -s ${MONTH}.jpg earth.jpg
        cd ..
    fi

    # Call xplanet #####################################################

    xplanet \
            -latitude ${LAT} -longitude ${LON}                         \
            -geometry ${RES}                                           \
            -radius ${RAD}                                             \
            -quality 90                                                \
            -font ${BASEDIR}/fonts/pf_tempesta_seven.ttf               \
            -fontsize 8                                                \
            -starmap ${BASEDIR}/stars/BSC                              \
            -searchdir ${BASEDIR}                                      \
            -output ${OUTPUT}                                          \
            -pango                                                     \
            -num_times 1                                               \
            -verbosity -1

    # Tell the window manager to update the background image ###########

    ${WM_RELOAD_CMD}

    # Go to sleep

    sleep ${SLEEP}

done
