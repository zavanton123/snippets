# How to install Word Press?

### Create MySQL using RDS (+ DB security group)

### Create EC2 instance (+ EC2 security group), create CustomKeyPair.pem

### Update the DB security group inbound rule (to allow EC2 security group)

### ssh to the EC2 instance
chmod 600 CustomKeyPair.pem
ssh -i CustomKeyPair.pem ec2-user@the-ec2-instance-public-ip-here

### install the db client
sudo yum install -y mysql

### make db host environment variable
export MYSQL_HOST=wordpress.cofkamzbbdxu.eu-central-1.rds.amazonaws.com

### connect to the db
mysql --user=db-user-here --password=some-password-here db-name-here

### create a new db user
CREATE USER 'wordpress' IDENTIFIED BY 'wordpress-pass';
GRANT ALL PRIVILEGES ON wordpress.* TO wordpress;
FLUSH PRIVILEGES;
Exit

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

cd wordpress
cp wp-config-sample.php wp-config.php

nano wp-config.php
```
// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'database_name_here' );

/** MySQL database username */
define( 'DB_USER', 'username_here' );

/** MySQL database password */
define( 'DB_PASSWORD', 'password_here' );

/** MySQL hostname */
define( 'DB_HOST', 'localhost' );
```



### visit this link to generate the salt and copy its contents into the config file
https://api.wordpress.org/secret-key/1.1/salt/

```
define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );
```


### install some dependencies for WP
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2

### copy WP to the apache folder and restart the apache web server
cd /home/ec2-user
sudo cp -r wordpress/* /var/www/html/
sudo service httpd restart


### Visit the website to finish the WP installation
http://ec2-54-93-240-103.eu-central-1.compute.amazonaws.com


### While installing the WP will be unable to edit the wp-config.php file
### Copy the file contents from the browser and create this file manually:
/var/www/html/wp-config.php

