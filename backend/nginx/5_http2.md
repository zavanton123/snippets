# HTTP2

### HTTP 2 advantages:
- Binary protocol
- Compressed headers
- Persistent connections
- Multiplex streaming
- Server push

### How to load a page (index.html + style.css + index.js)
- Traditional HTTP 1.1: 3 connections are used
- HTTP 2: only 1 connection is used


### Reinstall nginx with http2 module
### go to source folder: /home/ubuntu/nginx
### reconfigure nginx
```
./configure --sbin-path=/usr/bin/nginx \
  --conf-path=/etc/nginx/nginx.conf \ 
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log \
  --with-pcre --pid-path=/var/run/nginx.pid \
  --with-http_ssl_module --with-http_image_filter_module=dynamic \
  --modules-path=/etc/nginx/modules \
  --with-http_v2_module
```

### recompile
```
make
make install
systemctl restart nginx
systemctl status nginx
```






## SSL
### to enable HTTP 2 we need an SSL certificate
### for testing purposes we generate a self-signed SSL certificate
```
mkdir -p /etc/nginx/ssl

openssl req -x509 -days 10 -nodes \
  -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/self.key \
  -out /etc/nginx/ssl/self.crt 
```



### Enable SSL and HTTP 2 by configuring /etc/nginx/nginx.conf
### Note: if you are using AWS EC2, update the EC2 instance security group's inbound rules
### to accept https from anywhere
```
  server {
    
    #enable https
    listen 443 ssl http2;

    server_name 18.192.99.149;

    root /sites/demo;

    index index.php index.html;

    #indicate SSL certificate and key location
    ssl_certificate /etc/nginx/ssl/self.crt;
    ssl_certificate_key /etc/nginx/ssl/self.key;

    location / {
      try_files $uri $uri/ =404;
    }

    location ~\.php$ {
      include fastcgi.conf;
      fastcgi_pass unix:/run/php/php7.4-fpm.sock;
    }
  }
```






## Server Push
### Install nghttp2-client
```
apt-get install -y nghttp2-client

nghttp -nys https://18.192.99.149/index.html
nghttp -nysa https://18.192.99.149/index.html
```

### update config to enable push
```
location = /index.html {
  http2_push /style.css;
  http2_push /thumb.png;
}
```

### test if push is ok
```
nghttp -nys https://18.192.99.149/index.html
```
