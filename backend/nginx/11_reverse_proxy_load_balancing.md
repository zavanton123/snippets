# Reverse Proxy and Load Balancing

### Install nginx locally and run it at localhost:8888
### nginx config at /etc/nginx/nginx.conf
```
events {}

http {
  server {
    listen 8888;

    location / {
      return 200 "Hello from NGINX!\n";
    }
  }
}
```

### Run a NodeJS server at localhost:9999
### index.js
```
const express = require('express');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.use("/", (req, res) => {
  return res.send("Hello from NodeJS\n");
});

app.listen(9999);
```


### Update the nginx config to set up  reverse proxy
```
events {}

http {
  server {
    listen 8888;

    location / {
      return 200 "Hello from NGINX!\n";
    }

    location /nodejs {
      proxy_pass 'http://localhost:9999/';
    }
  }
}
```

### Check the reserve proxy is ok
```
curl http://localhost:8888/nodejs
```















