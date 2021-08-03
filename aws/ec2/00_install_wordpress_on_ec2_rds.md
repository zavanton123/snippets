# How to install Wordpress on AWS?

### Source: 
- https://aws.amazon.com/getting-started/hands-on/deploy-wordpress-with-amazon-rds/?refid=gs_card

### Create MySQL using RDS (+ DB security group)

### Create EC2 instance (+ EC2 security group), create CustomKeyPair.pem

### Update the DB security group inbound rule (to allow EC2 security group)

### ssh to the EC2 instance
chmod 600 CustomKeyPair.pem
ssh -i CustomKeyPair.pem ec2-user@the-ec2-instance-public-ip-here

### install the Apache web server
sudo yum install -y httpd

### start the Apache web server
sudo service httpd start

### alternative start/stop/restart Apache web server
sudo systemctl start httpd
sudo systemctl stop httpd
sudo systemctl restart httpd

### visit the public IP of the EC2 instance to check the Apacke web server is running
http://ec2-54-93-240-103.eu-central-1.compute.amazonaws.com

### download and configure wp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

### install some dependencies for WP
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2

### copy WP to the apache folder and restart the apache web server
cd /home/ec2-user
sudo cp -r wordpress/* /var/www/html/
sudo chown -r apache:apache /var/www
sudo systemctl restart httpd

### Visit the website to finish the WP installation
http://ec2-54-93-240-103.eu-central-1.compute.amazonaws.com
