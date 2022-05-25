# GitLab-Autoscaling-Runners

## 使用技術
- AWS
- Terraform v1.0.11

## ディレクトリ構成
```
.
├── README.md
├── main.tf
├── module
│   ├── ec2
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── iam
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── network
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
└── terraform.tfvars
```

## 構築方法
1. リソース作成
```
terraform apply
```

2. リソース削除
```
terraform destroy
```

## 接続方法

### 参考
- [Autoscaling GitLab Runner on AWS EC2 \| GitLab](https://docs.gitlab.com/runner/configuration/runner_autoscale_aws/)
- [Advanced configuration \| GitLab](https://docs.gitlab.com/runner/configuration/advanced-configuration.html)
- [npalm/terraform\-aws\-gitlab\-runner: Terraform module for AWS GitLab runners on ec2 \(spot\) instances](https://github.com/npalm/terraform-aws-gitlab-runner)