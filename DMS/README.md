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

設計・構築関連
- [AWS Database Migration Service とは? \- AWS Database Migration Service](https://docs.aws.amazon.com/ja_jp/dms/latest/userguide/Welcome.html)
- [AWS Database Migration Service のベストプラクティス \- AWS Database Migration Service](https://docs.aws.amazon.com/ja_jp/dms/latest/userguide/CHAP_BestPractices.html)
- [TerraformでDMSレプリケーションインスタンスを自動構築する\(基本編\) \- Qiita](https://qiita.com/neruneruo/items/d327e2e0bf504c4c8c43)
- [チュートリアル: Amazon OpenSearch Service を用いて検索アプリケーションを作成する \- Amazon OpenSearch Service](https://docs.aws.amazon.com/ja_jp/opensearch-service/latest/developerguide/search-example.html)
- [変換ルール式を使用した列の内容の定義 \- AWS Database Migration Service](https://docs.aws.amazon.com/ja_jp/dms/latest/userguide/CHAP_Tasks.CustomizingTasks.TableMapping.SelectionTransformation.Expressions.html#CHAP_Tasks.CustomizingTasks.TableMapping.SelectionTransformation.Expressions-SQLite)

OpenSearch関連
- [Amazon OpenSearch サービスクラスターをターゲットとして使用するAWS Database Migration Service \- AWS Database Migration Service](https://docs.aws.amazon.com/ja_jp/dms/latest/userguide/CHAP_Target.Elasticsearch.html)
- [AWS Database Migration Serviceのターゲットとしての Amazon Elasticsearch Service の導入 \| Amazon Web Services ブログ](https://aws.amazon.com/jp/blogs/news/introducing-amazon-elasticsearch-service-as-a-target-in-aws-database-migration-service/)

運用・保守関連
- [Lambda における問題のトラブルシューティング \- AWS Lambda](https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/lambda-troubleshooting.html)
- [MySQLの約30億レコードをRedshiftにDMSでニアリアルタイム同期した \- クラウドワークス エンジニアブログ](https://engineer.crowdworks.jp/entry/aws-dms)

</details>
