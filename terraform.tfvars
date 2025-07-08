vpc-cidr = "14.0.0.0/16"
cidr-allowing-all = "0.0.0.0/0"
public-subnet-cidr = {
  public_1a = {
    cidr = "14.0.1.0/26"
    az   = "us-east-2a"
  }
  public_1b = {
    cidr = "14.0.2.0/26"
    az   = "us-east-2b"
  }
}

private-subnet-cidr = {
  private_1a = {
    cidr = "14.0.3.0/26"
    az   = "us-east-2a"
  }
  private_1b = {
    cidr = "14.0.4.0/26"
    az   = "us-east-2b"
  }
}

ownername = "Umar"
ec2_ami = "ami-0c71c8ad33d8ff07d"
asg_max_size = "3"
asg_min_size = "1"
asg_desired_capacity = "2"
ec2_type = "t2.micro"
aws_region = "us-east-2"