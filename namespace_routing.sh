ip netns add custA-1
ip netns add custA-X
ip netns add custB-1
ip netns add custB-X
ovs-vsctl add-br OVS1


ip link add a1-eth0 type veth peer name veth-a1
ip link add ax-eth0 type veth peer name veth-ax
ip link add bx-eth0 type veth peer name veth-bx
ip link add ax-eth1 type veth peer name veth1-ax
ip link add bx-eth1 type veth peer name veth1-bx
ip link add b1-eth0 type veth peer name veth-b1

ip link set ax-eth0 netns custA-X
ip link set ax-eth1 netns custA-X
ip link set a1-eth0 netns custA-1
ip link set b1-eth0 netns custB-1
ip link set bx-eth0 netns custB-X
ip link set bx-eth1 netns custB-X


ovs-vsctl add-port OVS1 veth-a1 tag=100
ovs-vsctl add-port OVS1 veth-ax tag=100
ovs-vsctl add-port OVS1 veth-b1 tag=300
ovs-vsctl add-port OVS1 veth-bx tag=300
ovs-vsctl add-port OVS1 veth1-bx tag=200
ovs-vsctl add-port OVS1 veth1-ax tag=200

ip link set veth-a1 up
ip link set veth-ax up
ip link set veth1-ax up
ip link set veth1-bx up
ip link set veth-bx up
ip link set veth-b1 up

ip netns exec custA-1 ip link set lo up
ip netns exec custA-1 ip link set a1-eth0 up
ip netns exec custA-1 ip address add 10.5.0.20/24 dev a1-eth0

ip netns exec custB-1 ip link set lo up
ip netns exec custB-1 ip link set b1-eth0 up
ip netns exec custB-1 ip address add 10.6.0.20/24 dev b1-eth0

ip netns exec custB-X ip link set lo up
ip netns exec custB-X ip link set bx-eth0 up
ip netns exec custB-X ip link set bx-eth1 up
ip netns exec custB-X ip address add 10.6.0.10/24 dev bx-eth0
ip netns exec custB-X ip address add 169.254.169.101/24 dev bx-eth1
ip netns exec custB-X iptables -t nat -A PREROUTING -i bx-eth1 -j DNAT --to 10.6.0.20
ip netns exec custB-X iptables -t nat -A POSTROUTING -o bx-eth0 -j MASQUERADE
ip netns exec custB-X sysctl -w net.ipv4.ip_forward=1

ip netns exec custA-X ip link set lo up
ip netns exec custA-X ip link set ax-eth0 up
ip netns exec custA-X ip link set ax-eth1 up
ip netns exec custA-X ip address add 10.5.0.10/24 dev ax-eth0
ip netns exec custA-X ip address add 169.254.169.100/24 dev ax-eth1
ip netns exec custA-X iptables -t nat -A PREROUTING -i ax-eth0 -j DNAT --to 169.254.169.101
ip netns exec custA-X iptables -t nat -A POSTROUTING -o ax-eth1 -j MASQUERADE
ip netns exec custA-X sysctl -w net.ipv4.ip_forward=1

ip netns add testA
ip netns add testB
ip link add a-eth0 type veth peer name b-eth0
ip link set a-eth0 netns testA
ip link set b-eth0 netns testB

ip netns exec testA ip link set lo up
ip netns exec testA ip link set a-eth0 up
ip netns exec testA ip address add 10.1.0.20/24 dev a-eth0

ip netns exec testB ip link set lo up
ip netns exec testB ip link set b-eth0 up
ip netns exec testB ip address add 10.1.0.21/24 dev b-eth0
