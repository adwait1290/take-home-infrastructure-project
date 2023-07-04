# Produce outputs which can be consumed by other resources

# ARN stands for Amazon Resource Number that uniquely identifies this particular resource
# It is used to specify this exact load balancer in AWS commands & API calls
output "alb_tg_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb_target_group.tg.arn
}

# DNS name of Load Balancer is required for the clients to resolve to correct servers
# Value is used to set up DNS records
output "alb_dns_name" {
 description = "The DNS name of the load balancer"
 value       = aws_lb.main.dns_name
}

# Zone ID for the hosted zone in route 53. It is used for activities like
# creating A alias record which points to the load balancer.
output "alb_zone_id" {
 description = "The Zone ID of the load balancer"
 value       = aws_lb.main.zone_id
}