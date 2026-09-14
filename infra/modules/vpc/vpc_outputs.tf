output "vpc_id" { value = aws_vpc.practice_vpc.id }
output "public_subnet_2a_id" { value = aws_subnet.public_sn_2a.id }
output "public_subnet_2b_id" { value = aws_subnet.public_sn_2b.id }
output "private_subnet_2a_id" { value = aws_subnet.private_sn_2a.id }
output "private_subnet_2b_id" { value = aws_subnet.private_sn_2b.id }
