#!/bin/bash



USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
M="\e[35m"
C="\e[36m"
W="\e[37m"
N="\e[0m"

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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "copying mongo.repo file"

dnf install mongodb-org -y 
VALIDATE $? "installing mongodb SERVER"

systemctl enable mongod 
VALIDATE $? "enabling mongodb service"

systemctl start mongod 
VALIDATE $? "starting mongodb service"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "updating mongodb config file allowing remote connections"


systemctl restart mongod
VALIDATE $? "restarted mongodb service"