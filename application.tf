resource "aws_ecs_task_definition" "test-app" {
  family                   = "test-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512

  container_definitions = <<DEFINITION
[
  {
    "name": "test-app",
    "image": "nginx:1.13.9-alpine",
    "cpu": 256,
    "memory": 512,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
DEFINITION
}

resource "aws_security_group" "test_app" {
  name        = "tf-ecs-tasks"
  description = "allow inbound access from the ALB only"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = ["${aws_security_group.lb.id}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "test-app" {
  name            = "test-app"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.test-app.arn}"
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["${aws_security_group.test_app.id}"]
    subnets         = ["${module.vpc.private_subnets}"]
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.app.id}"
    container_name   = "test-app"
    container_port   = 80
  }

  depends_on = [
    "aws_alb_listener.front_end",
  ]
}
