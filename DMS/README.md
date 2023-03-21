# DMS-Terraform

## 必要条件
- Terraform v1.4.0

## ディレクトリ構成
```
.
├── README.md
├── main.tf
├── module
│   └── dms
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

- [Amazon OpenSearch サービスクラスターをターゲットとして使用するAWS Database Migration Service \- AWS Database Migration Service](https://docs.aws.amazon.com/ja_jp/dms/latest/userguide/CHAP_Target.Elasticsearch.html)
- [AWS Database Migration Serviceのターゲットとしての Amazon Elasticsearch Service の導入 \| Amazon Web Services ブログ](https://aws.amazon.com/jp/blogs/news/introducing-amazon-elasticsearch-service-as-a-target-in-aws-database-migration-service/)
- [Lambda 実行ロール \- AWS Lambda](https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/lambda-intro-execution-role.html)
- [TerraformでDMSレプリケーションインスタンスを自動構築する\(基本編\) \- Qiita](https://qiita.com/neruneruo/items/d327e2e0bf504c4c8c43)
- [チュートリアル: Amazon OpenSearch Service を用いて検索アプリケーションを作成する \- Amazon OpenSearch Service](https://docs.aws.amazon.com/ja_jp/opensearch-service/latest/developerguide/search-example.html)

</details>
