# Redis

# Why use Redis
### traditional DB is too slow
### 150 - 200 records per second

### in memory db - memcached
### hundreds of thousands operations per second

### What is Redis?
- NoSQL database
- key value storage
- complex data type
- pub/sub channels


### Redis port
6379

### check redis installation
redis-cli
quit

### clear the DB
FLUSHALL


### SET
SET foo 42

### GET
GET foo

### EXISTS
EXISTS foo

### with time to live 20 seconds
SET bar "Hello" EX 20

### time to live in millisec
SET demo 'Demo' PX 1000


### GETSET - get the current value and set the new current value
GETSET foo 'This is some new value'

### Append to the existing value
SET hello 'Hello'
APPEND hello 'World'


### Show all existing keys (KEYS is used only for debugging, not in prod)
KEYS *


### Increment/decrement numbers
SET foo 1
INCR foo
DECR foo





### In contrast to memcached, redis supports complex data types
### Hash Tables
HSET person1 name 'Jack'
HSET person1 age 32

HGET person1 name
HGET person1 age

HGETALL person1
HVALS person1




# SETS
SADD persons 'Tom'
SADD persons 'Jack'
SMEMBERS persons

SADD another 'Tom'
SADD another 'James'

### show the number of members in a set
SCARD persons

### show the union of two sets
SUNION persons another

### show the difference between the first and the second set
### (e.g. returns 'Jack')
SDIFF persons another

### show the intersect 
### (e.g. returns 'Tom')
SINTER persons another

### remove some random element from the set




# LISTS
### left push some element into the list
LPUSH mylist 'one'

### show the first element of the list
LRANGE mylist 0 1

### show all elements of the list
LRANGE mylist 0 -1

### right push some element into the list
RPUSH mylist 'two'

### left pop some element
LPOP mylist

### right pop some element
RPOP mylist

### show the length of the list
LLEN mylist



# SORTED SETS
ZADD persons 1980 'Tom'
ZADD persons 1990 'Jack'
ZRANGE persons 0 -1
ZRANGE persons 0 -1 WITHSCORES












# TRANSACTIONS (i.e. operations are queued)
### put the operations into a queue and then execute them
MULTI 
INCR foo
DECR bar
EXEC

### queued operations can be discarded
MULTI 
INCR foo
DECR bar
DISCARD









# PUB/SUB
### client 1 subscribes to the channel 'news'
SUBSCRIBE news


### client 2 publishes and client 1 receives the message
PUBLISH news 'hello world'
