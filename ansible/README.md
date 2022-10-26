# Ansible

Based upon https://luktom.net/en/e1693-ansible-over-aws-systems-manager-sessions-a-perfect-solution-for-high-security-environments

## Setup

Setup SSH for the tunnel over SSM for ansible.

1. Capture information about the server and availability-zone in local variables:

```shell
instanceid=$(aws ec2 describe-instances \
  --query 'Reservations[].Instances[].InstanceId' \
  --filters Name=tag:Name,Values=soapbox-demo Name=instance-state-name,Values=running \
  --output text)
echo "Instance is $instanceid"
availabilityzone=$(aws ec2 describe-instances \
  --instance-id ${instanceid} \
  --query 'Reservations[].Instances[].Placement.AvailabilityZone' \
  --output text)
echo "Availability Zone is $availabilityzone"
```

2. Generate your SSH key & set permissions:

```shell
ssh-keygen -q -t rsa -N '' -f ~/.ssh/${instanceid} <<<y 2>&1 >/dev/null
chmod 600 ~/.ssh/${instanceid}*
```

3. Send the new SSH publickey to the Gantry jumpbox:

```shell
aws ec2-instance-connect send-ssh-public-key \
  --instance-id ${instanceid} \
  --availability-zone ${availabilityzone} \
  --instance-os-user ssm-user \
  --ssh-public-key file://~/.ssh/${instanceid}.pub
```

There is only 60 seconds allowable between the previous `send-ssh-public-key` command and the next ssh command, before the key is automatically removed from the EC2 instance.

Each time a new session is required, both of the two steps `send-ssh-public-key` and ssh need to be re-executed, within this time period.

```shell
ansible all -i ec2-inventory.yml -m ping
ansible-galaxy install --roles-path ./roles/ -r requirements.yml
ansible-playbook -i ec2-inventory.yml rebased-setup.yml
ansible-playbook -i ec2-inventory.yml rebased-configure.yml
```
