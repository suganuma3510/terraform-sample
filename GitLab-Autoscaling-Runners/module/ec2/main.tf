#--------------------------------------------------------------
# AMI
#--------------------------------------------------------------
# aws ec2 describe-images --filters "Name=name,Values=amzn2-ami-kernel*" "Name=architecture,Values=x86_64" --query "sort_by(Images, &CreationDate)[].Name" --owners amazon --no-cli-pager
data "aws_ami" "amazon2_amd64" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["amazon"]
}

#--------------------------------------------------------------
# EC2
#--------------------------------------------------------------

resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.amazon2_amd64.id
  instance_type          = "t3.micro"
  subnet_id              = var.pub_subnet_ids[0]
  vpc_security_group_ids = [var.security_group]
  iam_instance_profile   = var.iam_instance_profile_name
  user_data              = var.template_user_data
}
