variable "region" {}
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
    ami = "ami-03d56f451ca110e99"
    instance_type = "t3.medium"
    subnet_id = "${module.vpc.vpc_public_subnet1}"
    vpc_security_group_ids = [module.vpc.vpc_security_group_id]
    monitoring = "true"
    iam_instance_profile = "${aws_iam_instance_profile.techdebug_profile.id}"
    user_data = "${file("${path.module}/install-ssm.sh")}"
    tags = {
        Name = "ec2-workstation"
    }
}