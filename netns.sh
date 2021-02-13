#!/usr/bin/env bash

if [[ $# -lt 1 ]]; then
	echo -e "Usage: $0 [iface]"
	exit
fi

host=10.200.200.1
guest=10.200.200.2
subnet=10.200.200.0
cidr=24

host_if=v0
guest_if=v1

inet=$1
ns_name=vpn

network=$subnet/$cidr
exec_ns="sudo ip netns exec $ns_name"

stty -echoctl

cleanup() {
	echo -e '[*] Cleaning up...'

	sudo iptables -t nat -D POSTROUTING -s $network -o $inet -j MASQUERADE
	sudo iptables -D FORWARD -i $host_if -o $inet -j ACCEPT
	sudo iptables -D FORWARD -i $inet -o $host_if -j ACCEPT

	sudo ip netns delete $ns_name
}

trap cleanup SIGINT

sudo ip netns add $ns_name
sudo ip link add $host_if type veth peer name $guest_if
sudo ip link set $guest_if netns $ns_name

sudo ip addr add $host/$cidr dev $host_if
sudo ip link set $host_if up

$exec_ns ip link set lo up
$exec_ns ip addr add $guest/$cidr dev $guest_if
$exec_ns ip link set $guest_if up

sudo iptables -t nat -A POSTROUTING -s $network -o $inet -j MASQUERADE
sudo iptables -A FORWARD -i $host_if -o $inet -j ACCEPT
sudo iptables -A FORWARD -i $inet -o $host_if -j ACCEPT

$exec_ns ip route add default via $host dev $guest_if

$exec_ns ip a

sleep infinity
