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




















