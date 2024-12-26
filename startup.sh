#!/bin/bash

# Navigate to the transport directory
cd /home/ubuntu/transport/

# Fetch the most recent .zip file from S3
echo "Fetching the latest .zip file from S3..."
LATEST_ZIP_FILE=$(aws s3 ls s3://sanket-codebuild-poc/transport/ --recursive | grep '.zip' | sort -t- -k2,3 -k4,5 -k6,7 | tail -n 1 | awk '{print $4}')

# Check if the .zip file exists in the bucket
if [ -z "$LATEST_ZIP_FILE" ]; then
    echo "No .zip file found in the S3 bucket!"
    exit 1
fi

echo "Latest zip file found: $LATEST_ZIP_FILE"

# Download the latest .zip file from S3
aws s3 cp s3://sanket-codebuild-poc/transport/$LATEST_ZIP_FILE /home/ubuntu/transport/

# Unzip the downloaded .zip file
echo "Unzipping the downloaded file..."
unzip /home/ubuntu/transport/$LATEST_ZIP_FILE -d /home/ubuntu/transport/

# Find the .jar file within the unzipped content (assumes it's the only .jar file)
JAR_FILE=$(find /home/ubuntu/transport/ -name "*.jar" -type f | head -n 1)

# Check if the .jar file was found
if [ -z "$JAR_FILE" ]; then
    echo "No .jar file found in /home/ubuntu/transport!"
    exit 1
fi

echo "Found JAR file: $JAR_FILE"

# Make the .jar file executable
sudo chmod +x $JAR_FILE

# Run the Spring Boot application in the background
echo "Running the Spring Boot application..."
nohup java -jar $JAR_FILE > /home/ubuntu/transport/app.log 2>&1 &

echo "Spring Boot application started in the background."


#=====================================================================
    #sudo apt-get update -y
    #c#d /home/ubuntu/transport-api-springboot
    #sudo apt-get install openjdk-11-jdk -y
    #sudo apt install snapd -y
    #sudo snap install gradle --classic
    #gradle build
    #cd /build/libs/transport-module-1.0.jar
    #nohup java -jar /build/libs/transport-module-1.0.jar > /tmp/app.log 2>&1 &
#cd /home/ubuntu/transport/
#aws s3 cp s3://sanket-codebuild-poc/transport/.zip /home/ubuntu/transport/
#unzip 
#sudo chmod +x transport-module-1.0.jar
#nohup java -jar transport-module-1.0.jar > app.log 2>&1 &
