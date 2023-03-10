# RDS-Aurora-Terraform

## 使用技術
- Amazon RDS - Aurora
- Terraform v1.1.9

## ディレクトリ構成
```
.
├── README.md
├── main.tf
├── module
│   ├── network
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── rds
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── secrets
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

<details><summary>参考</summary>

- [TerraformでRDS\(Aurora Mysql\)の作成](https://zenn.dev/nicopin/books/58c922f51ea349/viewer/d98efb)
- [TerraformでAmazon Auroraクラスタを自動構築する\(基本編\) \- Qiita](https://qiita.com/neruneruo/items/a7c5f7fa80fbf9d6a828)

</details>
