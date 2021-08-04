# Some simple NGINX config

### Features:
- reverse proxy
- serve static files
- serve php via php-fpm

### location: /etc/nginx/nginx.conf

```
user www-data;

events {}

http {
  include mime.types;

  server {
    listen 8787;
    server_name localhost;

    location / {
      proxy_pass http://localhost:9999;
    }

    location ~ \.(png|jpeg)$ {
      root /example/images;
    }
  }

  server {
    listen 9999;
    server_name localhost;

    root /example2/www;

    index index.php index.html;

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
