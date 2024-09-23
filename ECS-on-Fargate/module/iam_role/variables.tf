variable "name" {}

variable "assume_role_policy" {
  type = string
}

variable "iam_policies" {
  type = list(string)
}
