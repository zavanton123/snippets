# Let's Encrypt SSL Certificate

### Create a new ubuntu EC2 instance with some valid domain name pointing to it
### (e.g. exevato.com)

### ssh to the EC2 instance
```
ssh -i CustomKey.pem ubuntu@3.69.23.70
```

### Update and upgrade packages
```
sudo su
apt-get update -y && apt-get upgrade -y
```

### install nginx
```
apt-get install -y nginx
```

### check nginx is running
```
px aux | grep nginx
systemctl status nginx
curl -I http://3.69.23.70
```

### create some basic config
### /etc/nginx/nginx.conf
```
user www-data;
worker_processes auto;

events {
}

http {
  server {
    listen 80;

    location / {
      return 200 "Hello from NGINX";
    }
  }
}
```

### reload the service
```
systemctl reload nginx
```

### check that http is ok, but https is not ok
```
curl -I http://3.69.23.70
curl -I https://3.69.23.70
```


### Install certbot
### go to the certbot site https://certbot.eff.org 
### and follow the instructions
### check certbot installation is ok
```
certbot --help
```

### Run default certbot command for nginx
```
certbot --nginx
```

### check the certificates are installed
```
ls -la /etc/letsencrypt/live/exevato.com
```

### Check the modifications made by certbot to nginx config
```
user www-data;
worker_processes auto;

events {}

http {
  server {
    server_name exevato.com;

    location / { 
      return 200 "Hello from NGINX";
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/exevato.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/exevato.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
  }
  
  server {
    if ($host = exevato.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    listen 80;
    server_name exevato.com; 
    return 404; # managed by Certbot
  }
}
```

### Renew the certificates manually
```
certbot renew
```


### Create a cron job to renew certificates daily
```
crontab -e
```
### add this 
```
@daily certbot renew
```
### show all the cron entries
```
crontab -l
```
