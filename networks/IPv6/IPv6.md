
### Set IPv6 address to loopback interface of the router
enable
configure terminal 
interface loopback 0
ipv6 address some-address-here
end
show ipv6 interface loopback 0



### Types of IPv6 addresses
- Unspecified Address ::/128
- Loopback Address ::1/128
- Global Address 2::/123 or 3::/128 (the most common is 2001::/128)
- Multicast Address FF....
- Link Local Address FE80.....

### Example
### IPv6 allocated to us by ISP
2001:db8:6783/48
### First 64 bits (including the ISP 48 bits) are for the network
### Second 64 bits are for hosts



### Set some router port's IPv6 address
enable
conf t
### (note: this enables ipv6 routing)
ipv6 unicast routing
int gi 0/0/0
ipv6 address 2001:db8:6783:801::1/64
end
show int gi 0/0/0
show ipv6 int br

### Autoconfigure another router port's link local IPv6 address
conf t
int gi 0/0/1
ipv6 address autoconfig
end

show ipv6 int
show ipv6 int br










