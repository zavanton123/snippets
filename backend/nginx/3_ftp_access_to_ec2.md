### Source
```
https://medium.com/tensult/configure-ftp-on-aws-ec2-85b5b56b9c94
```

### Login to ec2 instance
ssh -i CustomPair.pem ec2-user@54.93.240.103

### change to root account
sudo su

### install the dependencies
yum update -y
yum install vsftpd -y

### open ftp ports
### Update the EC2 instance security group
### Add 2 inbound rules
allow custom TCP to port 20-21 from anywhere
allow custom TCP to port 1024-1048 from anywhere

### Update the vsftp config
vim /etc/vsftpd/vsftpd.conf
```
anonymous_enable=NO
pasv_enable=YES
pasv_min_port=1024
pasv_max_port=1048
pasv_address=54.93.240.103

```


### Restart the vsftpd
sudo systemctl restart vsftpd


### Create a new user
sudo adduser zavanton
### change user password
sudo passwd zavanton


### Give the rights to write files
### update vsftpd.config
chroot_local_user=YES
write_enable=YES
allow_writeable_chroot=YES


### Set the user's ftp home directory
sudo usermod -d /some/directory/here zavanton

### assign the user to the group that owns /some/directory/here
sudo usermod -a -G some-group-name zavanton
sudo systemctl restart vsftpd

### Now you can ftp to the EC2 instance as zavanton to port 21
