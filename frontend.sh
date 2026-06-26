#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MYSQL_HOST=mysql.durgagopalakrishna.online


if [ $USERID -ne 0 ]; then 
    echo -e "$R please run this script with root user access $N" | tee -a $LOG_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$R $2 ....failed $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$G $2 ....success $N" | tee -a $LOG_FILE
    fi
}


dnf module disable nginx -y &>>$LOG_FILE
dnf module enable nginx:1.24 -y &>>$LOG_FILE
dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing NGINX"

systemctl enable nginx &>>$LOG_FILE
systemctl start nginx 
VALIDATE $? "Enable and Start Nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Remove default or old code"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $? "Download and unzip frontend"

rm -rf /etc/nginx/nginx.conf
VALIDATE $? "Removem old data"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copied our nginx conf file

systemctl restart nginx 
VALIDATE $? "Restart Nginx"
