clustername = "ojas-atlan"

spot_instance_types = ["m5.2xlarge", "m6i.2xlarge", "m4.2xlarge"]
spot_desired_size   = 3
spot_max_size       = 6
spot_min_cpu = 8
spot_max_cpu = 16
spot_min_memory = 30000
spot_max_memory = 40000

ondemand_instance_type = "t3a.2xlarge"
ondemand_desired_size  = 1
ondemand_max_size      = 4

launch_template_image_id = "ami-00a4cd63f089232e0"
spot_max_price_percentage_over_lowest_price = 10