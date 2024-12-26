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


# Enable error handling and debugging
set -e
set -x

# Environment variables - modify these as needed
APP_NAME=" transport-api"
S3_BUCKET="sanket-codebuild-poc"
DEPLOY_DIR="/home/ubuntu/transport/"
JAR_NAME="transport-module-1.0.jar"
LOG_FILE="/var/log/${APP_NAME}.log"
S3_FOLDER="transport"

# Function for logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/deploy.log
}

# Check if required commands are available
command -v aws >/dev/null 2>&1 || { log "AWS CLI is required but not installed. Aborting."; exit 1; }
command -v unzip >/dev/null 2>&1 || { log "unzip is required but not installed. Aborting."; exit 1; }
command -v java >/dev/null 2>&1 || { log "Java is required but not installed. Aborting."; exit 1; }

# Create application directory if it doesn't exist
log "Creating deployment directory..."
mkdir -p ${DEPLOY_DIR} || { log "Failed to create directory ${DEPLOY_DIR}"; exit 1; }
cd ${DEPLOY_DIR} || { log "Failed to change to directory ${DEPLOY_DIR}"; exit 1; }

# Stop the existing application if it's running
if pgrep -f ${JAR_NAME}; then
    log "Stopping existing application: ${APP_NAME}"
    pkill -f ${JAR_NAME} || true
    sleep 10
fi

# Clean up old deployment
log "Cleaning up old deployment..."
rm -rf ${DEPLOY_DIR}/* || { log "Failed to clean up old deployment"; exit 1; }

# Install required packages if missing
if ! command -v aws &> /dev/null; then
    log "Installing AWS CLI..."
    apt-get update
    apt-get install -y awscli
fi

if ! command -v unzip &> /dev/null; then
    log "Installing unzip..."
    apt-get update
    apt-get install -y unzip
fi

# Get the latest zip file from S3
log "Finding latest deployment package..."
LATEST_ZIP=$(aws s3api list-objects-v2 \
    --bucket ${S3_BUCKET} \
    --prefix "${S3_FOLDER}/" \
    --query 'sort_by(Contents[?contains(Key, `.zip`)], &LastModified)[-1].Key' \
    --output text) || { log "Failed to list S3 objects"; exit 1; }

if [ -z "${LATEST_ZIP}" ] || [ "${LATEST_ZIP}" = "None" ]; then
    log "No zip file found in S3"
    exit 1
fi

log "Downloading latest package: ${LATEST_ZIP}"
aws s3 cp "s3://${S3_BUCKET}/${LATEST_ZIP}" "${DEPLOY_DIR}/latest.zip" || { log "Failed to download from S3"; exit 1; }

# Unzip the deployment package
log "Extracting package..."
unzip -q "${DEPLOY_DIR}/latest.zip" -d "${DEPLOY_DIR}" || { log "Failed to extract zip file"; exit 1; }
rm "${DEPLOY_DIR}/latest.zip" || { log "Failed to remove zip file"; exit 1; }

# Ensure correct permissions
log "Setting permissions..."
chmod +x "${DEPLOY_DIR}/${JAR_NAME}" || { log "Failed to set execute permission"; exit 1; }
chown -R ubuntu:ubuntu "${DEPLOY_DIR}" || { log "Failed to change ownership"; exit 1; }

# Start the application
log "Starting ${APP_NAME}..."
sudo -u ubuntu bash -c "cd ${DEPLOY_DIR} && nohup java -jar ${JAR_NAME} > ${LOG_FILE} 2>&1 &" || { log "Failed to start application"; exit 1; }

# Check if application started successfully
log "Checking application status..."
sleep 10
if pgrep -f ${JAR_NAME}; then
    log "${APP_NAME} started successfully"
    exit 0
else
    log "Failed to start ${APP_NAME}"
    exit 1
fi
