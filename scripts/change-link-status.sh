#!/bin/bash

PORT_ID=$1
STATUS=$2
MININET=$(docker compose ps mininet -q)
SDX_CONTROLLER=$(docker compose ps sdx-controller -q)
SDX_CTRL_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $SDX_CONTROLLER)

if [ $# -ne 2 -o "$PORT_ID" = "-h" -o "$PORT_ID" = "--help" ]; then
	echo "USAGE: $0 <port-id> <up|down>"
	exit 0
fi

PORT=$(curl -s http://$SDX_CTRL_IP:8080/SDX-Controller/topology | jq -r '.nodes[].ports[]|tostring'| grep $PORT_ID | jq -r '.name')

if [ -z "$PORT" ]; then
	echo "Invalid port! not found.. use the './show-sdx-controller.sh ports'"
	exit
fi

docker exec -it $MININET tmux send-keys -t mn "sh ip link set $STATUS $PORT" ENTER
