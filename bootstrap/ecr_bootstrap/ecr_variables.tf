variable "ecr_name" {
  type        = string
  description = "ECR repo name for ecs practice project"
  default     = "practice-repo"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-2"

}
