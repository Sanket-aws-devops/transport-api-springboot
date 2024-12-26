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


#!/bin/bash

# Variables
#!/bin/bash

# Variables
S3_BUCKET="s3://sanket-codebuild-poc/transport"  # S3 bucket where the files are stored
DEST_DIR="/home/ubuntu/transport"               # Local directory to unzip
LATEST_ZIP="$DEST_DIR/latest.zip"              # Local path for the latest zip file

# Step 1: Fetch the latest zip file from S3 based on timestamp in the filename
echo "Fetching the latest transport zip file from S3..."

# List all the zip files in the S3 bucket, sort by date, and get the latest one
LATEST_ZIP_FILE=$(aws s3 ls $S3_BUCKET/ --recursive | grep '.zip' | sort -t- -k2,3 -k4,5 -k6,7 | tail -n 1 | awk '{print $4}')

# If the file exists, download it to a consistent location
if [ -n "$LATEST_ZIP_FILE" ]; then
  echo "Latest zip file found: $LATEST_ZIP_FILE"
  aws s3 cp s3://$LATEST_ZIP_FILE $LATEST_ZIP
else
  echo "No zip file found in $S3_BUCKET!"
  exit 1
fi

# Step 2: Unzip the latest zip file
echo "Unzipping the latest transport package..."
unzip -o $LATEST_ZIP -d $DEST_DIR

# Step 3: Find the .jar file inside the unzipped directory
JAR_FILE=$(find $DEST_DIR -name "*.jar" | head -n 1)  # Assuming there's only one .jar file

# Step 4: Run the .jar file
if [ -f "$JAR_FILE" ]; then
  echo "Running the Spring Boot application..."
  java -jar $JAR_FILE
else
  echo "No .jar file found inside $LATEST_ZIP!"
  exit 1
fi
