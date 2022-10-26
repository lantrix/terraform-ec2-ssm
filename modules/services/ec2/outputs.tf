output "ec2-instance" {
  description = "The EC2 instance"
  value       = "${aws_instance.soapbox-demo.id}"
}

output "ec2-instance-profile" {
  description = "The EC2 Instance Profile"
  value       = "${aws_iam_instance_profile.soapbox_profile.id}"
}
