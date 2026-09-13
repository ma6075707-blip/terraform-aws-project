output "bastion_public_ip" {
  value = module.bastion.public_ip
}

output "bastion_private_ip" {
  value = module.bastion.private_ip
}

output "private_ec2_ip" {
  value = module.private_ec2.private_ip
}

output "peering_id" {
  value = module.peering.peering_connection_id
}