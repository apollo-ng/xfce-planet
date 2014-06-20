#!/bin/bash

ORIGINSHA=$(wget https://raw.githubusercontent.com/apollo-ng/cloudmap/master/global.sha256 --no-cache -q -O - | awk {'print $1;'})
LOCALSHA=$(sha256sum clouds.jpg | awk {'print $1;'})

if [ ${ORIGINSHA} != ${LOCALSHA} ]; 
then
    wget -O global.jpg --no-cache -q https://raw.githubusercontent.com/apollo-ng/cloudmap/master/global.jpg?${ORIGINSHA} 
    
    NEWSHA=$(sha256sum global.jpg | awk {'print $1;'})
   
    if [ $NEWSHA == $ORIGINSHA ];
    then
        mv global.jpg clouds.jpg
    else
        rm global.jpg
    fi
fi
