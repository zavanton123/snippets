### S3 AWS CLI
### show help
aws s3 help

### list contents
aws s3 ls
aws s3 ls s3://some-bucket-name-here

### copy the file to local dir
aws s3 cp s3://demo-zavanton-s3-bucket-1/face.png ./new_face.png

### create a bucket
aws s3 mb s3://demo-zavanton-s3-bucket-2

### remove the bucket (it must be empty)
aws s3 rb s3://demo-zavanton-s3-bucket-2





### How to test if some action has permissions?
### E.g., check if you have permission to run instance (with --dry-run)
aws ec2 run-instances --dry-run --image-id some-ami-id-here --instance-type t2.micro --region eu-central-1




### STS Decode Errors
aws sts decode-authorization-message --encoded-message some-message-here



### AWS EC2 Instance Metadata 
### Note: this should be run from within the EC2 instance
### E.g., curl http://169.254.169.254/latest/meta-data 
http://169.254.169.254/latest/meta-data


### How to use Profiles?
aws configure --profile some-name-here
### then run any command with this profile
aws s3 ls --profile some-name-here








