#!/bin/bash

echo "waiting switches to connect..."
until [ $(ovs-vsctl list-br | wc -l) -gt 0 -a $(ovs-vsctl list-br | wc -l) -eq $(ovs-vsctl list Controller | grep is_connected | grep -c true) ]; do
	sleep 2
done
echo "all switches connected!"
