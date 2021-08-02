### VLAN (Virtual Local Area Network)

### What problems do VLANs solve?
- There is no security at Layer 2
- There is no segmentation at Layer 2
- There is no way to differentiate devices at Layer 2

### Old solutions:
- use routers everywhere
- use servers on every network

### What VLANs do:
- create multiple broadcast domains / subnets / networks
- extend the entire Layer 2 fabric (stop at router)
- segment and isolate traffic

### Communication between VLANs
- Traditional:  router and switch (+ many cables connect to many interfaces)
(i.e. the router has an individual port to connect to each VLAN)

- "Router on a stick": router and switch (+ a thunk)
(i.e. the router has one interface with many subinterfaces, it is connected to thunk - 
one physical cable tagged with labels for each vlan)

- 3L switch









### Configure the switch with VLAN
### create different VLANs and name them
en
show vlan
show vlan brief
conf t
vlan 10
name STATIC
exit
vlan 20
name VOIP
exit
vlan 30
name CLIENT
exit
vlan 40
name BYOD
end
show vlan

### assign one port to a VLAN
### login to switch
conf t
int fa 0/2
switchport mode access
switchport access vlan 10
end
show vlan
conf t
int fa 0/3
switchport mode access
switchport access vlan 10
end
show vlan

### assign multiple ports to some VLAN
conf t
int range fa 0/4 - fa 0/5
switchport mode access
switchport access vlan 20
end

### Turn off spanning tree protocol
conf t
int range fa0/1 - fa0/24
spanning-tree portfast









### configure "router with a stick"
### login to router
en
show ip int br
conf t
int gi 0/1
no ip address
no shutdown
exit
int gi 0/1.10
encapsulation dot1Q 10
ip address 10.16.8.1 255.255.255.0
exit
int gi 0/1.20
encapsulation dot1Q 20
ip address 10.16.10.1 255.255.255.0
exit









### login to switch
en
### check the 'administrative mode' is 'dynamic'
show int fa 0/1 switchport 
conf t
int fa 0/1 
### set 'administrative mode' to 'trunk'
switchport mode trunk







### PC1 and PC2 are in the same VLAN
### configure PC1
10.16.8.2
255.255.255.0
default gateway: 10.16.8.1
connect to fa 0/2

### configure PC2
10.16.8.3
255.255.255.0
default gateway: 10.16.8.1
connect to fa 0/3

### from PC1
ping 10.16.8.3
### clear arp
arp -d
### check arp
arp -a




### PC3 is in VLAN 20
### configure PC3
10.16.10.2
255.255.255.0
default gateway: 10.16.10.1
connect to fa 0/3

### Ping from VLAN 20 (from PC3) to VLAN 10 (to PC1)
### this is possible because we have a 'router with thunk'
ping 10.16.8.2
tracert 10.16.8.2

