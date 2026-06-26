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

dnf install python3 gcc python3-devel -y  &>>$LOG_FILE
VALIDATE $? "Installing Python"

id roboshop &>>$LOG_FILE


if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading payment code"

cd /app
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/payment.zip &>>$LOG_FILE 
VALIDATE $? "Uzip payment code"

cd /app 
pip3 install -r requirements.txt &>>$LOG_FILE 
VALIDATE $? "Installing Dependencies"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "Created systemctl service"

systemctl daemon-reload
systemctl enable payment  &>>$LOG_FILE 
systemctl start payment
VALIDATE $? "Enableed and started payment"
