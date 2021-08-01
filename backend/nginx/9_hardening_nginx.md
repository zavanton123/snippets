# Hardening NGINX

### Keep the packages up to date
```
apt-get update && apt-get upgrade -y
```





### Check your version of nginx
```
nginx -v
```

### Check the latest version changes at 
- https://nginx.org/en/CHANGES
### download the new version, recompile and reinstall NGINX 
### if some critical updates have been made

### Do not show nginx version in 'server' response header
### update the config
```
server_tokens off;
```










### Prevent xframes attach and XSS attacks 
```
add_header X-Frame-Options "SAMEORIGIN";
add_header X-XSS-Protection "1; mode=block";
```













### Remove some unnecessary NGINX modules
### (e.g. exclude the autoindex module)
```
./configure --without-http_autoindex_module \
  --sbin-path=/usr/bin/nginx --conf-path=/etc/nginx/nginx.conf \
  --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log \
  --with-pcre --pid-path=/var/run/nginx.pid --with-http_ssl_module \
  --with-http_image_filter_module=dynamic --modules-path=/etc/nginx/modules \
  --with-http_v2_module
```
### recompile and install
```
make 
make install
```
