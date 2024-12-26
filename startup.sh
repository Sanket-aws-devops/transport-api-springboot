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




# Variables

#!/bin/bash

# Define the S3 bucket
S3_BUCKET="s3://sanket-codebuild-poc/transport"

# Ensure the transport directory exists
echo "Ensuring /home/ubuntu/transport directory exists..."
mkdir -p /home/ubuntu/transport

# Fetch the latest transport zip file from S3
echo "Fetching the latest transport zip file from S3..."
LATEST_ZIP_FILE=$(aws s3 ls $S3_BUCKET/ --recursive | grep '.zip' | sort -t- -k2,3 -k4,5 -k6,7 | tail -n 1 | awk '{print $4}')
echo "Latest zip file found: $LATEST_ZIP_FILE"

# If the file exists, download it to a consistent location
if [ -n "$LATEST_ZIP_FILE" ]; then
    echo "Copying file from S3: s3://$LATEST_ZIP_FILE to /home/ubuntu/transport/latest.zip"
    sudo aws s3 cp s3://$LATEST_ZIP_FILE /home/ubuntu/transport/latest.zip
else
    echo "No zip file found in S3!"
    exit 1
fi

# Unzip the latest transport package
echo "Unzipping the latest transport package..."
sudo unzip /home/ubuntu/transport/latest.zip -d /home/ubuntu/transport/

# Check for the .jar file in the directory
JAR_FILE=$(find /home/ubuntu/transport/ -name "*.jar" -type f)
if [ -n "$JAR_FILE" ]; then
    echo "Found JAR file: $JAR_FILE"
else
    echo "No .jar file found in /home/ubuntu/transport!"
    exit 1
fi

# Run the Spring Boot application in the background
echo "Running the Spring Boot application..."
nohup java -jar $JAR_FILE > /home/ubuntu/transport/app.log 2>&1 &

echo "Spring Boot application started in the background."

