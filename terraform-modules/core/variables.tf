variable "clustername" {
  default     = "ojas-atlan"
  description = "Ojas Atlan audition."
}
variable "spot_instance_types" {
  # Here we are looking for 8 vcpu and 32 GB RAM
  # we will increase more types to make sure VMs are avail.
  default     = ["t2.micro"]
  description = "List of instance types for SPOT instance selection"
}
variable "ondemand_instance_type" {
  default     = "t2.micro"
  description = "On Demand instance type"
}
variable "spot_max_size" {
  default     = 6
  description = "How many SPOT instance can be created max"
}
variable "spot_desired_size" {
  default     = 3
  description = "How many SPOT instance should be running at all times"
}
variable "ondemand_desired_size" {
  default     = 1
  description = "How many OnDemand instances should be running at all times"
}

variable "ondemand_max_size" {
  default     = 6
  description = "How many OnDemand instances should be running at most"
}

variable "spot_min_cpu" {
  default = 8
}

variable "spot_max_cpu" {
  default = 16
}

variable "spot_min_memory" {
  default = 32
}

variable "spot_max_memory" {
  default = 64
}

variable "spot_max_hourly_price" {
  default = 0.32
}

variable "launch_template_image_id" {
  description = "Image ID launch template should use."
}

variable "spot_max_price_percentage_over_lowest_price" {
  description = "maximum % price you are willing to pay over lowest spot instance price"
}