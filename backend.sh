#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d '.' -f 1)
LOGFILE="/tmp/$SCRIPTNAME-$TIMESTAMP.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[0m"
echo "Enter MySQL DB Password:"
read -s mysql_root_password # ExpenseApp@1

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ...$R FAILED $W"
    else
        echo -e "$2 ...$G SUCCESS $W"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script as super user"
    exit 1
else
    echo "Running this script as super user"
fi

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabling default NodeJS"

dnf module enable nodejs:20 -y &>> $LOGFILE
VALIDATE $? "Enabling NodeJS:20"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing NodeJS:20"

id expense &>> $LOGFILE

if [ $? -ne 0 ]
then
    useradd expense &>> $LOGFILE
    VALIDATE $? "Adding User: expense"
else
    echo -e "User expense is already present...$Y SKIPPED $W"
fi

mkdir -p /app &>> $LOGFILE

curl -o /tmp/backend.zip "https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip" &>> $LOGFILE
VALIDATE $? "Downloading Source Code"

rm -r /app/*
cd /app
unzip /tmp/backend.zip &>> $LOGFILE
VALIDATE $? "Unzipping the file"

npm install &>> $LOGFILE
VALIDATE $? "Installing NodeJS dependencies"

cp /home/ec2-user/daws-expense-shell/backend.service /etc/systemd/system/ &>> $LOGFILE
VALIDATE $? "Copying Backend Configuration"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon Reload"

systemctl start backend &>> $LOGFILE
VALIDATE $? "Starting Backend Service"

systemctl enable backend &>> $LOGFILE
VALIDATE $? "Enabling Backend Service"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "Installing MySQL Client"

# Here backend.sql makes this idempotent
mysql -h db.harshadevops.site -uroot -p${mysql_root_password} < /app/schema/backend.sql &>> $LOGFILE
VALIDATE $? "Loading DB Schema"

systemctl restart backend &>> $LOGFILE
VALIDATE $? "Restarting Backend Service"

