#--------------------------------------------------------------
# IAM Role
#--------------------------------------------------------------

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html#create_task_iam_policy_and_role
resource "aws_iam_role" "default" {
  name               = var.name
  assume_role_policy = var.assume_role_policy
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy
data "aws_iam_policy" "default" {
  for_each = toset(var.iam_policies)

  name = each.key
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "default" {
  for_each = data.aws_iam_policy.default

  role       = aws_iam_role.default.id
  policy_arn = each.value.arn
}
