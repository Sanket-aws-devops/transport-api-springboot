##! /bin/bash
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





#!/bin/bash

# Environment variables - modify these as needed
APP_NAME=" transport-api"
S3_BUCKET="sanket-codebuild-poc"
DEPLOY_DIR="/home/ubuntu/transport/"
JAR_NAME="transport-module-1.0.jar"
LOG_FILE="/var/log/${APP_NAME}.log"
S3_FOLDER="transport"

# Create application directory if it doesn't exist
mkdir -p ${DEPLOY_DIR}
cd ${DEPLOY_DIR}

# Stop the existing application if it's running
if pgrep -f ${JAR_NAME} > /dev/null; then
    echo "Stopping existing application..."
    pkill -f ${JAR_NAME}
    sleep 10
fi

# Clean up old deployment
rm -rf ${DEPLOY_DIR}/*

# Get the latest deployment package from S3
# Note: AWS CodeDeploy will handle the S3 download, so we just need to handle the extracted files
echo "Setting up new deployment..."

# Ensure correct permissions
chmod +x ${DEPLOY_DIR}/${JAR_NAME}

# Start the application
echo "Starting application..."
nohup java -jar ${DEPLOY_DIR}/${JAR_NAME} > ${LOG_FILE} 2>&1 &

# Check if application started successfully
sleep 10
if pgrep -f ${JAR_NAME} > /dev/null; then
    echo "Application started successfully"
    exit 0
else
    echo "Failed to start application"
    exit 1
fi
