### RDS (Relational Database Service)

### RDS Backups:
- Automated Backups
- DB Snapshots

### RDS Read Replicas

### RDS Storage Auto Scaling

### RDS Read Replicas
- used for scaling
- Up to 5 (within the same AZ, cross-AZ, cross-Region)
- ASYNC replication
- For SELECT queries
- Read Replicas network cost (free within the same region, not free when it is cross-Region)

### RDS Multi AZ (Disaster Recovery)
- not used for scaling
- Master DB vs Standby DB
- SYNC replication
- One DNS name

### RDS - from Single-AZ to Multi-AZ
- zero downtime operation
- press 'modify'
    > snapshot of master DB
    > restore to different AZ
    > sync replication of master DB to standby DB


### DB Encryption
### RDS KMS (Key Management Service) (i.e. AES-256 encryption)





### ElastiCache (for Redis or Memcached)
- Application queries ElastiCache ('cache hit')
- If no entry is found ('cache miss'), it reads from the DB
- Then it writes the result to the ElastiCache


### Caching Strategies:
- Lazy Loading (Cache-Aside, Lazy Population) (read penalty and no cache churn)
- Write-Through (write penalty and cache churn)


### Cache Evictions and TTL (Time-to-live)


# ElastiCache Replication
### Cluster Mode Disabled
- There is a Shard
- There is a Primary Node in the Shard
- There are 0 - 5 Replica Nodes in the Shard
- The Primary Node is used for Read/Write
- The Replica Nodes are used for Reads only
- Multi-AZ capability

### Cluster Mode Enabled
- There are several Shards
- There are 1 Primary Node and 0 - 5 Replica Nodes in each Shard
- Multi-AZ capability
