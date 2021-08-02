# Dynamic Trunking Protocol (DTP)

## Modes
- Manual
- Dynamic:
-- auto (it is passive)
-- desirable (it is active)

### Change modes
### manual vs dynamic mode
```
en
conf t
int fa0/10
switchport mode dynamic auto
switchport mode dynamic desirable
switchport mode trunk
switchport nonegotiage
```


## Native VLAN

### Idea: trunk ports should receive packets with tags
### But what if it doesn't? Then packets go to the native VLAN.
### This happens in these situations:
- Switch originated traffic

### The big rule: when you set up a trunk,
### make sure the native VLANs on each side match
### (e.g. always VLAN 1)
```
en
conf t
int fa 0/10
switchport trunk native vlan 1
```






## Manually configure trunks in a multi-switch environment
### (i.e. all the switches are interconnected by trunks)

### Setup Core Switch 1
### Setup trunks on switch ports (fa 0/1, gi 0/1, gi o/2)
```
en
conf t
int fa 0/1
switchport trunk encapsulation dot1Q
switchport mode trunk
switchport nonegotiate
end

conf t
int range gi 0/1-2
switchport trunk encapsulation dot1Q
switchport mode trunk
switchport nonegotiage
end
wr
```

### Setup Core Switch 2
```
en
conf t
int range gi 0/1-2
switchport trunk encapsulation dot1Q
switchport mode trunk
switchport nonegotiage
end
wr
```

### Setup Access Switch 
```
en
show cdp neighbors
conf t
int range fa 0/2-3
switchport mode trunk
switchport nonegotiage
end
wr
show int fa 0/2 switchport
```









