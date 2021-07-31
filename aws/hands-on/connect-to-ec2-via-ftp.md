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



### create password for the user ec2-user
sudo passwd ec2-user
### enter some-pass-here



### Now you can ftp to the EC2 instance as ec2-user to port 21

