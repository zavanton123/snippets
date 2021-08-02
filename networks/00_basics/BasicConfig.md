# Device Modes
User Mode > (enable/disable) > Privileged Mode > (configure terminal) > Global Config Mode




# CLI commands

### Move to the start of the line
CTRL+a

### Move to the end of the line
CTRL+e

### Jump back from anywhere to the privileged mode
### (The same as 'end')
CTRL+z

### enable the privileged mode
enable

### disable the privileged mode
disable

### show your current privilege level
show privilege

### enter global config mode
configure terminal

### enter the gigabitEthernet config mode
interface gigabitEthernet 0/0

### enter line config
line vty 0

### jump to the previous mode
exit

### jump to privileged mode from anywhere
### The same as CTRL+z
end


### Show physical port info
show ip interface brief


### clear config
write erase







# NAMING
### rename the host
enable 
conf t
hostname some-name-here

### set the login banner (motd = message of the day)
banner motd $ hello world $









# SET PASSWORD FOR THE PRIVILEGED MODE
### set a password (unhashed) for the privileged mode
enable 
conf t
enable password some-pass-here
### remove the password
no enable password
### set a secret (hashed) for the privileged mode
enable secret some-secret-here
### (privileged mode) show running config
exit
show running-config








# SET PASSWORD FOR VIRTUAL TERMINAL
### 'vty' (virtual teletype)
enable 
conf t
### configure all the virtual terminals from 0 to 4
### (i.e. enter config mode for virtual terminals)
line vty 0 4
### enable login
login
### set a password
password some-password here





# SET PASSWORD FOR THE CONSOLE TERMINAL
### (config mode command)
enable
conf t
### enter config mode for the console terminal
line con 0
### enable login
login
### set password
password some-pass-here







# SET USERNAME
enable
conf t
### create a username
username some-username
### or create a username with secret
username some-username secret som-secret




# SET IP ADDRESS FOR THE ROUTER AND TURN ON THE INTERFACE
show ip interface brief
enable 
configure terminal
interface gigabitEthernet 0/0
### assign an ip address to the interface
ip address 192.168.10.1 255.255.255.0
### turn on the interface
no shutdown



# DISABLE DNS LOOKUP (FOR SHOWING MISTAKES WHEN YOU MISTYPE SOMETHING...)
enable
conf t
### disable dns lookup
no ip domain-lookup



# ENCRYPT EXISTING PLAIN-TEXT PASSWORDS
enable
conf t
### convert the existing unencrypted passwords into encrypted ones
service password-encryption



# ENABLE SYNCHRONOUS LOGGING
enable
conf t
line con 0
logging synchronous





# SAVE CONFIGURATION (ON DEVICE)
enable
copy running-config startup-config
### or shortcut
write
### check the startup config
show startup-config



# TELNET TO ROUTER USING USERNAME AND PASSWORD
enable 
conf t
username zavanton secret some-secret
### configure the virtual terminal
line vty 0 4
### enable login/password with telnet
login local




# ACCESS PRIVILEGED MODE COMMAND FROM GLOBAL CONFIG MODE
en
conf t
do show ip int br


# HOW TO JUMP FROM ONE MODE TO ANOTHER MODE
en
conf t
int gig 0/0
description This is some description
exit
router rip
### jump directly to g 0/0 config mode
int gi 0/0






# HOW TO ADD IP ADDRESS TO A SWITCH?
en
conf t
interface Vlan1
no shutdown
ip address 192.168.1.2 255.255.255.0



# How to ping from router to core switch?
### Turn on all the ethernet interfaces of the router
en 
conf t
int fa 0/1/0
no shutdown
exit

int fa 0/1/1
no shutdown
exit

int fa 0/1/2
no shutdown
exit

int fa 0/1/3
no shutdown
exit

### Turn on the vlan of the router
int Vlan1
no shutdown
exit

### remove the ip address from the gigabitEthernet interface
int gi 0/0
no ip address
shutdown
exit

### add the ip address to the vlan interface of the router
int Vlan1
ip addr 192.168.1.1 255.255.255.0
exit

### Ping the switch from the router
ping 192.168.1.2

### telnet from router to the switch
telnet 192.168.1.2

### suspend the telnet session
### press CTRL+SHIFT+6 and press X
### return to the telnet session
### press ENTER
### Note: if many telnet sessions are active, you can show them:
show sessions
### You can select the session by typing it number:
1















