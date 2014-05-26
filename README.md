# xfce-planet

A collection of resources and scripts to feed and manage xplanet's weather
and satellite (two-line elements) files.

It was born out of the necessity to get xplanet to work with xfce or
other compositing window managers, where xplanet cannot take over
(or you don't want it to) the root window to draw on.

Of course, it should be possible to use this with just minor tweaks
for any other window manager.

![alt text](https://raw.githubusercontent.com/chron0/xfce-planet/master/example_output.jpg "Example output")

## Installation

### Dependencies

Make sure the following tools are available on your system:

* xplanet
* convert (imagemagick)
* dos2unix (some TLE's have some really weird chars that break xplanet)
* unzip
* wget
* bash

### Cloning the Repo

    $ cd
    $ git clone https://github.com/chron0/xfce-planet.git
    $ ln -s xfce-planet .xplanet

## Usage

    $ cd .xplanet
    $ ./xfce-planet.sh

Or simply put it into your local .xinitrc/autostart system

Then select xplanet_output.png as your background image in xfce.

The default sats are a subset of known USA/NRO spy satellites to remind
oneself how far this totalitarian surveillance has come and the ISS
as a contrast showing a glimpse of global co-operation.

Goes along very well with the experimental ISS HD payload live stream:

http://www.ustream.tv/channel/iss-hdev-payload
