# Nginx and Wordpress

## Setup AWS infrastructure
### Create MySQL using RDS (+ DB security group)
### Create EC2 instance (+ EC2 security group), create CustomKeyPair.pem
### Update the DB security group inbound rule (to allow EC2 security group)





## Install some dependencies
```
ssh -i CustomKey.pem ubuntu@ec2-54-93-240-103.eu-central-1.compute.amazonaws.com
sudo su
apt-get update -y && apt-get upgrade -y
apt-get install build-essential
apt-get install libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev 
apt-get install php
apt-get install php-mysql
apt-get install php-fpm
apt-get install php-zip
```








## Install Nginx
### download nginx
wget https://nginx.org/download/nginx-1.21.1.tar.gz

### extract the archive
tar -zxvf nginx-1.21.1.tar.gz

### configure the installation
cd nginx-1.21.1
./configure

### check configure options
./configure --help


### set some common configuration flags
./configure \
    --sbin-path=/usr/bin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --with-pcre \
    --pid-path=/var/run/nginx.pid \
    --with-http_ssl_module 
    
### now compile
make

### now install the compiled source
make install

### check the configuration folder
ls -la /etc/nginx

### check the installed nginx version
nginx -V

### start nginx
nginx

### check the process is running
ps aux | grep nginx

### now the website is up
http://some-public-ip-here:80

### how to stop nginx
nginx -s stop

### configure system service for nginx (systemd)
touch /lib/systemd/system/nginx.service
vim /lib/systemd/system/nginx.service
```
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/bin/nginx -t
ExecStart=/usr/bin/nginx
ExecReload=/usr/bin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

### start nginx via systemd
systemctl start nginx

### check if nginx is running via systemd
systemctl status nginx

### enable nginx startup on Ubuntu server boot
systemctl enable nginx

### reboot the Ubuntu server to check if nginx will be running on startup
reboot

### check nginx
systemctl status nginx







## Configure NGINX
### /etc/nginx/nginx.conf
```
user  www-data;
worker_processes  1;

events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    client_max_body_size 100M;

    server {
        listen       80;
        server_name  localhost;

        root /var/www/html;
        index index.php;

        location = /favicon.ico {
                log_not_found off;
                access_log off;
        }

        location = /robots.txt {
                allow all;
                log_not_found off;
                access_log off;
        }

        location / {
                # This is cool because no php is touched for static content.
                # include the "?$args" part so non-default permalinks doesn't break when using query string
                try_files $uri $uri/ /index.php?$args;
        }

        location ~ \.php$ {
                #NOTE: You should have "cgi.fix_pathinfo = 0;" in php.ini
                include fastcgi_params;
                fastcgi_intercept_errors on;
                fastcgi_pass unix:/run/php/php7.4-fpm.sock;
                #The following parameter can be also included in fastcgi_params file
                fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }

        location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
                expires max;
                log_not_found off;
        }
    }
}
```







## Configure php.ini
### update file upload size
### update upload_max_filesize to 100M
```
find / -name php.ini
vim /etc/php/fpm/php.ini
vim /etc/php/cli/php.ini

reboot
```










## Install Wordpress
### download and configure wp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

### copy WP to the apache folder and restart the apache web server
sudo su
mkdir -p /var/www/html
cd /home/ubuntu
sudo cp -r wordpress/* /var/www/html/
sudo chown -r www-data:www-data /var/www
sudo systemctl restart nginx

### Visit the website to finish the WP installation
http://ec2-54-93-240-103.eu-central-1.compute.amazonaws.com

