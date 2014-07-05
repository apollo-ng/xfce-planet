#!/bin/sh

PATH=$PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Get latest remote checksum
ORIGINSHA=$(wget https://raw.githubusercontent.com/apollo-ng/cloudmap/master/global.sha256 -q -T 5 --no-cache -O - | awk {'print $1;'})

# Generate local checksum
if [ -e clouds.jpg ];
then
    LOCALSHA=$(sha256sum clouds.jpg | awk {'print $1;'})
fi

# Check if we're behind origin
if [ "${ORIGINSHA}" != "${LOCALSHA}" ];
then

    # Download raw global.jpg from master
    wget https://raw.githubusercontent.com/apollo-ng/cloudmap/master/global.jpg?${ORIGINSHA} --no-cache -q -T 5 -O global.jpg

    # Generate checksum of downloaded file
    NEWSHA=$(sha256sum global.jpg | awk {'print $1;'})

    # Check if download's chksum corresponds to to origin
    if [ "$NEWSHA" = "$ORIGINSHA" ];
    then
        mv global.jpg clouds.jpg
    else
        rm global.jpg
    fi
fi
