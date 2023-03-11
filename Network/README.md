# VPC-Terraform

## 使用技術
- Terraform v1.4.0

## ディレクトリ構成
```
.
├── README.md
├── main.tf
├── module
│   └── network
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
└── terraform.tfvars
```

## 構築方法
1. 初期化 & モジュール読み込み
```
terraform init
```

2. リソース作成
```
terraform apply
```

3. リソース削除
```
terraform destroy
```
