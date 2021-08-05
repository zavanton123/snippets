### Problem: access-switch has access to vlan 45)
### (we want to prevent access switch from having access to vlan 45)

### vlan 45 is configured on core-switch-1 and core-switch-2

### from core-switch-1 (repeat on core-switch-2 as well)
### (access-switch is connected to core-switch-1 on fa 0/1)
```
en
show int trunk
conf t
vlan 45
name DEV
end
show vlan

conf t
int fa 0/1
switchport trunk allowed vlan remove 45
end
show int trunk
```

