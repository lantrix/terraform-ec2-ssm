output "ec2-instance" {
  description = "The EC2 instance"
  value       = "${aws_instance.ec2-workstation.id}"
}

output "ec2-instance-profile" {
  description = "The EC2 Instance Profile"
  value       = "${aws_iam_instance_profile.techdebug_profile.id}"
}