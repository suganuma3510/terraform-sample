# CloudFront-Terraform

## 使用技術
- Terraform v1.9.5

## ディレクトリ構成
```
.
├── README.md
├── content
│   ├── error
│   │   └── 404.html
│   └── static
│       └── index.html
├── main.tf
├── module
│   ├── cf_functions
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── cloudfront
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── s3_oac
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── src
│   └── add_index_html.js
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

3. S3へ静的コンテンツを配置
```sh
aws s3 cp content/static s3://dev-cloudfront-sample/test/ --recursive
aws s3 cp content/error s3://dev-cloudfront-sample/error/ --recursive
```
