# OIDC-Terraform


## 必須条件

- Terraform
- AWS CLI
- GitHub CLI

## 事前準備

1. GitHubリポジトリを作成する
```sh
gh repo create <your-repo-name> --private --clone --add-readme
```

## 手順
1. IDプロバイダ＆GitHub Actions用のロールを作成する
```sh
terraform init
terraform plan
terraform apply
```

2. GitHub Secretsを設定する
```sh
gh secret set AWS_ID --body 1234567890123
gh secret set AWS_ROLE_NAME --body github-ctions
```
