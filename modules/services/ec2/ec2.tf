variable "region" {}
# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon-linux-2" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
module "vpc" {
  source  = "../vpc"
  region  = var.region
}

resource "aws_iam_role" "workstation_role" {
  name = "ec2-workstation"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name = "ec2-workstation"
  }
}
resource "aws_iam_instance_profile" "techdebug_profile" {
  name = "ec2-workstation"
  role = "${aws_iam_role.workstation_role.id}"
}
resource "aws_iam_policy_attachment" "techdebug_attach1" {
  name       = "techdebug-policy-attachment"
  roles      = [aws_iam_role.workstation_role.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_instance" "ec2-workstation" {
    ami = "${data.aws_ami.amazon-linux-2.id}"
    instance_type = "t3.medium"
    subnet_id = "${module.vpc.vpc_public_subnet1}"
    vpc_security_group_ids = [module.vpc.vpc_security_group_id]
    monitoring = "true"
    associate_public_ip_address = "true"
    iam_instance_profile = "${aws_iam_instance_profile.techdebug_profile.id}"
    user_data = "${file("${path.module}/bootstrap.sh")}"
    tags = {
        Name = "ec2-workstation"
    }
}
resource "aws_ssm_document" "ec2-workstation" {
  name          = "ec2-workstation"
  document_type = "Session"

  content = <<DOC
  {
    "schemaVersion": "1.0",
    "description": "Parameterized document for SSM Session Manager",
    "sessionType": "Standard_Stream",
    "parameters": {
      "linuxcmd": {
        "type": "String",
        "default": "bash -l",
        "description": "The command to run on connection."
      }
    },
    "inputs": {
      "s3BucketName": "",
      "s3KeyPrefix": "",
      "s3EncryptionEnabled": false,
      "cloudWatchLogGroupName": "",
      "cloudWatchEncryptionEnabled": false,
      "kmsKeyId": "",
      "runAsEnabled": true,
      "runAsDefaultUser": "ec2-user",
      "shellProfile": {
        "windows": "",
        "linux": "{{ linuxcmd }}"
      }
    }
  }
DOC
}
