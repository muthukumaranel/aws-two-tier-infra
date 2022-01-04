output "public_subnets" {

  value = aws_subnet.public_subnets.*.id

}

output "private_subnets" {
  value = aws_subnet.private_subnet.*.id
}

output "security_group" {
  value = aws_security_group.my-sg.id
}