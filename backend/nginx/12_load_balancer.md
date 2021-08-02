# Load Balancer

### create 3 NodeJS servers running at ports: 10001, 10002, 10003
```
const express = require('express');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.use("/", (req, res) => {
  console.log(JSON.stringify(req.headers));
  return res.send("Hello from Server 1\n");
});

app.listen(10001);
```


### Create a new config for NGINX 
### /etc/nginx/load-balancer.conf
```
events {}

http {
  server {
    listen 8888;
    location / {
      proxy_pass 'http://localhost:10001/';
    }
  }
}
```


### Run NGINX with the new config
```
systemctl stop
nginx -c /etc/nginx/load-balancer.conf
```

### Request the nginx server every 0.5 sec
```
while sleep 0.5; do curl http://localhost:8888; done
```




### Update nginx config to create and use upstream
### /etc/nginx/load-balancer.conf
```
events {}

http {

  upstream nodejs_servers {
    server localhost:10001;
    server localhost:10002;
    server localhost:10003;
  }
  
  server { 
    listen 8888; 
    location / { 
      proxy_pass http://nodejs_servers;
    }
  }
}
```

### Reload the nginx server and test 
```
nginx -s reload 
while sleep 0.5; do curl http://localhost:8888; done
```


### Load Balancer Options
### Sticky Sessions
```
events {}

http {

  upstream nodejs_servers {
    ## enable sticky sessions load balancing
    # ip_hash;

    ## enable least connected load balancing
    least_conn;

    server localhost:10001;
    server localhost:10002;
    server localhost:10003;
  }

  server {
    listen 8888;
    location / {
      proxy_pass http://nodejs_servers;
    }
  }
}
```
