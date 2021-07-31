### What is serverless?
- You do not have to manage servers
- You just deploy code
- Originally FaaS (Function as a Service)

### AWS Lambda
- Triggers and Destinations
- Sync vs async
- Event Source Mapping
- Resource Based Policies (i.e. other resources have the right to invoke the Lambda)
- (Note: Lambda Resource Based Policies are similar to S3 Bucket Policies)
- IAM role (i.e. lambda hase the right to use other resources)
- By default lambda is created in Amazon VPC
- You can create a lambda in your private VPC, so that it can access your resources (RDS, etc.)
- Lambda Concurrency (reserved/unreserved and provisioned concurrency)
- Lambda Layers
- Lambda Versions (immutable)
- Lambda Aliases (mutable)


### DynamoDB
- NoSQL DB

### API Gateway
- Client > (REST API) > API Gateway > Lambda > DynamoDB
- Integrates with Lambda, HTTP, any AWS Service
- Endpoint types: edge-optimized (default), regional, private
- Deployment Stages



### SAM














