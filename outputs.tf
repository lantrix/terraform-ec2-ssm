output "instance_id" {
  description = "ID of the EC2 instance"
  value       = "${module.ec2.ec2-instance}"
}