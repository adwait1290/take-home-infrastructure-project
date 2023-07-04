[
  {
    "name": "${ecs_service_container_name}",
    "image": "${image}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "protocol": "tcp"
      }
    ],
    "healthCheck": {
            "command" : ["CMD-SHELL","echo hello || exit 1"],
            "interval" : 30,
            "timeout" : 5,
            "retries" : 3,
            "startPeriod" : 30
          },
    "environment": [
      {"name": "DB_HOST", "value": "${db_host}"},
      {"name": "DB_NAME", "value": "${db_name}"},
      {"name": "DB_PASSWORD", "value": "${db_password}"},
      {"name": "DB_USER", "value": "${db_username}"}
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group" : "${aws_logs_group}",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "wordpress"
      }
    },
    "mountPoints": [
      {
        "readOnly": false,
        "containerPath": "/var/www/html/wordpress/wp-content/themes",
        "sourceVolume": "efs-themes",
        "readOnly" : false
      },
      {
        "readOnly": false,
        "containerPath": "/var/www/html/wordpress/wp-content/plugins",
        "sourceVolume": "efs-plugins",
        "readOnly" : false
      }
    ],
    "essential": true
  }
]