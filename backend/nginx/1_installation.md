# Install Nginx on Ubuntu via apt
sudo su
apt-get update
apt-get install nginx -y

### check the folder with configuration
ls -la /etc/nginx

### apt package automatically starts nginx
### check nginx is running
ps aux | grep nginx

### now the page is available at
http://public-ip-here:80










# Install on CentOS via yum
yum install -y epel-release
yum install -y nginx

### check the folder with configuration
ls -la /etc/nginx

### yum package does not automatically start nginx
### check nginx is not running
ps aux | grep nginx

### start the nginx
service nginx start






# Manual Installation on Ubuntu
### Manual installation is recommended, because you can install additional modules
sudo su
apt-get update

### install the C compiler
apt-get install build-essential

### install some additional dependencies
apt-get install libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev 

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
