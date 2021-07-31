### Resources



### Parameters (can be referenced via Fn::Ref or !Ref)
Example define parameter:
```
Parameters:
  SecurityGroupDescription:
    Description: Security Group Description
    Type: String
```
Example use parameter:
```
  ServerSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: !Ref SecurityGroupDescription
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
```







### Mappings (can be referenced via Fn::FindInMap or !FindInMap)
  FindInMap [ MapName, TopLevelKey, SecondLevelKey ]
Example:
```
Mappings:
  RegionMap:
    us-east-1:
      "32": "ami-3231312"
      "64": "ami-5454545"
    us-west-1:
      "32": "ami-78787"
      "64": "ami-98988"
Resources:
  MyEc2Instance:
    Type: AWS::EC2:Instance
    Properties:
      ImageId: !FindInMap [RegionMap, !Ref "AWS:Region", 32]
      InstanceType: t2.micro
```
  
  
  
  
  
### Outputs (can be imported via Fn::ImportValue or !ImportValue)
Define output example:
```
Outputs:
  StackSSHSecurityGroup:
    Description: The SSH Security Group for our Company
    Value: !Ref MyCompanyWideSSHSecurityGroup
    Export:
      Name: SSHSecurityGroup
```
Import output example:
```
Resources:
  MySecureInstance:
    Type: AWS::EC2::Instance
    Properties:
      AvailabilityZone: us-east-1a
      ImageId: ami-a4c7edb2
      InstanceType: t2.micro
      SecurityGroups:
        - !ImportValue SSHSecurityGroup
```


                                                                
      
### Conditions    
Create a condition example:
```
Conditions:
  CreateProdResources: !Equals [ !Ref EnvType, prod ]
```      

Functions:
- And
- Equals
- If
- Not
- Or

Use the condition example:
```
Resources:
  MountPoint:
    Type: "AWS::EC2::VolumeAttachment"
    Condition: CreateProdResources
```
      
      


### Intrinsic Functions
- Ref
- Fn::GetAtt
- Fn::FindInMap
- Fn::ImportValue
- Fn::Join
- Fn::Sub
- Condition functions (If, Equals, And, Or, Not)




### GetAtt Example (get AZ from EC2)
```
Resources:
  EC2Instance:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-123456
      InstanceType: t2.micro

NewVolume:
  Type: AWS::ECS::Volume
  Condition: CreateProdResources
  Properties:
    Size: 100
    AvailabilityZone:
      !GetAtt: EC2Instance.AvailabilityZone
```




### Join demo
### e.g. create "a:b:c"
!Join [ ":", [a, b, c] ]




### CloudFormation Rollbacks

### CloudFormation ChangeSets

### CloudFormation Nested Stacks VS Cross Stacks

### CloudFormation StackSet










      
      
      
      

