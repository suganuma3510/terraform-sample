# Lambda-Terraform

## 使用技術
- Terraform v1.6.6

## ディレクトリ構成
```
.
├── README.md
├── main.tf
├── module
│   ├── lambda
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── lambda_layer
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── sample_python_function
│   ├── makefile
│   └── src
│       ├── index.py
│       └── requirements.txt
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
