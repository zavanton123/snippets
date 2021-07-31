### Route 53 
- It is a Managed DNS 

### Types of DNS Records:
- A
- AAAA
- CNAME
- Alias

### How to check a record?
dig exevato.com

### Add this to your EC2 instance
#!bin/bash
yum update -y
yum install -y httpd
systemctl start httpd.service
systemctl enable httpd.service
EC2_AVAIL_ZONE=$(curl -s http://169.254.169.264/latest/meta-data/placement/availability-zone)
echo "<h1>Hello world from $(hostname -f) in AZ $EC2_AVAIL_ZONE </h1>" > /var/www/html/index.html


### IPS:
18.192.103.14 - Frankfurt
13.48.28.148 - Stockholm -> ALB DemoRoute53-1978994437.eu-north-1.elb.amazonaws.com
16.162.24.40 - Hong Kong


### DNS TTL



### Alias VS CNAME
- Alias is ok for both root domain and subdomains (+ it is free)
- CNAME is ok only for subdomains (- it is not free)



### Routing Policies:
- Simple Routing Policy (- no health checks)
- Weighted Routing Policy
- Latency Routing Policy
- Failover Routing Policy (it uses Health Checks)
- Multi Value Routing Policy (it uses Health Checks)
