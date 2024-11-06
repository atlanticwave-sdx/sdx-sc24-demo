#!/bin/bash

usage(){
	echo "USAGE: $0"
	echo "USAGE: $0 VLAN"
	echo "USAGE: $0 VLAN1 VLAN2"
	echo "USAGE: $0 ENDPOINT1 VLAN1 ENDPOINT2 VLAN2"
}

if [ "$1" = "-h" -o "$1" = "--help" ]; then
	echo $1
	usage
	exit 0
fi

ENDPOINT1=urn:sdx:port:france.geant.org:geantFRS1:50
VLAN1=any
ENDPOINT2=urn:sdx:port:tenet.ac.za:tenetS1:50
VLAN2=any

if [ $# -eq 0 ]; then
	# Nothing
	true
elif [ $# -eq 1 ]; then
	VLAN1=$1
	VLAN2=$1
elif [ $# -eq 2 ]; then
	VLAN1=$1
	VLAN2=$2
elif [ $# -eq 4 ]; then
	ENDPOINT1=$1
	VLAN1=$2
	ENDPOINT2=$3
	VLAN2=$4
else
	usage
	exit 1
fi


SDX_CONTROLLER=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker compose ps sdx-controller -q))

curl -X POST -H 'Content-type: application/json' http://$SDX_CONTROLLER:8080/SDX-Controller/l2vpn/1.0 -d '{"name": "vlan test '$VLAN1"--"$VLAN2'", "endpoints": [{"port_id": "'$ENDPOINT1'", "vlan": "'$VLAN1'"}, {"port_id": "'$ENDPOINT2'", "vlan": "'$VLAN2'"}]}'
