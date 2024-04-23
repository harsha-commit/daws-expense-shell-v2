#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d '.' -f 1)
LOGFILE="/tmp/$SCRIPTNAME-$TIMESTAMP.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R FAILED $W"
    else
        echo -e "$2...$G SUCCESS $W"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script as super user"
    exit 1
else
    echo "Running this script as super user"
fi

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "Enabling Nginx"

rm -rf /usr/share/nginx/html/*
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>> $LOGFILE
VALIDATE $? "Downloading Source Code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>> $LOGFILE

cp /home/ec2-user/daws-expense-shell/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Downloading Frontend Configuration"

systemctl restart nginx &>> $LOGFILE
VALIDATE $? "Restarting Nginx"
