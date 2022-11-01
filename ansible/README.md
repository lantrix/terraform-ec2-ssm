# Ansible

Based upon https://luktom.net/en/e1693-ansible-over-aws-systems-manager-sessions-a-perfect-solution-for-high-security-environments


### Ansible setup

If running locally install roles and collections.

```
ansible-galaxy install -r requirements.yml
```

## Populate Secrets

Ensure the `ec2-inventory.yml` has the secrets populated.

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
```

## Setup Server for Soapbox BE

```shell
ansible-playbook -i ec2-inventory.yml soapbox-be-setup.yml
```

## Setup PostgreSQL Server for Soapbox BE

```shell
ansible-playbook -i ec2-inventory.yml soapbox-be-database.yml
```

## Configure Server for Soapbox BE

```shell
ansible-playbook -i ec2-inventory.yml soapbox-be-configure.yml
```

## Server secrets & instance config

If you want to generate new ones skip the playbook here

### Upload your secrets/config

```shell
ansible-playbook -i ec2-inventory.yml soapbox-be-secrets.yml
```

### Create new secrets/config

If you want to generate new server secrets, generate a new instance config as follows:

Enter the source code directory, and become the pleroma user:

```shell
cd /opt/pleroma
sudo -Hu pleroma bash
```

Generate new config & secrets:

```shell
MIX_ENV=prod mix pleroma.instance gen
```

If you’re happy with it, rename the generated file so it gets loaded at runtime:

```shell
mv config/generated_config.exs config/prod.secret.exs
```

This step also generated database config for next step.

## Setup Database

```shell
ansible-playbook -i ec2-inventory.yml soapbox-be-db.yml
```

## Setup Nginx & SSL

```shell
ansible-playbook -i ec2-inventory.yml soapbox-be-nginx.yml
```

## Setup Frontend

```shell
ansible-playbook -i ec2-inventory.yml soapbox.yml
```
