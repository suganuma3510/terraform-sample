# RDS-Aurora-Terraform

## 使用技術
- Amazon RDS-Aurora
- Terraform v1.5.5

## ディレクトリ構成
```
.
├── README.md
├── main.tf
├── module
│   └── rds
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

##　Topics
・Aurora の利用可能なエンジンバージョンの一覧を表示
```sh
# --engine [mysql|postgres|aurora-mysql|aurora-postgres]
aws rds describe-db-engine-versions \
  --engine aurora-mysql \
  --query 'DBEngineVersions[*].{Engine: Engine, EngineVersion: EngineVersion, Description: DBEngineVersionDescription}' \
  --output table
```

・Aurora の利用可能なインスタンスタイプを一覧で表示
```sh
# --engine [mysql|postgres|aurora-mysql|aurora-postgres]
aws rds describe-orderable-db-instance-options \
  --engine aurora-mysql \
  --engine-version 8.0.mysql_aurora.3.05.1 \
  --query 'OrderableDBInstanceOptions[*].DBInstanceClass' \
  --output table
```

<details><summary>参考</summary>

- [TerraformでRDS\(Aurora Mysql\)の作成](https://zenn.dev/nicopin/books/58c922f51ea349/viewer/d98efb)
- [TerraformでAmazon Auroraクラスタを自動構築する\(基本編\) \- Qiita](https://qiita.com/neruneruo/items/a7c5f7fa80fbf9d6a828)

</details>
