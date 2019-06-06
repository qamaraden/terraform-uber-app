# Terraform-uber-app

Used Terraform to automate the process of running the uber app using aws 

The main.tf had instructions to create the following:
- 1 Vpc 
- 1 public and 1 private subnet
- Instances within those subnets 
- Security groups for those instances
- Key Pair

You can clone this repo, and 

`terraform apply`

this will create the instances in aws.

You can connect to the public instance and follow the steps below in your terminal:

`chmod 400 ~/.ssh/team_2_key_pair.pem`

`ssh -i "team_2_key_pair.pem" ubuntu@ec2-34-253-220-193.eu-west-1.compute.amazonaws.com`

`python app/app.py`

Connect to your instance using its Public DNS provided in the AWS.
 
