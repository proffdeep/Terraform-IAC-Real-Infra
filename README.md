1. **AWS Provider Configuration**
   - Configures Terraform to use the AWS provider for resource management in the `us-east-1` region.

2. **VPC Creation**
   - Creates a Virtual Private Cloud (VPC) with the CIDR block `10.0.0.0/16`.

3. **Internet Gateway Creation**
   - Creates an Internet Gateway and associates it with the VPC.

4. **Public Subnet Creation**
   - Creates two public subnets (`10.0.1.0/24` and `10.0.2.0/24`) in different Availability Zones (`us-east-1a` and `us-east-1b`).
   - Enables automatic assignment of public IP addresses to instances launched in these subnets.

5. **Private Route Table Creation**
   - Creates two route tables, one for private and one for public resources.

6. **Private Subnet Creation**
   - Creates two private subnets (`10.0.3.0/24` and `10.0.4.0/24`) in different Availability Zones (`us-east-1a` and `us-east-1b`).

7. **Associates Route Tables with Subnets**
   - Associates the private route table with the private subnets and the public route table with the public subnets.

8. **Sets Up Public Subnet Route**
   - Adds a route in the public route table to route all traffic (`0.0.0.0/0`) through the Internet Gateway.

9. **Security Group Creation**
   - Creates two security groups for instances in private and public subnets.
   - Allows inbound traffic on port 22 (SSH) and allows all outbound traffic.

10. **EC2 Instances in Private Subnets**
    - Launches two EC2 instances in the private subnets with specified AMI, instance type, key pair, and security group.

11. **Bastion Host in Public Subnet**
    - Launches a bastion host (jump server) in the public subnet.

12. **NAT Gateway and Elastic IP**
    - Creates a NAT Gateway and associates it with an Elastic IP in the public subnet.
    - Ensures instances in private subnets can access the internet.
