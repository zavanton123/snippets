### IAM action:
- create a group
- create a user and add it to some group
- login as root/login as user
- add policies from the group
- add policies from the user
- create a new policy
- create a role (e.g. for EC2)
- download credential report
- see some user's access advisor
- create some user's security credentials (create Access Key)
- login using AWS CLI



### EC2 actions
- choose an AMI for the new EC2 instance
- choose an instance type (t.g. t2.micro) for the new EC2 instance
- create a new EC2 instance
- create a new security group
- change its inbound/outbound rules
- add IAM role to EC2 instance
- access EC2 instance by its public IP and DNS in browser (via http)
- access EC2 instance by its public IP and DNS via ssh
- using IAM role show all the IAM users via the ssh
- create a clone of the image by ('launch more like this', or a new template, or a new AMI)
- create a new EBS volume and attach it to some EC2 instance
- create a snapshot of some EC2 volume
- create a volume from the snapshot in a different AZ
- create a new AMI from the snapshot (or volume)
- create a new EC2 instance from the new AMI




### EFS actions:
- create an EFS
- attach the EFS to several EC2 instances in different AZ
```
- create two or more EC2 instances in the same region but in different AZ
- the EC2 instances must share the same Security Group
- create a new EFS
- create a new Security Group and attach it to the EFS
- the EFS Security Group inbound rule must allow NFS connection from the EC2s Security Group
- ssh to all the EC2 instances
- install amazon-efs-utils and create efs dir
- use the utils to mount the EFS
- create some file (it will be shared among EC2 instances)
```




### ELB actions:
- create a classic ELB and a security group for it
- create three EC2 instances and configure their security group to allow only traffic from ELB
- Enable/Disable Cross-Zone Load Balancing for the ELB



### ALB actions:
- create an ALB (with a Target Group and a Security Group)
- create three EC2 instances and configure their security group to allow only traffic from ALB
- create a new Target Group
- update the Listener of the ALB (add a new rule to forward to the new Target Group)
- Make Target Group Sticky



### ASG actions:
- create an ASG
- increase/decrease the desired number of EC2 instances in the group

### ASG Scaling Policies
- Target Tracking Scaling
- Simple Scaling (based on CloudWatch alarms)
- Step Scaling (based on CloudWatch alarms)
- Scheduled Actions






### RDS actions:
- Create a DB and connect to it


### ElastiCache actions:
- Create an ElastiCache instance



### Route 53:
- Register a new domain name
- Add A, AAAA, CNAME records (+ Alias)
- Use different routing policies (simple, weighted, latency, geolocation, failover multi-value)
- Use Health Checks with routing policies 


