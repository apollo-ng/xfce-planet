#!/bin/bash

wget --no-cache https://github.com/apollo-ng/cloudmap/blob/master/global.jpg 
cp global.jpg clouds.jpg
rm global.jpg
#convert -resize 5400x2700 clouds_2048.jpg clouds.jpg
#rm clouds_2048.jpg
