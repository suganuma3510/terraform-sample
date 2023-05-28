#--------------------------------------------------------------
# IAM Role
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "ecs" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "ecs" {
  name               = "${var.name}-ecs-role"
  assume_role_policy = data.aws_iam_policy_document.ecs.json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# resource "aws_iam_role_policy_attachment" "ssm_read_only" {
#   role       = aws_iam_role.ecs.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMReadOnlyAccess"
# }

# resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
#   role       = aws_iam_role.ecs.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/CloudWatchAgentServerPolicy"
# }
