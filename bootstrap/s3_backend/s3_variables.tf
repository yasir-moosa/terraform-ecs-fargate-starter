variable "bucket_name" {
  type        = string
  description = "S3 bucket to keep remote statefile"
  default     = "practice-ecs-s3-bucket"
}

variable "region" {
  type        = string
  description = "aws region variable"
  default     = "eu-west-2"

}
