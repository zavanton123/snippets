# Basic Auth

### We need apache tools
```
apt-get install apache2-utils
```

### Generate a user and password and store it to some file
```
htpasswd -c /etc/nginx/.htpasswd user1
```

### Update the config file at /etc/nginx/nginx.conf
### Protect some location with basic auth 
```
location / {
  auth_basic "Secure area";
  auth_basic_user_file /etc/nginx/.htpasswd;
  try_files $uri $uri/ =404;
}
```
