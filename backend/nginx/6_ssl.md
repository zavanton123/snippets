# SSL

## Some terminology
- SSL (Secure Sockets Layer)
- TLS (Transport Layer Security)


### How to improve SSL security?
- Redirect all http requests to https
- Disable SSL (use TLS only)
- Optimise cipher suites
- Enable DH parameters
- Enable HSTS
- Cache SSL sessions


### Generate dhparam via openssl
```
openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
```

### Update the config at /etc/nginx/nginx.conf
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

    #Disable SSL
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

    #Optimise cipher suite
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5;

    #Enable DH key exchange (i.e. enable DH params)
    ssl_dhparam /etc/nginx/ssl/dhparam.pem;

    #Enable HSTS
    add_header Strict-Transport-Security "max-age=31536000" always;

    #Cache SSL sessions
    ssl_session_cache shared:SSL:40m;
    ssl_session_timeout 4h;
    ssl_session_tickets on;

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
