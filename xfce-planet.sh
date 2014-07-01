#!/bin/sh

BASEDIR="${HOME}/.xplanet"

# Default Configuration
# Edit .local.cfg to override these

OUTPUT="${BASEDIR}/xplanet_output.png"

# Set your monitor resolution and viewing distance

RES="1600x1200"
RAD="41"

# Observer position (Eurocentric View)

LAT="30"
LON="11"

# Fonts

FONT=${BASEDIR}/fonts/pf_tempesta_seven.ttf
FONTSIZE=10

# Window Manager background image reload trigger

# XFCE:     "xfdesktop --reload"   tells xfce to reload the desktop
# LightDM:  ""                     image is automatically updated (Thanks to Marco)
# Other:    "?"                    We appreciate your feedback

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

# Create a fresh default config for xplanet
# xplanet doesn't appreciate ~/ or $HOME in default config
#
# Add/Remove satellite_file=${BASEDIR}/satellites/[your_tle_conf]
# to the DEFCFG as needed.


DEFCFG=$(cat << EOF
satellite_file=${BASEDIR}/satellites/iss
satellite_file=${BASEDIR}/satellites/noss
satellite_file=${BASEDIR}/satellites/usa
#satellite_file=${BASEDIR}/satellites/iridum
#marker_file=${BASEDIR}/updatelabel

[earth]
"Earth"
map=${BASEDIR}/world/earth.jpg
night_map=${BASEDIR}/world/night.jpg
bump_map=${BASEDIR}/world/bump.jpg
specular_map=${BASEDIR}/world/specular.jpg
cloud_map=${BASEDIR}/world/clouds.jpg
bump_scale=1
shade=10
EOF
)

echo "${DEFCFG}" > ${BASEDIR}/default

########################################################################
# Main Loop

while true
do
    # Download weather image if local copy is older than 3h ############

    if [ ! -e ${BASEDIR}/world/clouds.jpg ] || test "$(find ${BASEDIR}/world/clouds.jpg -mmin +60)";
    then
        cd ${BASEDIR}/world/
        ${BASEDIR}/world/download-clouds.sh
        cd ..
    fi

    # Download new TLE package if local elements are older than 24h ####

    if test "$(find ${BASEDIR}/satellites/.last_updated -mmin +1440)";
    then
        cd ${BASEDIR}/satellites/
        ${BASEDIR}/satellites/download-tle.sh
        cd ..
    fi

    # Check/Link the appropriate VE/BM texture for this month ##########

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

    # Call xplanet #####################################################

    nice -n 19 xplanet                                                 \
            -latitude ${LAT} -longitude ${LON}                         \
            -geometry ${RES}                                           \
            -radius ${RAD}                                             \
            -quality 90                                                \
            -font ${FONT}                                              \
            -fontsize ${FONTSIZE}                                      \
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
