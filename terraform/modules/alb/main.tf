resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups            = [var.security_group_id]
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = var.enable_deletion_protection

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}





resource "aws_lb_target_group" "frontend" {
  name = "${var.project_name}-${var.environment}-frontend"
  port = 3000 //frontend container listens on 3000
  protocol = "HTTP"
  target_type = "ip" //ALB check whether the frontend  is heathy
  vpc_id = var.vpc_id


  health_check { //ALB check whether the frontend is healthy
    enabled = true
    path = "/" //ALB calls ? to test it
    protocol = "HTTP"
    port = "traffic-port" // health check users the target grp port
    healthy_threshold = 2
    unhealthy_threshold = 3
    interval = 30
    timeout = 5
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-frontend"
    Environment =  var.environment
    ManagedBy = "terraform"
    Application = "frontend"
  }
}



resource "aws_lb_target_group" "backend" {
  name        = "${var.project_name}-${var.environment}-backend"
  port        = 5000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    enabled = true
    path = "/health"
    protocol = "HTTP"
    port = "traffic-port"
    healthy_threshold = 2
    unhealthy_threshold = 3
    interval = 30
    timeout = 5

  }


  tags = {
    Name = "${var.project_name}-${var.environment}-backend"
    Environment = var.environment
    Application = "backend"
    ManagedBy = "terraform"
  }
}




resource "aws_lb_listener" "frontend_http" { //creates the ALB listener
  load_balancer_arn = aws_lb.main.arn //attaches it to our ALB
  port = 80 // listern for th http traffic
  protocol = "HTTP" //traffic user http



  default_action { //tells ALB what to do with requests
    type = "forward" //forward the request 
    target_group_arn = aws_lb_target_group.frontend.arn  //send it to the frontend target grp
  }
}



resource "aws_lb_listener_rule" "backend" {
    listener_arn = aws_lb_listener.frontend_http.arn //user our port 80 ALB listerer
    priority = 100 //determines rule evaluation order

    action {
      type = "forward" //send the request to backend
      target_group_arn = aws_lb_target_group.backend.arn // backend target grp
    }
  

  condition {
    path_pattern {
      values = ["/api/*"] //match api requests
    }
  }
}