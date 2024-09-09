# terraform-sample

## 必要条件
- [Terraform](https://www.terraform.io/downloads)
- [AWS CLI](https://aws.amazon.com/cli/)

## セットアップ
1. AWS CLI インストール

```sh
brew install awscli
```

2. AWS CLIの設定

```sh
% aws configure --profile terraform-sample
AWS Access Key ID [None]: xxxxxxxx
AWS Secret Access Key [None]: xxxxxxxxxxxxxxxx
Default region name [None]: ap-northeast-1
Default output format [None]: json
```

3. AWS CLIのプロファイルを変更

```sh
export AWS_PROFILE=terraform-sample
aws configure list
```

4. tfenv インストール

```sh
brew install tfenv
```

5. Terraform インストール

```sh
tfenv list-remote
tfenv install 1.9.5
tfenv use 1.9.5
tfenv list
terraform -v
```

6. Terraform 初期化

```sh
terraform init
```

## Topics

- プロバイダのアップグレード

```sh
terraform init -upgrade
```


- リソースをインポート

1. 下記のTerraformコードを追加

```
import {
  # id はインポート対象のリソース ID
  # インポート可能なリソースと形式については、プロバイダーのドキュメントを確認
  id = “i-abcd1234”

  # to は対象となる Terraform のリソース参照を指定
  to = aws_instance.example
}
```

2. インポート結果をファイルへ出力

```sh
terraform plan -generate-config-out=generated_resources.tf
```

3. 実行内容の確認

```sh
terraform plan
```

4. リソースの作成

```sh
terraform apply
```
