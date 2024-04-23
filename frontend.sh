#!/bin/bash

source ./common.sh

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "Enabling Nginx"

rm -rf /usr/share/nginx/html/*
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>> $LOGFILE
VALIDATE $? "Downloading Source Code"

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>> $LOGFILE

cp /home/ec2-user/daws-expense-shell-v2/expense.conf /etc/nginx/default.d/expense.conf
VALIDATE $? "Downloading Frontend Configuration"

systemctl restart nginx &>> $LOGFILE
VALIDATE $? "Restarting Nginx"
