# Headers and Expires

## 'Expires' header
### add a custom header to some location
```
location /thumb.png {
  add_header my_header "Hello world";
}
```

### test custom header
```
curl -I http://18.192.99.149/thumb.png
```


### set the 'Expires' header
```
location /thumb.png {
  add_header Cache-Control public;
  add_header Pragma public;
  add_header Vary Accept-Encoding;
  expires 60m;
}
```


### Apply the 'Expires' header to many static resources
```
location ~* \.(css|js|jpg|png)$ {
    access_log off;
    add_header Cache-Control public;
    add_header Pragma public;
    add_header Vary Accept-Encoding;
    expires 60m;
}
```






## Compressed responses with gzip
### update the configuration
```
http {
  gzip on;
  gzip_comp_level 3;
  gzip_types text/css;
  gzip_types text/css text/javascript;
}
```

### the client must indicate that it accepts zipped content
```
curl -I -H "Accept-Encoding: gzip, deflate" http://18.192.99.149/style.css
```







## FastCGI Cache (Micro Cache)
### (i.e. cache for dynamic php content)
```
user www-data;

worker_processes auto;

events {
  worker_connections 1024;
}

http {
  include mime.types;

  #setup microcache
  fastcgi_cache_path /tmp/nginx_cache levels=1:2 keys_zone=MYCACHE:100m inactive=60m;
  fastcgi_cache_key "$scheme$request_method$host$request_uri";

  server {
    listen 80;
    server_name 18.192.99.149;

    root /sites/demo;
    index index.php index.html;

    location / {
      try_files $uri $uri/ =404;
    }

    location ~\.php$ {
      include fastcgi.conf;
      fastcgi_pass unix:/run/php/php7.4-fpm.sock;

      #enable microcache
      fastcgi_cache MYCACHE;
      fastcgi_cache_valid 200 60m;
      fastcgi_cache_valid 404 10m;
    }
  }
}
```

### test with Apache Bench
### install it
```
apt-get install -y apache2-utils 
```

### use Apache Bench to create 100 request via 10 connections
```
ab -n 100 -c 10 http://18.192.99.149/
```

### $upstream_cache_status is used to answer the question:
### is the response coming from cache?
### put it into a header
```
add_header X-Cache $upstream_cache_status;
```

### check the result
```
curl -I http://18.192.99.149
```










### add dynamic cache exceptions
```
ser www-data;

worker_processes auto;

events {
  worker_connections 1024;
}

http {
  include mime.types;

  #setup microcache
  fastcgi_cache_path /tmp/nginx_cache levels=1:2 keys_zone=MYCACHE:100m inactive=60m;
  fastcgi_cache_key "$scheme$request_method$host$request_uri";

  #is the response coming from cache
  add_header X-Cache $upstream_cache_status;

  server {
    listen 80;
    server_name 18.192.99.149;

    root /sites/demo;
    index index.php index.html;

    #Set default cache exception to false
    set $no_cache 0;

    #Process the argument to enable cache exception
    if ($arg_skipcache = 1) {
      set $no_cache 1;
    }

    location / {
      try_files $uri $uri/ =404;
    }

    location ~\.php$ {
      include fastcgi.conf;
      fastcgi_pass unix:/run/php/php7.4-fpm.sock;

      #enable microcache
      fastcgi_cache MYCACHE;
      fastcgi_cache_valid 200 60m;
      fastcgi_cache_valid 404 10m;

      #use cache exception
      fastcgi_cache_bypass $no_cache;
      fastcgi_no_cache $no_cache;
    }
  }
}
```

### test cache exception on the client side
```
curl -I http://18.192.99.149?skipcache=1
```
