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




# Define the S3 bucket and folder
S3_BUCKET="s3://sanket-codebuild-poc/transport"
DEST_DIR="/home/ubuntu/transport"

# Ensure the transport directory exists
echo "Ensuring $DEST_DIR directory exists..."
mkdir -p $DEST_DIR

# Fetch the latest transport zip file from S3
echo "Fetching the latest transport zip file from S3..."
LATEST_ZIP_FILE=$(aws s3 ls $S3_BUCKET/ --recursive | grep '.zip' | sort -t- -k2,3 -k4,5 -k6,7 | tail -n 1 | awk '{print $4}')
echo "Latest zip file found: $LATEST_ZIP_FILE"

# If the file exists, download it to a consistent location
if [ -n "$LATEST_ZIP_FILE" ]; then
    echo "Copying file from S3: s3://$LATEST_ZIP_FILE to $DEST_DIR/latest.zip"
    aws s3 cp s3://$LATEST_ZIP_FILE $DEST_DIR/latest.zip
else
    echo "No zip file found in S3!"
    exit 1
fi

# Check if the .zip file has been downloaded
if [ -f "$DEST_DIR/latest.zip" ]; then
    echo "File downloaded successfully."
else
    echo "File download failed!"
    exit 1
fi

# Unzip the latest transport package
echo "Unzipping the latest transport package..."
unzip -o $DEST_DIR/latest.zip -d $DEST_DIR/

# Check for the .jar file in the directory
JAR_FILE=$(find $DEST_DIR/ -name "*.jar" -type f -print -quit)
if [ -n "$JAR_FILE" ]; then
    echo "Found JAR file: $JAR_FILE"
else
    echo "No .jar file found in $DEST_DIR!"
    exit 1
fi

# Run the Spring Boot application in the background
echo "Running the Spring Boot application..."
nohup java -jar $JAR_FILE > $DEST_DIR/app.log 2>&1 &

echo "Spring Boot application started in the background."

