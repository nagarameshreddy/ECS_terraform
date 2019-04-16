/*
variable "aws_access_key" {
  type        = "string"
  description = "AWS Access Key"
  default     = ""
}
variable "aws_secret_key" {
  type        = "string"
  description = "AWS Secret Access Key"
  default     = ""
}
*/

variable "region" {
  type        = "string"
  description = "AWS Region"
  default     = "us-east-1"
}