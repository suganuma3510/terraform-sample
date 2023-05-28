# ECS-on-Fargate-Terraform

## 必要条件
- Terraform v1.4.0

## ディレクトリ構成
```
.
├── README.md
├── main.tf
├── module
│   ├── ecs_task
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── iam
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── template
│   └── nginx_definition.json
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
ECS
- [TerraformでECS FargateのApache起動をコード化してみた \| DevelopersIO](https://dev.classmethod.jp/articles/terraform-ecs-fargate-apache-run/)
- [【Terraform】Terraformを使用したECS Webアプリ構築 \- Qiita](https://qiita.com/Shoma0210/items/b998a260c5d18839fb7a#ecs)
- [ECS \- Terraformで構築するAWS](https://y-ohgi.com/introduction-terraform/handson/ecs/)

CloudWatch Agent
- [Amazon ECS での CloudWatch エージェントと X\-Ray デーモンのデプロイ \- Amazon CloudWatch](https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/deploy_servicelens_CloudWatch_agent_deploy_ECS.html)
- [【AWS ECS 小ネタ】CloudWatch Agentを使用してクラスター名、タスクIDのディメンション付きでディスク使用率のメトリクスを収集する \- ENECHANGE Developer Blog](https://tech.enechange.co.jp/entry/2022/10/04/101051)
- [Amazon CloudWatchエージェントのセットアップ方法（Linux） \| Tech ブログ \| JIG\-SAW OPS](https://ops.jig-saw.com/tech-cate/amazon-cloudwatch-setup)