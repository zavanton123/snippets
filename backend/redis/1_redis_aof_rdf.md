# Redis Info

### Stop the global redis-server service
sudo systemctl stop redis-server

### Restart the global redis-server service
sudo systemctl stop redis-server







### Start the local redis-server
redis-server

### The redis config file location
```
/etc/redis/redis.conf
```

### Change the default port 6379 via /etc/redis/redis.conf
```
port 6363
```


### Or change the port via command line
redis-server --port 8080

### The client must listen to the new port
redis-cli -p 8080





### Redis Persistence
- Append-Only File (AOF) (i.e. logs each record)
- Redis Database File (i.e. snapshot of data)


### Edit the /etc/redis/redis.conf file
### Configure RDF settings
```
save 900 1
save 300 10
save 60 10000
```

### Enable Append Only
```
appendonly yes

```


### create /etc/redis/redis2.conf
```
port 6380
replicaof 127.0.0.1 6379
appendfilename "appendonly2.aof" 
```


### Multiple get/set
MSET first_name 'Jack' last_name 'Tomson' age 32
MGET first_name last_name 



### Delete key
DEL first_name

### Make some key expire after 3 seconds
SET data 'this is some data'
EXPIRE data 3

