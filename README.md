# terraform-ec2-ssm

Sets up an EC2 workstation with CentOS 7 (x86_64) in `ap-southeast-2`
## Setup

```
terraform init
terraform plan
terraform apply
```

It will run and spit out the EC2 instance ID

![terraform-apply.png](./terraform-apply.png)

## Connect to EC2 with SSM Session Manager

Install [Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) for AWS CLI first.

Start the session using the output `instance_id`

```
aws ssm start-session \
    --document-name ec2-workstation \
    --target i-053cc3cc379ef0069
```