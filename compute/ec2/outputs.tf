output "on_demand_instance_id" {
  value = aws_instance.on_demand.id
}

output "on_demand_instance_public_ip" {
  value = aws_instance.on_demand.public_ip
}

output "spot_instance_id" {
  value = aws_instance.spot.id
}

output "spot_instance_public_ip" {
  value = aws_instance.spot.public_ip
}
