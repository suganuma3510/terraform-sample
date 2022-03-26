#--------------------------------------------------------------
#  CloudWatch log gloup
#--------------------------------------------------------------

resource "aws_cloudwatch_log_group" "cloudwatch" {
  name = "/ecs/${var.name}-service"

  tags = {
    Application = "${var.name}-ecs-logs"
  }
}