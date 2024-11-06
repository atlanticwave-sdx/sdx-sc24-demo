#!/bin/bash

AMLIGHT=http://0.0.0.0:8181
SAX=http://0.0.0.0:8282
TENET=http://0.0.0.0:8383

# Enable all switches
for oxp in tenet amlight sax internet2 esnet geant_london geant_france lhc; do
	for sw in $(curl -s http://$oxp:8181/api/kytos/topology/v3/switches | jq -r '.switches[].id'); do
		curl -H 'Content-type: application/json' -X POST http://$oxp:8181/api/kytos/topology/v3/switches/$sw/enable
		curl -H 'Content-type: application/json' -X POST http://$oxp:8181/api/kytos/topology/v3/interfaces/switch/$sw/enable
	done
done

# XXX: this step is commented out because we dont actually have links on this topology
## give a few seconds for link discovery (LLDP)
#sleep 5
#
## enable all links
#for oxp in tenet amlight sax internet2 esnet geant_london geant_france lhc; do
#	for l in $(curl -s http://$oxp:8181/api/kytos/topology/v3/links | jq -r '.links[].id'); do
#		curl -H 'Content-type: application/json' -X POST http://$oxp:8181/api/kytos/topology/v3/links/$l/enable; 
#	done
#done

#
# location
# 
curl -H 'Content-type: application/json' -X POST http://amlight:8181/api/kytos/topology/v3/switches/00:00:00:00:00:00:00:01/metadata -d '{"lat": "25.0", "lng": "-80.0", "address": "Miami - USA", "iso3166_2_lvl4": "US-FL"}'
curl -H 'Content-type: application/json' -X POST http://sax:8181/api/kytos/topology/v3/switches/00:00:00:00:00:00:00:02/metadata -d '{"lat": "-3.0", "lng": "-38.0", "address": "Fortaleza, Brazil", "iso3166_2_lvl4": "BR-CE"}'
curl -H 'Content-type: application/json' -X POST http://tenet:8181/api/kytos/topology/v3/switches/00:00:00:00:00:00:00:03/metadata -d '{"lat": "-33.0", "lng": "18.0", "address": "Cape Town, South Africa", "iso3166_2_lvl4": "ZA-WC"}'
curl -H 'Content-type: application/json' -X POST http://internet2:8181/api/kytos/topology/v3/switches/00:00:00:00:00:00:00:04/metadata -d '{"lat": "38.0", "lng": "-77.0", "address": "Washington DC, USA", "iso3166_2_lvl4": "US-DC"}'
curl -H 'Content-type: application/json' -X POST http://esnet:8181/api/kytos/topology/v3/switches/00:00:00:00:00:00:00:05/metadata -d '{"lat": "33.0", "lng": "-84.0", "address": "Atlanta, USA", "iso3166_2_lvl4": "US-GA"}'
curl -H 'Content-type: application/json' -X POST http://geant_london:8181/api/kytos/topology/v3/switches/00:00:00:00:00:00:00:06/metadata -d '{"lat": "51.0", "lng": "0.0", "address": "London, UK", "iso3166_2_lvl4": "GB-LND"}'
curl -H 'Content-type: application/json' -X POST http://geant_france:8181/api/kytos/topology/v3/switches/00:00:00:00:00:00:00:07/metadata -d '{"lat": "48.0", "lng": "2.0", "address": "Paris, France", "iso3166_2_lvl4": "FR-IDF"}'
curl -H 'Content-type: application/json' -X POST http://lhc:8181/api/kytos/topology/v3/switches/00:00:00:00:00:00:00:08/metadata -d '{"lat": "46.0", "lng": "6.0", "address": "Geneva, Switzerland", "iso3166_2_lvl4": "CH-GE"}'

#
# Links
#

# net.addLink(amlight_s1, sax_s1, port1=10, port2=10)
curl -H 'Content-type: application/json' -X POST http://amlight:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:01:10/metadata -d '{"sdx_nni": "sax.net:saxS1:10"}'
curl -H 'Content-type: application/json' -X POST http://sax:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:02:10/metadata -d '{"sdx_nni": "amlight.net:amlightS1:10"}'

# net.addLink(amlight_s1, tenet_s1, port1=11, port2=11)
curl -H 'Content-type: application/json' -X POST http://amlight:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:01:11/metadata -d '{"sdx_nni": "tenet.ac.za:tenetS1:11"}'
curl -H 'Content-type: application/json' -X POST http://tenet:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:03:11/metadata -d '{"sdx_nni": "amlight.net:amlightS1:11"}'

# net.addLink(sax_s1, tenet_s1, port1=12, port2=12)
curl -H 'Content-type: application/json' -X POST http://sax:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:02:12/metadata -d '{"sdx_nni": "tenet.ac.za:tenetS1:12"}'
curl -H 'Content-type: application/json' -X POST http://tenet:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:03:12/metadata -d '{"sdx_nni": "sax.net:saxS1:12"}'

# net.addLink(amlight_s1, esnet_s1, port1=13, port2=13)
curl -H 'Content-type: application/json' -X POST http://amlight:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:01:13/metadata -d '{"sdx_nni": "es.net:esnetS1:13"}'
curl -H 'Content-type: application/json' -X POST http://esnet:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:05:13/metadata -d '{"sdx_nni": "amlight.net:amlightS1:13"}'

# net.addLink(sax_s1, internet2_s1, port1=14, port2=14)
curl -H 'Content-type: application/json' -X POST http://sax:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:02:14/metadata -d '{"sdx_nni": "internet2.net:i2S1:14"}'
curl -H 'Content-type: application/json' -X POST http://internet2:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:04:14/metadata -d '{"sdx_nni": "sax.net:saxS1:14"}'

# net.addLink(esnet_s1, internet2_s1, port1=15, port2=15)
curl -H 'Content-type: application/json' -X POST http://internet2:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:04:15/metadata -d '{"sdx_nni": "es.net:esnetS1:15"}'
curl -H 'Content-type: application/json' -X POST http://esnet:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:05:15/metadata -d '{"sdx_nni": "internet2.net:i2S1:15"}'

# net.addLink(internet2_s1, lhc_s1, port1=16, port2=16)
curl -H 'Content-type: application/json' -X POST http://internet2:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:04:16/metadata -d '{"sdx_nni": "lhc.cern:lhcS1:16"}'
curl -H 'Content-type: application/json' -X POST http://lhc:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:08:16/metadata -d '{"sdx_nni": "internet2.net:i2S1:16"}'

# net.addLink(esnet_s1, geant_london_s1, port1=17, port2=17)
curl -H 'Content-type: application/json' -X POST http://esnet:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:05:17/metadata -d '{"sdx_nni": "london.geant.org:geantUKS1:17"}'
curl -H 'Content-type: application/json' -X POST http://geant_london:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:06:17/metadata -d '{"sdx_nni": "es.net:esnetS1:17"}'

# net.addLink(lhc_s1, geant_london_s1, port1=18, port2=18)
curl -H 'Content-type: application/json' -X POST http://lhc:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:08:18/metadata -d '{"sdx_nni": "london.geant.org:geantUKS1:18"}'
curl -H 'Content-type: application/json' -X POST http://geant_london:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:06:18/metadata -d '{"sdx_nni": "lhc.cern:lhcS1:18"}'

# net.addLink(lhc_s1, geant_france_s1, port1=19, port2=19)
curl -H 'Content-type: application/json' -X POST http://lhc:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:08:19/metadata -d '{"sdx_nni": "france.geant.org:geantFRS1:19"}'
curl -H 'Content-type: application/json' -X POST http://geant_france:8181/api/kytos/topology/v3/interfaces/00:00:00:00:00:00:00:07:19/metadata -d '{"sdx_nni": "lhc.cern:lhcS1:19"}'
