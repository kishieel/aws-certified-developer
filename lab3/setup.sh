#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
echo '<center><h1>This instance is in the: AZ</h1></center>' > /var/www/html/index.txt
sed "s/AZ/$AZ/" /var/www/html/index.txt > /var/www/html/index.html
