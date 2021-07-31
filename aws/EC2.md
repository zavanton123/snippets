### EC2 Intro
- Elastic Compute Cloud (Infrastructure as a Service)

### AMI
- Amazon Machine Image


### Instance Types (e.g. t2.micro)
- Example: m5.2xlarge
- m: instance class
- 5: generation
- 2xlarge: size


### Copy this script
#!bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello world from $(hostname -f)</h1>" > /var/www/html/index.html


### Security Group
- firewall settings
- Inbound and outbound rules


### Access the EC2 instance via ssh
### Security group inbound rule: ssh protocol on port 22 open to all (0.0.0.0)
### Example: 3.68.105.86 is the public IP address fo the EC2 instance
### Note: we generate the ssh key when we are creating the EC2 instance
chmod 400 some-ssh-key.pem
ssh -i some-ssh-key.pem ec2-user@3.68.105.86

### Note: for ubuntu 
ssh -i some-ssh-key.pem ubuntu@3.68.105.86

### check the ssh access is ok
whoami

### try to get list of users
### You first have to create a role with IAM read access and attach this role to the EC2 instance
aws iam list-users


### Storage options
- EBS (Elastic Block Store) Volume (network drive)
- Instance Store (physical drive)
- EFS (Elastic File System) (NFS - network file system)
  
### EBS
- EBS is a network drive (not physical drive)
- EBS are locked to AZ (Availability Zones)
- EBS Snapshot (it is a backup)

### Instance Store
- Good IO performance (i.e. very high IOPS)
- Data is lost when the drive is stopped
- Not good for long-term storage
- Good for caching


### EFS (Elastic File System)
- it is NFS (Network File System)
- Must be used with a Security Group
- More expensive than EBS
- it is multi-AZ (unlike EBS)
- Only for Linux AMIs

### Install amazon-efs-utils
### Note: first configure EFS security group inbound rule 
### to allow NFS access from EC2's security group
sudo yum install -y amazon-efs-utils
mkdir efs
sudo mount -t efs -o tls fs-efdb6fb4:/ efs
cd efc
sudo touch hello-world.txt






### ELB (EC2 Load Balancer)
- CLB (Classic ELB)
- ALB (Application ELB)
- NLB (Network ELB)


### ALB
- has Target Groups:
 - Instance based
 - IP based
 - Lambda based
- Target Groups can be sticky
- Cross-Zone Load Balancing is on (and can't be disabled)


### Network Load Balancer (NLB)
- TCP/UDP based
- Cross-Zone Load Balancing is disabled by default





### SNI (Server Name Indication)
### (i.e. how webserver can handle different certs for different websites)


### Connection Draining (or Deregistration Delay)


### ASG (Auto Scaling Group)







