#! /bin/bash
    sudo apt-get update -y
    cd /home/ubuntu/transport-api-springboot
    sudo apt-get install openjdk-11-jdk -y
    sudo apt install snapd -y
    sudo snap install gradle --classic
    gradle build
    cd /build/libs/transport-module-1.0.jar
    nohup java -jar /build/libs/transport-module-1.0.jar > /tmp/app.log 2>&1 &
