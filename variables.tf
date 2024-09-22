variable "region" {
  type    = string
  default = "ap-southeast-1"
}

variable "vpc_az" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "min_size" {
  type = string
}

variable "max_size" {
  type = string
}

variable "desired_capacity" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "image_id" {
  type = string
}

variable "key_name" {
  type = string
}