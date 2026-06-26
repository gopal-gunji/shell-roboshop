#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$(basename "$0" .sh)
LOGS_FILE="$LOGS_FOLDER/${SCRIPT_NAME}.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

SCRIPT_DIR=$(pwd)

if [ $USERID -ne 0 ]; then
    echo -e "${R}Please run this script with root user access${N}" | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE() {
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... ${R}FAILURE${N}" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$2 ... ${G}SUCCESS${N}" | tee -a $LOGS_FILE
    fi
}

dnf module disable nginx -y &>>$LOGS_FILE
dnf module enable nginx:1.24 -y &>>$LOGS_FILE
dnf install nginx -y &>>$LOGS_FILE
VALIDATE $? "Installing Nginx"

# Remove old broken config if exists
rm -f /etc/nginx/default.d/roboshop.conf &>>$LOGS_FILE
VALIDATE $? "Removed old config"

systemctl enable nginx &>>$LOGS_FILE
systemctl start nginx &>>$LOGS_FILE
VALIDATE $? "Enabled and started nginx"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "Removed default content"

curl -L -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloaded frontend"

cd /usr/share/nginx/html
unzip -o /tmp/frontend.zip &>>$LOGS_FILE
VALIDATE $? "Unzipped frontend"

rm -f /etc/nginx/nginx.conf &>>$LOGS_FILE
VALIDATE $? "Removed old nginx config"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOGS_FILE
VALIDATE $? "Copied nginx config"

nginx -t &>>$LOGS_FILE
VALIDATE $? "Nginx config test"

systemctl restart nginx &>>$LOGS_FILE
VALIDATE $? "Restarted nginx"