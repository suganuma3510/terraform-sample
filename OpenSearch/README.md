# OpenSearch-Terraform

## 必要条件
- Terraform v1.4.0

## ディレクトリ構成
```
.
├── README.md
├── main.tf
├── module
│   └── opensearch
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

## OpenSearch クエリ例
```
GET employee/_search
{
  "query": {
    "match_all": {}
  }
}
```

<details><summary>参考</summary>

- [Amazon OpenSearch Service とは？ \- Amazon OpenSearch Service](https://docs.aws.amazon.com/ja_jp/opensearch-service/latest/developerguide/what-is.html)
- [Amazon OpenSearch Service のきめ細かなアクセスコントロール \- Amazon OpenSearch Service](https://docs.aws.amazon.com/ja_jp/opensearch-service/latest/developerguide/fgac.html)
- [チュートリアル: Amazon OpenSearch Service を用いて検索アプリケーションを作成する \- Amazon OpenSearch Service](https://docs.aws.amazon.com/ja_jp/opensearch-service/latest/developerguide/search-example.html)
- [NGINX プロキシを使用して Amazon OpenSearch Dashboards にアクセスする \| AWS re:Post](https://repost.aws/ja/knowledge-center/opensearch-outside-vpc-nginx)

</details>
