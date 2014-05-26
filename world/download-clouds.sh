#!/bin/bash

wget --no-cache http://xplanetclouds.com/free/coral/clouds_2048.jpg
convert -resize 5400x2700 clouds_2048.jpg clouds.jpg
rm clouds_2048.jpg
