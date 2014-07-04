# xfce-planet

A simple and easy to understand structure & collection of pre-selected resources
and scripts to feed and control xplanet's high-definition textures, near-realtime
cloudmap and satellite two-line elements (TLE) files.

It was born out of the necessity to get xplanet to work with xfce or other
compositing multi screen window managers, where xplanet cannot simply take
over the root window to draw on (or you don't want it to do so).

And, of course, you can use this with just minor tweaks for any other window manager.

![alt text](https://raw.githubusercontent.com/apollo-ng/xfce-planet/master/example_output.jpg "Example output")



## Installation

### Dependencies

Make sure the following tools are available on your system:

* xplanet
* dos2unix (some TLE's have really weird WIN/DOS chars that break xplanet)
* unzip
* wget
* convert (imagemagick) - only when you use your own textures/cloudmaps

### Cloning the Repo

    $ git clone https://github.com/apollo-ng/xfce-planet.git

### Set up a link

This package provides all neccessary files in 5400x2700px high-definition
resolution. If your distribution already placed a .xplanet folder in your
$HOME, please move it to avoid collisions.

    $ mv $HOME/.xplanet $HOME/.xplanet_dist

Now set the fallback link for xplanet:

    $ ln -s xfce-planet $HOME/.xplanet

If you don't like this and want/need to deploy somewhere else you'll have to
edit xfce-planet.sh and change the BASEDIR parameter accordingly. The rest
should line up automatically again.

## Usage

    $ cd $HOME/.xplanet
    $ ./xfce-planet.sh

Or simply put it into your local .xinitrc/autostart system

Then select xplanet_output.png as your background image in xfce.

## Configuration

On the first run, xfce-planet will copy a sample config to xfce-planet.conf.
Please change all your local settings in there.


The default sats are a subset of known USA/NRO spy satellites to remind
oneself how far this totalitarian surveillance has come and the ISS
as a contrast showing a glimpse of global co-operation.

## Bonus Points

Goes along very well with the experimental ISS HDEV payload live stream:

http://www.ustream.tv/channel/iss-hdev-payload

And if you want to have it as a live backdrop on the desktop of your
second monitor, have a look at https://github.com/chrippa/livestreamer and
xwinwrap :)

    $ livestreamer -Q http://www.ustream.tv/channel/iss-hdev-payload best --player \
      "./xwinwrap -ni -fs -s -st -sp -b -nf -- mplayer2 -wid WID -nosound

## Support

Please use the issue tracker if you have problems or questions. We are looking
forward to see feedback and pull requests. Or just join us in #apollo on freenode.

## License

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
