# Frontend Target Group
resource "aws_lb_target_group" "frontend_target_group" {
    name = "frontend-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc_id
    target_type = "ip"
    health_check {
        path = "/"
        protocol = "HTTP"
        port = "80"
        interval = 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

# Backend Target Group
resource "aws_lb_target_group" "backend_target_group" {
    name = "backend-tg"
    port = 5000
    protocol = "HTTP"
    vpc_id = var.vpc_id
    target_type = "ip"
    health_check {
        path = "/api/users"
        protocol = "HTTP"
        port = "5000"
        interval = 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

# ALB
resource "aws_lb" "alb" {
    name = "fullstack-user-alb"
    internal = false
    load_balancer_type = "application"
    security_groups = var.load_balance_security_group_ids
    subnets = var.load_balance_subnet_ids
    enable_deletion_protection = false
    enable_http2 = true
    idle_timeout = 60
    enable_cross_zone_load_balancing = true
    tags = {
        Name = "Fullstack User ALB"
    }
}

# ALB Listener
resource "aws_lb_listener" "alb_listener" {
    load_balancer_arn = aws_lb.alb.arn
    port = 80
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.frontend_target_group.arn
    }
}

# Custom rule for backend
resource "aws_lb_listener_rule" "backend_listener_rule" {
    listener_arn = "${aws_lb_listener.alb_listener.arn}"
    priority = 10
    action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.backend_target_group.arn}"
    }
    condition {
        path_pattern {
        values = ["/api/*"]
        }
    }
}