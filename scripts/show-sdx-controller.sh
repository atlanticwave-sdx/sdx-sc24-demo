#!/bin/bash
CONTAINER=$(docker compose ps sdx-controller -q)
IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER)

case $1 in
links)
	curl -s http://$IP:8080/SDX-Controller/topology | jq -r '(["ID","STATUS","STATE"] | (., map(length*"-"))), (.links[] | [.id, .status, .state]) | @tsv' | column -t
	;;
nodes)
	curl -s http://$IP:8080/SDX-Controller/topology | jq -r '(["ID","STATUS","STATE"] | (., map(length*"-"))), (.nodes[] | [.id, .status, .state]) | @tsv' | column -t
	;;
ports)
	curl -s http://$IP:8080/SDX-Controller/topology |  jq -r '(["ID","STATUS","STATE"] | (., map(length*"-"))), (.nodes[].ports[] | [.id, .status, .state]) | @tsv' | column -t
	;;
l2vpn)
	curl -s http://$IP:8080/SDX-Controller/l2vpn/1.0 | jq -r '(["ID", "ENDPOINT-1", "VLAN-1", "ENDPOINT-2", "VLAN-2"] | (., map(length*"-"))), (.[]|[.service_id, .endpoints[0].port_id, .endpoints[0].vlan, .endpoints[1].port_id, .endpoints[1].vlan]) | @tsv' | column -t
	;;
*)
	echo "USAGE $0 nodes|ports|links"
	;;
esac
