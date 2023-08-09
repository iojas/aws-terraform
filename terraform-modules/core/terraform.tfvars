clustername = "ojas-atlan"

#aws ec2 describe-instance-types --filters "Name=processor-info.supported-architecture,Values=x86_64" "Name=vcpu-info.default-vcpus,Values=8" "Name=memory-info.size-in-mib, Values=32768" --query "InstanceTypes[*].InstanceType" > useful-ec2
spot_instance_types = ["t2.2xlarge", "d3en.2xlarge", "trn1.2xlarge", "g4ad.2xlarge", "m5dn.2xlarge", "m6a.2xlarge", "m7i.2xlarge", "m5ad.2xlarge", "m6idn.2xlarge", "m4.2xlarge", "m5d.2xlarge", "m5zn.2xlarge", "m6in.2xlarge", "m5a.2xlarge", "m7i-flex.2xlarge", "t3a.2xlarge", "m6i.2xlarge", "g5.2xlarge", "m6id.2xlarge", "h1.2xlarge", "m5.2xlarge", "m5n.2xlarge", "g4dn.2xlarge"]

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