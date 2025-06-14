# How to reference in other places

variable "MONGODB_URI" {
  description = "MongoDB Atlas connection URI"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be created"
  type        = string
}

variable "name_prefix" {
  description = "ecs for grp4"
  type        = string
}

variable "alb_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
  
}

variable "mongodb_name" {
  description = "Name of the MongoDB secret in Secrets Manager"
  type        = string
  default     = "test/mongodb_uri"
  
}
variable "mongodb_prefix" {
  description = "Prefix for MongoDB secret name"
  type        = string
  default     = "OMruUN"
  
}

variable "secretsmanager_arn" {
  description = "ARN of the Secrets Manager secret for MongoDB URI"
  type        = string
  default     = "arn:aws:secretsmanager:us-east-1:255945442255:secret:test/mongodb_uri-OMruUN"
}