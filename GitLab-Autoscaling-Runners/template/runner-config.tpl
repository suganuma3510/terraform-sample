concurrent = ${runners_concurrent}
check_interval = 0

[[runners]]
  name = "${runners_name}"
  url = "${gitlab_url}"
  token = "${runners_token}"
  executor = "docker+machine"
  limit = ${runners_limit}
  [runners.docker]
    image = "docker:latest"
    privileged = true
    disable_cache = true
  [runners.cache]
    Type = "s3"
    Path = "${cache_path}"
    Shared = true
    [runners.cache.s3]
      ServerAddress = "s3.amazonaws.com"
      AccessKey = "${s3_access_key}"
      SecretKey = "${s3_secret_key}"
      BucketName = "${bucket_name}"
      BucketLocation = "${aws_region}"
  [runners.machine]
    IdleCount = 0
    IdleTime = 1800
    MaxBuilds = 100
    MachineDriver = "amazonec2"
    MachineName = "${runners_name}-%s"
    MachineOptions = [
      "amazonec2-access-key=${ci_access_key}",
      "amazonec2-secret-key=${ci_secret_key}",
      "amazonec2-region=${aws_region}",
      "amazonec2-zone=${runners_aws_zone}",
      "amazonec2-vpc-id=${runners_vpc_id}",
      "amazonec2-subnet-id=${runners_subnet_id}",
      "amazonec2-security-group=${runners_security_group_name}",
      "amazonec2-use-private-address=true",
      "amazonec2-instance-type=${runners_instance_type}",
      "amazonec2-ami=${runners_ami}",
      "amazonec2-request-spot-instance=${runners_request_spot_instance}",
      "amazonec2-spot-price=${runners_spot_price_bid}",
      "amazonec2-tags=gitlab-runner-autoscale"
    ]
    [[runners.machine.autoscaling]]
      Periods = ["* * 9-19 * * mon-fri *"]
      IdleCount = ${runners_idle_count}
      IdleTime = ${runners_idle_time}
      Timezone = "Asia/Tokyo"
    [[runners.machine.autoscaling]]
      Periods = ["* * * * * sat,sun *"]
      IdleCount = 0
      IdleTime = 60
      Timezone = "Asia/Tokyo"