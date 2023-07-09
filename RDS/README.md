# RDS-Terraform
[Terraform で RDS 構築して接続確認するまで - Zenn](https://zenn.dev/suganuma/articles/fe14451aeda28f)

## 必要条件
- Terraform v1.4.0

## ディレクトリ構成
```
.
├── README.md
├── main.tf
├── module
│   ├── ec2
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
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

## 接続方法
1. EC2にセッションマネージャーでログイン
2. 下記コマンドを実行後、パスワードを入力しMySQLにログイン
```
mysql -u admin -p -h [RDSのエンドポイント]
```
3. 以下の画像のように表示されれば接続成功
![RDS接続1](https://user-images.githubusercontent.com/57606507/142875634-7ddb9f1d-a3e1-46e2-b707-47fc94af85e2.png)

### 注意点
- パスワードの管理方法  
DBのパスワードはTerraformで管理しない方が望ましいです。  
仮のパスワードでRDSを作成したら手動でDBのパスワードを変更し、SSMパラメータストアやSecrets Managerで管理するのが安全かと思います。

- 利用可能なRDSのEngineとVersion情報を確認する方法
  ```
  aws rds describe-db-engine-versions \
  --query "DBEngineVersions[*].[{FamiryName:DBParameterGroupFamily,Vesion:EngineVersion}]" \
  --out table
  ```

## RDS (Relational Database Service)
AWS クラウドでリレーショナルデータベースを簡単にセットアップし、運用し、拡張することのできるウェブサービス。

使用できるRDBMS
- Amazon Aurora  
Amazonが提供しているリレーショナルデータベース。  
MySQLおよびPostgreSQLと互換性がある、クラウド向けのリレーショナルデータベース。  
標準的なMySQLデータベースと比べて最大で5倍、標準的なPostgreSQLデータベースと比べて最大で3倍高速。  
[Amazon Aurora（高性能マネージドリレーショナルデータベース）\| AWS](https://aws.amazon.com/jp/rds/aurora/?aurora-whats-new.sort-by=item.additionalFields.postDateTime&aurora-whats-new.sort-order=desc)
- MySQL
- MariaDB
- PostgreSQL
- Oracle
- Microsoft SQL Server

#### メリット
- 管理が簡単
- スケーラビリティが高い
- 可用性と耐久性が高い
- セキュア
- 高速
- 安価

<details><summary>参考</summary>

- [Amazon RDS（マネージドリレーショナルデータベース）\| AWS](https://aws.amazon.com/jp/rds/)
- [Amazon RDSってなに？ – Amazon Web Service\(AWS\)導入開発支援](https://www.acrovision.jp/service/aws/?p=316)
- [aws\_db\_instance \| Resources \| hashicorp/aws \| Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance)
- [【RDS構築】terraform AWS環境構築 第5回 \- たけログ](https://takelg.com/terraform-aws-rds/)
- [Terraform Aurora MySQL 編 \| 30歳未経験からのITエンジニア](https://www.se-from30.com/aws/terraform-aurora-mesql/)
- [AWSのEC2とRDSをTerraformで構築する　Terraform３分クッキング \- Qiita](https://qiita.com/Brutus/items/cd5aab062ea6cebe436c)
- [Terraformを使用してEC2とRDSで基本的なVPCをセットアップする方法\-DEVコミュニティ](https://dev.to/rolfstreefkerk/how-to-setup-a-basic-vpc-with-ec2-and-rds-using-terraform-3jij)
- [完全初心者向けTerraform入門（AWS）](https://blog.dcs.co.jp/aws/20210401-terraformaws.html)
- [TerraformでAuroraを作成する際にセキュアにパスワードを設定したい](https://zenn.dev/bun913/scraps/8fbc0534fd1a79)
- [amazon web services \- Terraform RDS database credentials \- Stack Overflow](https://stackoverflow.com/questions/65603923/terraform-rds-database-credentials)

</details>
