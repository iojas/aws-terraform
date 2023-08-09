resource "aws_iam_role" "EKSClusterRole" {
  name = "EKSClusterRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "NodeGroupRole" {
  name = "EKSNodeGroupRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.EKSClusterRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.EKSClusterRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicySpot" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.NodeGroupRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.NodeGroupRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.NodeGroupRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.NodeGroupRole.name
}

resource "aws_eks_cluster" "eks-cluster" {
  name     = var.clustername
  role_arn = aws_iam_role.EKSClusterRole.arn
  version  = "1.26"

  vpc_config {
    subnet_ids          = [
      aws_subnet.public-us-east-1b.id,
      aws_subnet.private-us-east-1a.id
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]
}

resource "aws_launch_template" "spot_launch_template" {
  name = "spot-launch-instance"
  image_id = var.launch_template_image_id
  user_data = base64encode(<<-EOF
    MIME-Version: 1.0
    Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="
    --==MYBOUNDARY==
    Content-Type: text/x-shellscript; charset="us-ascii"
    #!/bin/bash
    /etc/eks/bootstrap.sh ojas-atlan
    --==MYBOUNDARY==--\
      EOF
  )
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 20
      volume_type = "gp2"
    }
  }

  instance_requirements {
    allowed_instance_types = var.spot_instance_types
    spot_max_price_percentage_over_lowest_price = var.spot_max_price_percentage_over_lowest_price

    vcpu_count {
      min = var.spot_min_cpu
      max = var.spot_max_cpu
    }
    memory_mib {
      min = var.spot_min_memory
      max = var.spot_max_memory
    }
  }
}

resource "aws_eks_node_group" "spot_node_group" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "spot-ng"
  node_role_arn   = aws_iam_role.NodeGroupRole.arn
  subnet_ids      = [
    aws_subnet.private-us-east-1a.id
  ]
  capacity_type = "SPOT"
  instance_types = var.spot_instance_types

  launch_template {
    name = aws_launch_template.spot_launch_template.name
    version = aws_launch_template.spot_launch_template.latest_version
  }

  update_config {
    max_unavailable = 1
  }

  taint {
    effect = "NO_SCHEDULE"
    value = "spot"
    key    = "atlan.instance.type"
  }

  labels = {
    "atlan.instance.type" = "spot"
  }

  scaling_config {
    desired_size = var.spot_desired_size
    max_size     = var.spot_max_size
    min_size     = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
  ]

  tags = merge(
    local.common_tags,
    {"type": "public"},
  )
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "on_demand" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "on-demand-ng"
  node_role_arn   = aws_iam_role.NodeGroupRole.arn
  subnet_ids      = [
    aws_subnet.public-us-east-1b.id
  ]
  capacity_type = "ON_DEMAND"
  instance_types = [var.ondemand_instance_type]

  scaling_config {
    desired_size = var.ondemand_desired_size
    max_size     = var.ondemand_max_size
    min_size     = 1
  }

  taint {
    effect = "NO_SCHEDULE"
    value = "on_demand"
    key    = "atlan.instance.type"
  }

  labels = {
    "atlan.instance.type" = "on_demand"
  }

  update_config {
    max_unavailable = 1
  }

  tags = merge(
    local.common_tags,
    {"type": "public"},
  )

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
  ]
}