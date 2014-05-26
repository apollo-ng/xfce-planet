echo "Downloading images... "

# NASA Visible Earth / Blue Marble Images from 2004

URL="http://eoimages.gsfc.nasa.gov/images/imagerecords"
wget -O 01.jpg "$URL/73000/73580/world.topo.bathy.200401.3x5400x2700.jpg"
wget -O 02.jpg "$URL/73000/73605/world.topo.bathy.200402.3x5400x2700.jpg" 
wget -O 03.jpg "$URL/73000/73630/world.topo.bathy.200403.3x5400x2700.jpg" 
wget -O 04.jpg "$URL/73000/73655/world.topo.bathy.200404.3x5400x2700.jpg" 
wget -O 05.jpg "$URL/73000/73701/world.topo.bathy.200405.3x5400x2700.jpg"
wget -O 06.jpg "$URL/73000/73726/world.topo.bathy.200406.3x5400x2700.jpg" 
wget -O 07.jpg "$URL/73000/73751/world.topo.bathy.200407.3x5400x2700.jpg" 
wget -O 08.jpg "$URL/73000/73776/world.topo.bathy.200408.3x5400x2700.jpg" 
wget -O 09.jpg "$URL/73000/73801/world.topo.bathy.200409.3x5400x2700.jpg"
wget -O 10.jpg "$URL/73000/73826/world.topo.bathy.200410.3x5400x2700.jpg" 
wget -O 11.jpg "$URL/73000/73884/world.topo.bathy.200411.3x5400x2700.jpg"
wget -O 12.jpg "$URL/73000/73909/world.topo.bathy.200412.3x5400x2700.jpg" 

# Bump map for relief

wget -O bump.jpg "https://raw.githubusercontent.com/sukharev/ucd/master/PrecomputedAtmosphericScattering/height%20maps/srtm_ramp2.world.5400x2700.jpg"

# Night view of earth 2012

wget -O night.tmp.jpg "${URL}/79000/79765/dnb_land_ocean_ice.2012.13500x6750.jpg"
convert -resize 5400x2700 night.tmp.jpg night.jpg
rm night.tmp.jpg

# Specular map for reflections

wget -O specular.jpg "http://misc.oranse.net/ie/inverted_earth/gebco_bathy.5400x2700.jpg"

echo "DONE."

