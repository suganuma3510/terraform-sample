variable "name" {}

variable "image_tag_mutability" {
  type = string
}

variable "policy" {
  type = string
  default = jsonencode(
    {
      "rules" : [
        {
          "rulePriority" : 1,
          "description" : "Expire images older than one days",
          "selection" : {
            "tagStatus" : "untagged",
            "countType" : "sinceImagePushed",
            "countUnit" : "days",
            "countNumber" : 1
          },
          "action" : {
            "type" : "expire"
          }
        }
      ]
    }
  )
}
