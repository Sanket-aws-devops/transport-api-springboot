#! /bin/bash
    #sudo apt-get update -y
    #c#d /home/ubuntu/transport-api-springboot
    #sudo apt-get install openjdk-11-jdk -y
    #sudo apt install snapd -y
    #sudo snap install gradle --classic
    #gradle build
    #cd /build/libs/transport-module-1.0.jar
    #nohup java -jar /build/libs/transport-module-1.0.jar > /tmp/app.log 2>&1 &
#cd /home/ubuntu
#sudo chmod +x transport-module-1.0.jar
#nohup java -jar transport-module-1.0.jar > app.log 2>&1 &





# Redirect output to a log file
exec > /var/log/startup.log 2>&1

echo "Starting startup.sh"

# Ensure the transport directory exists
echo "Ensuring /home/ubuntu/transport directory exists..."
mkdir -p /home/ubuntu/transport

# Install AWS CLI if not already installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Installing..."
    apt-get update -y && apt-get install -y awscli  # For Ubuntu/Debian
    # yum install -y aws-cli  # Uncomment for Amazon Linux
else
    echo "AWS CLI is already installed."
fi

# Fetch the latest transport zip file from S3
echo "Fetching the latest transport zip file from S3..."
BUCKET_NAME="sanket-codebuild-poc"  # Replace with your actual bucket name
LATEST_FILE=$(aws s3 ls s3://$BUCKET_NAME/transport/ | sort | tail -n 1 | awk '{print $4}')

if [ -z "$LATEST_FILE" ]; then
    echo "No files found in S3 bucket."
    exit 1
fi

echo "Latest zip file found: $LATEST_FILE"

# Copying file from S3 to local directory
echo "Copying file from S3: s3://$BUCKET_NAME/$LATEST_FILE to /home/ubuntu/transport/latest.zip"
aws s3 cp s3://$BUCKET_NAME/$LATEST_FILE /home/ubuntu/transport/latest.zip

if [ $? -ne 0 ]; then
    echo "File download failed!"
    exit 1
fi

# Unzipping the latest transport package
echo "Unzipping the latest transport package..."
unzip /home/ubuntu/transport/latest.zip -d /home/ubuntu/transport/

if [ $? -ne 0 ]; then
    echo "Unzipping failed!"
    exit 1
fi

# Check for .jar files in the transport directory
if ls /home/ubuntu/transport/*.jar 1> /dev/null 2>&1; then
    echo ".jar files found in /home/ubuntu/transport."
else
    echo "No .jar file found in /home/ubuntu/transport!"
fi

echo "Startup script completed."
