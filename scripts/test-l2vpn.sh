#!/bin/bash

CONN_ID=$1
ARG2=$2
MININET=$(docker compose ps mininet -q)
SDX_CONTROLLER=$(docker compose ps sdx-controller -q)
SDX_CTRL_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $SDX_CONTROLLER)

if [ $# -ne 1 -a $# -ne 2 ] || [ "$CONN_ID" = "-h" -o "$CONN_ID" = "--help" ]; then
	echo "USAGE: $0 <connection-id> [ping-only]"
	exit 0
fi

RES=$(curl -s http://$SDX_CTRL_IP:8080/SDX-Controller/l2vpn/1.0/$CONN_ID | jq -r '.["'$CONN_ID'"]|.endpoints[0].port_id + " " + (.endpoints[0].vlan|tostring) + " " + .endpoints[1].port_id + " " + (.endpoints[1].vlan|tostring)')

if [ -z "$RES" -o $(echo "$RES" | wc -w) -ne 4 ]; then
	echo "Invalid connection id or invalid response: $RES"
	exit 0
fi

read -r UNIA VLANA UNIZ VLANZ <<< $RES

if ! echo "$VLANA" | egrep -q "^[0-9]+$"; then
	echo "Invalid VLANA=$VLANA"
	exit 1
fi

if ! echo "$VLANZ" | egrep -q "^[0-9]+$"; then
	echo "Invalid VLANZ=$VLANZ"
	exit 1
fi

IFACEA=$(echo $UNIA | cut -d":" -f5,6 | sed 's/:/-eth/g')
IFACEZ=$(echo $UNIZ | cut -d":" -f5,6 | sed 's/:/-eth/g')

NETNSIDA=$(docker exec -it $MININET bash -c "ip link show dev $IFACEA" | egrep -o "link-netnsid [0-9]+" | cut -d' ' -f2)
NETNSIDZ=$(docker exec -it $MININET bash -c "ip link show dev $IFACEZ" | egrep -o "link-netnsid [0-9]+" | cut -d' ' -f2)

PIDA=$(docker exec -it $MININET bash -c 'lsns -t net --output NETNSID,PID |tail -n +3' | egrep -o "$NETNSIDA\s+[0-9]+" | awk '{print $2}')
PIDZ=$(docker exec -it $MININET bash -c 'lsns -t net --output NETNSID,PID |tail -n +3' | egrep -o "$NETNSIDZ\s+[0-9]+" | awk '{print $2}')

if ! echo "$PIDA" | egrep -q "^[0-9]+$"; then
	echo "Could not get $MININET pid for interface A (IFACEA=$IFACEA, NETNSIDA=$NETNSIDA, PIDA=$PIDA)"
	exit 1
fi

if ! echo "$PIDZ" | egrep -q "^[0-9]+$"; then
	echo "Could not get $MININET pid for interface Z (IFACEZ=$IFACEZ, NETNSIDZ=$NETNSIDZ, PIDZ=$PIDZ)"
	exit 1
fi

HOSTA=$(docker exec -it $MININET bash -c "mnexec -a $PIDA ip link" | egrep -o "\S+-eth1@if" | cut -d "-" -f1)
HOSTZ=$(docker exec -it $MININET bash -c "mnexec -a $PIDZ ip link" | egrep -o "\S+-eth1@if" | cut -d "-" -f1)

PING_ARG=""
if [ "$ARG2" != "ping-only" ]; then
	echo "Configuring hostA ($HOSTA)..."
	docker exec -it $MININET bash -c "mnexec -a $PIDA ip link del vlan$VLANA 2>/dev/null"
	docker exec -it $MININET bash -c "mnexec -a $PIDA ip link add link $HOSTA-eth1 name vlan$VLANA type vlan id $VLANA"
	docker exec -it $MININET bash -c "mnexec -a $PIDA ip link set up vlan$VLANA"
	docker exec -it $MININET bash -c "mnexec -a $PIDA ip addr add 2001:db8:$VLANA:$VLANZ::1/64 dev vlan$VLANA"
	echo "Configuring hostZ ($HOSTZ)..."
	docker exec -it $MININET bash -c "mnexec -a $PIDZ ip link del vlan$VLANZ 2>/dev/null"
	docker exec -it $MININET bash -c "mnexec -a $PIDZ ip link add link $HOSTZ-eth1 name vlan$VLANZ type vlan id $VLANZ"
	docker exec -it $MININET bash -c "mnexec -a $PIDZ ip link set up vlan$VLANZ"
	docker exec -it $MININET bash -c "mnexec -a $PIDZ ip addr add 2001:db8:$VLANA:$VLANZ::2/64 dev vlan$VLANZ"
	
	echo "Learning MAC addresses..."
	docker exec -it $MININET bash -c "mnexec -a $PIDA ping6 -c1 2001:db8:$VLANA:$VLANZ::2 2>&1 >/dev/null"

	PING_ARG=-c5
fi

echo "ping test HostA - HostB"
set -x
docker exec -it $MININET bash -c "mnexec -a $PIDA ping6 $PING_ARG -i0.2 2001:db8:$VLANA:$VLANZ::2"
