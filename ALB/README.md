# ALB-Terraform

## 使用技術
- AWS
- Terraform v1.0.11

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
1. ALBのDNSへアクセス
![image](https://user-images.githubusercontent.com/57606507/158185562-76a3e36d-65c8-4861-8694-9bcbeeab760c.png)
2. `ok`が表示されることを確認

### 参考
- [ALB \- Terraformで構築するAWS](https://y-ohgi.com/introduction-terraform/handson/alb/#alb)
- [TerraformでALBを作成する \- Qiita](https://qiita.com/gogo-muscle/items/81d9f73f16f901d95424)
- [【ロードバランサー構築】terraform AWS環境構築 第3回 \- たけログ](https://takelg.com/terraform-aws-loadbalancer-alb/)