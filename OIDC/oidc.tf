data "aws_caller_identity" "default" {}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

# https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html#idp_oidc_Create_GitHub
resource "aws_iam_role" "github_actions" {
  name = "github-ctions-${var.name}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : aws_iam_openid_connect_provider.github.arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          },
          "StringLike" : {
            "token.actions.githubusercontent.com:sub" : [
              "repo:${var.repository}/*"
            ]
          }
        }
      },
      # https://github.com/nektos/act/discussions/2029#discussioncomment-12656262
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.default.account_id}:root"
        },
        "Action" : [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

data "aws_iam_policy" "github_actions" {
  for_each = toset([
    "ReadOnlyAccess",
    # "PowerUserAccess",
    # "AWSCodeDeployRoleForECS",
  ])

  name = each.key
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  for_each = data.aws_iam_policy.github_actions

  role       = aws_iam_role.github_actions.name
  policy_arn = each.value.arn
}
