variable "region" {}
# Get latest Amazon Linux 2 AMI
data "aws_ami" "ubuntu-jammy64" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    # values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
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
  name = "soapbox-demo"
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
    Name = "soapbox-demo"
  }
}
resource "aws_iam_instance_profile" "soapbox_profile" {
  name = "soapbox-demo"
  role = "${aws_iam_role.workstation_role.id}"
}
resource "aws_iam_policy_attachment" "soapbox_attach1" {
  name       = "soapbox-policy-attachment"
  roles      = [aws_iam_role.workstation_role.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_instance" "soapbox-demo" {
    ami = "${data.aws_ami.ubuntu-jammy64.id}"
    instance_type = "m6g.large"
    subnet_id = "${module.vpc.vpc_public_subnet1}"
    vpc_security_group_ids = [module.vpc.vpc_security_group_id]
    monitoring = "true"
    associate_public_ip_address = "true"
    iam_instance_profile = "${aws_iam_instance_profile.soapbox_profile.id}"
    user_data = "${file("${path.module}/bootstrap.sh")}"
    tags = {
        Name = "soapbox-demo"
    }
}
resource "aws_ssm_document" "soapbox-demo" {
  name          = "soapbox-demo"
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
      "runAsDefaultUser": "ssm-user",
      "shellProfile": {
        "windows": "",
        "linux": "{{ linuxcmd }}"
      }
    }
  }
DOC
}
