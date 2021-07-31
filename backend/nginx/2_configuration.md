# NGINX Configuration

### Main terminology:
- Context (i.e. scope that contains directives)
- Directive (key value pairs)





## Set up a basic virtual host
```
mkdir -p /sites/demo
```

### Note: you nginx user and directory user must be the same
### and add 'user www-data' to /etc/nginx/nginx.conf
```
chown -R www-data:www-data /sites/demo 
```





### Add the files
### index.html
```
<html>
<head>
  <title>Hello</title>
  <link rel="stylesheet" href="style.css" type="text/css" />
</head>
<body>
  <h1>Hello world</h1>
</body>
</html>
```

### style.css
```
h1 {
  color: red;
}
```

### Update the configuration file:
### /etc/nginx/nginx.conf
```
events {}

http {

  include mime.types

  server {
    listen 80;
    server_name 54.93.123.207;

    root /sites/demo;
  }
}
```

### Check if the updated config is ok
```
nginx -t
```

### Check the type of style.css returned by nginx
### Note: it should be 'text/css', because we have loaded the 'mime.types'
```
curl -I http://54.93.123.207/style.css
```

### reload nginx to enable the new configuration
```
sudo systemctl reload nginx
```





## Location Blocks
### make a custom location '/greet' that returns a string
### reload the nginx for the new config to take effect (sudo systemctl reload nginx)

```
events {}

http {

  include mime.types

  server {
    listen 80;
    server_name 54.93.123.207;

    root /sites/demo;

    location /greet {
      return 200 "hello from here...";
    } 
  }
}
```


### You can use prefix match
```
location /greet {
  return 200 "this is prefix match";
} 
```

### You can use exact match
```
location = /greet {
  return 200 "this is exact match";
} 
```

### You can use regex match
### Case Sensitive
```

location ~ /greet[0-9] {
  return 200 "this is regex match";
} 
```

### You can use regex match
### Case Insensitive
```

location ~* /greet[0-9] {
  return 200 "hello from here...";
} 
```

### You can use preferential prefix match
### (i.e. its priority is higher than regex priority)
```

location ^~ /Greet2 {
  return 200 "this is preferenctial prefix match";
} 
```


### Location matching priorities
- Exact match (i.e =)
- Preferential prefix match (i.e. ^~)
- REGEX match (i.e. ~ or ~*)
- prefix match







## Nginx Variables

### Some build-in variables
```
location /inspect {
  return 200 "$host - $uri - $args";
}
```

### You can extract arguments

```
location /inspect {
  return 200 "Age: $arg_age, name: $arg_name";
}
```


### Use conditionals
```
http {
  server {
    if ( $arg_apiKey != 1234 ) {
      return 401 "Incorrect API key";
    }
  }
}
```

### Create your own variables
```
http {
  server {
    set $weekend "No";

    if ( $date_local ~ "Saturday|Sunday" ) {
      set $weekend "Yes";
    }

    location /is_weekend {
      return 200 $weekend;
    }
  }
}
```









## Rewrites
- rewrite some-pattern some-URI
- return some-status some-URI

### redirect with 'return' statement
### client makes the first request
### then the client makes the second request
```
location /logo {
  return 307 /thumb.png;
}
```

### redirect with 'rewrite' statement
### client makes only one request
### the server redirects internally
```
http {
  server {
    rewrite ^/user/\w+ /greet;

    location /greet {
      return 200 "Greeting to user";
    }
  }
}
```


### with 'rewrite' we can capture the parts of the original path
```
http {
  server {
    rewrite ^/user/(\w+) /greet/$1;

    location /greet {
      return 200 "Greeting to user";
    }

    location = /greet/john {
      return 200 "Greeting to John";
    }
  }
}
```


### You can use the 'last' flag with the 'rewrite'
### result: style.css is shown
```
http {
  server {
    rewrite ^/user/(\w+) /greet/$1;
    rewrite ^/greet/john /style.css;

    location /greet {
      return 200 "Greeting to user";
    }

    location = /greet/john {
      return 200 "Greeting to John";
    }
  }
}
```


### result: Greeting to John is shown
```
http {
  server {
    rewrite ^/user/(\w+) /greet/$1 last;
    rewrite ^/greet/john /style.css;

    location /greet {
      return 200 "Greeting to user";
    }

    location = /greet/john {
      return 200 "Greeting to John";
    }
  }
}
```





## try_files
```
events {}

http {
  include mime.types;

  server {
    listen 80;
    server_name 54.93.123.207;

    root /sites/demo;

    try_files $uri /non-existing-cat.png /greet /my-404;

    location /my-404 {
      return 404 "Page not found";
    }

    location /greet {
      return 200 "Hello, user";
    }
  }
}
```



### Named locations
### use '@'

```
events {}

http {
  include mime.types;

  server {
    listen 80;
    server_name 54.93.123.207;

    root /sites/demo;

    try_files $uri /non-existing-cat.png /greet @my-404;

    location @my-404 {
      return 404 "Page not found";
    }

    location /greet {
      return 200 "Hello, user";
    }
  }
}
```



## Logging
- Error logs
- Access logs

### clear the logs
```
cd /var/log/nginx
echo '' > error.log
echo '' > access.log
```

### custom log file for custom location

```
events {}

http {
  include mime.types;

  server {
    listen 80;
    server_name 54.93.123.207;

    root /sites/demo;

    location /secure {
      access_log /var/log/nginx/secure.access.log;
      return 200 "This is a secure page";
    }
  }
}
```




## Inheritance and Directive Types
- Standard Directive
- Array Directive
- Action Directive




## Serving PHP
```
apt-get update -y
apt-get install -y php-fpm
systemctl list-units | grep php
systemctl status php7.4-fpm
```

### update the configuration
### /etc/nginx/nginx.config
```
user www-data;

events {}

http {
  include mime.types;

  server {
    listen 80;
    server_name 54.93.123.207;

    root /sites/demo;

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

### check the php fpm location
```
find / -name *fpm.sock;
```

### Create php file
### /sites/demo/info.php
```
<?php phpinfo(); ?>
```

### If permission denied error, check the users of the processes
```
ps aux | grep nginx
ps aux | grep php
```

### Create index.php
### check if the index setting is working ok
### http://some-uri:80
```
<h1>Date: <?php echo date("l jS F"); ?></h1>
```




## Worker Processes
### check the current nginx processes
```
systemctl status nginx
ps aux | grep nginx
```

### Note: the number of worker processes must equal the number of CPU cores
### check the number of cores
```
nproc
lscpu
```

### configure the nginx to automatically match CPUs to worker processes
### /etc/nginx/nginx.conf
```
worker_processes auto;
```

### Check the number of files to be opened
### e.g. 1024
```
ulimit
```

### update the configuration
```
events {
  worker_connections 1024;
}
```

### You can change the pid file location setting
```
pid /var/run/new_nginx.pid;
```






## Add Dynamic Modules
### Check the current configuration
### location: downloaded nginx source code folder
```
nginx -V
./configure --help
```

### install some new dependencies
```
apt-get install -y libgd-dev
```

### call ./configure, pass the previous config options, plus the dynamic modules and add --modules-path
/home/ubuntu/nginx-1.21.1# ./configure \
  --sbin-path=/usr/bin/nginx \ 
  --conf-path=/etc/nginx/nginx.conf \ 
  --error-log-path=/var/log/nginx/error.log \ 
  --http-log-path=/var/log/nginx/access.log \ 
  --with-pcre --pid-path=/var/run/nginx.pid \ 
  --with-http_ssl_module \ 
  --with-http_image_filter_module=dynamic 
  --modules-path=/etc/nginx/modules


### compile the newly configured nginx and install it
```
make
make install
```

### Update the configuration
```
load_module /etc/nginx/modules/ngx_http_image_filter_module.so;

http {
...
  server {
    location /some-cat.png {
      image_filter rotate 180;
    }
  }
}
```


