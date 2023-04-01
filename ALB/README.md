# ALB-Terraform

## 必要条件
- Terraform v1.4.0

## ディレクトリ構成
```
.
├── README.md
├── main.tf
├── module
│   ├── acm
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── elb
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

## 接続方法
1. ALBのDNSへアクセス
![image](https://user-images.githubusercontent.com/57606507/158185562-76a3e36d-65c8-4861-8694-9bcbeeab760c.png)
2. `ok`が表示されることを確認

<details><summary>参考</summary>

- [ALB \- Terraformで構築するAWS](https://y-ohgi.com/introduction-terraform/handson/alb/#alb)
- [TerraformでALBを作成する \- Qiita](https://qiita.com/gogo-muscle/items/81d9f73f16f901d95424)
- [【ロードバランサー構築】terraform AWS環境構築 第3回 \- たけログ](https://takelg.com/terraform-aws-loadbalancer-alb/)
- [TerraformでALBを構築する \| DevelopersIO](https://dev.classmethod.jp/articles/terraform-alb/)
- [Enable access logs for your Application Load Balancer \- Elastic Load Balancing](https://docs.aws.amazon.com/en_us/elasticloadbalancing/latest/application/enable-access-logging.html#attach-bucket-policy)

</details>