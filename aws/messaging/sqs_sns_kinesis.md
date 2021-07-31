# Messaging:
- SQS (Simple Queue Service) - queue
- SNS (Simple Notification Service) - pub/sub
- Kinesis (real-time streaming)




### SQS
- Queue Access Policy
- Message Visibility Timeout
- Dead Letter Queue
- Delivery Delay
- Long Polling (receive message wait time)
- SQS Extended Client (use S3 bucket to store large message)
- FIFO Queue




### SNS
- pub/sub
- SNS Topic
- SNS Subscribers (http/https, SQS, Lambda, Email, SMS messages, mobile notifications)
- SNS Message Filtering


### 'Fan Out' Strategy
- One publisher -> one SNS topic -> two SQS queues (subscribed to the SNS topic) process the message


### Kinesis
### Kinesis Data Streams (Shards)

Producer -> 
Record (Partition Key + Data Blob) -> 
Kinesis (Shards) -> 
Record (Partition Key, Sequence Num, Data Blob) -> 
Consumer

### Kinesis Data Firehose

### Kinesis Data Analytics










