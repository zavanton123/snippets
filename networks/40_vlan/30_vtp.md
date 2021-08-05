# VLAN Trunking Protocol (VTP)


### setup vtp
```
show vtp status
conf t
vtp version 2
vtp mode server
vtp domain ARIZONA
exit

show vtp status
conf t
vlan 10
name CLIENT
end
show vtp status
```


### change to client mode
```
conf t
vtp mode client
vlan 30
# not allowed
vtp mode server
vlan 30 
name VOIP
```

### change to transparent mode (this disables vtp)
```
en
show vtp status
show vlan
conf t
vtp mode transparent
end
show vtp status
show vlan
```
