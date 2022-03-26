# ECS-on-Fargate-Terraform

## 使用技術
- AWS
- Terraform v1.0.11

## ディレクトリ構成
```
.
├── README.md
├── main.tf
├── module
│   ├── cloudwatch
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── ecs
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── task
│   │   │   └── nginx_definition.json
│   │   └── variables.tf
│   ├── elb
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── iam
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── network
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
└── terraform.tfvars
```

## 構築方法
1. リソース作成
```
terraform apply
```

2. リソース削除
```
terraform destroy
```

## 接続方法
1. マネジメントコンソールにてロードバランサーのDNS名からコンテナにアクセスする
![image](https://user-images.githubusercontent.com/57606507/159903605-2c3c0957-7cdd-4b61-9f67-9c2cb154df03.png)
2. `Welcome to nginx!`と表示されれば成功
![image](https://user-images.githubusercontent.com/57606507/159902516-7116b75e-076c-4a9b-9fba-d8cdcf978915.png)


### 参考
- [TerraformでECS FargateのApache起動をコード化してみた \| DevelopersIO](https://dev.classmethod.jp/articles/terraform-ecs-fargate-apache-run/)
- [【Terraform】Terraformを使用したECS Webアプリ構築 \- Qiita](https://qiita.com/Shoma0210/items/b998a260c5d18839fb7a#ecs)
- [ECS \- Terraformで構築するAWS](https://y-ohgi.com/introduction-terraform/handson/ecs/)