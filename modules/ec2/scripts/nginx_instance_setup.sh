set -e

# Start and run NGINX server
sudo apt update -y &&
sudo apt upgrade -y && 
sudo apt install -y nginx
echo "VExpenses Challenge" | sudo tee /var/www/html/index.html
sudo systemctl start nginx
echo "Nginx server is running"

# Cloudwatch install and configuration: 
exec > >(tee /var/log/user-data.log|logger -t user-data-extra -s 2>/dev/console) 2>&1
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-c ssm:${ssm_cloudwatch_config} -s

echo "Done initialization of cloudwatch"