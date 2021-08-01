# SSL

### Redirect all http requests to https
```
user www-data;

worker_processes auto;

events {
  worker_connections 1024;
}

http {
  include mime.types;

  #redirect all http requests to https
  server {
    listen 80;
    server_name 18.192.99.149;
    return 301 https://$host$request_uri;
  }

  server {
    listen 443 ssl http2;
    server_name 18.192.99.149;

    root /sites/demo;
    index index.html;

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
}
```


















