#!/usr/bin/env bash
set -e

RED="\e[0;31m"
GREEN="\e[0;32m"
CYAN="\e[0;36m"
RESET="\e[0m"

print_error() {
	echo -e "${RED}[✘]${RESET}" "$@"
}

print_info() {
	echo -e "${CYAN}[*]${RESET}" "$@"
}

print_success() {
	echo -e "${GREEN}[✔]${RESET}" "$@"
}

if [ $# -lt 1 ]; then
	echo -e "Usage: $0 [iface]"
	exit
fi

host="10.200.200.1"
guest="10.200.200.2"
subnet="10.200.200.0"
cidr="24"

host_if="v0"
guest_if="v1"

inet="$1"
ns_name="net0"

network="$subnet/$cidr"
exec_ns="sudo ip netns exec $ns_name"

stty -echoctl

setup() {
	sudo ip netns add "$ns_name"
	sudo ip link add "$host_if" type veth peer name "$guest_if"
	sudo ip link set "$guest_if" netns "$ns_name"

	sudo ip addr add "${host}/${cidr}" dev "$host_if"
	sudo ip link set "$host_if" up

	$exec_ns ip link set lo up
	$exec_ns ip addr add "${guest}/${cidr}" dev "$guest_if"
	$exec_ns ip link set "$guest_if" up

	sudo iptables -t nat -A POSTROUTING -s "$network" -o "$inet" -j MASQUERADE
	sudo iptables -A FORWARD -i "$host_if" -o "$inet" -j ACCEPT
	sudo iptables -A FORWARD -i "$inet" -o "$host_if" -j ACCEPT

	$exec_ns ip route add default via "$host" dev "$guest_if"
}

cleanup() {
	print_info "Cleaning up..."

	sudo iptables -t nat -D POSTROUTING -s "$network" -o "$inet" -j MASQUERADE
	sudo iptables -D FORWARD -i "$host_if" -o "$inet" -j ACCEPT
	sudo iptables -D FORWARD -i "$inet" -o "$host_if" -j ACCEPT

	sudo ip netns delete "$ns_name"
}

# Try to cleanup if any error occurs
trap cleanup ERR

setup
print_success "Creating namespace"
print_info "Enter the namespace with: $exec_ns $SHELL"
print_info "If you close this shell the namespace will be deleted"
print_success "Entering namespace..."
$exec_ns "$SHELL"
cleanup
