#!/bin/bash

# Getting User ID using id command
# User ID of super user is 0
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

# Function to check if package is installed correctly, else quit
# Because this can be re-used for other packages & commands, it is made to a function
VALIDATE(){
    if [ $? -ne 0 ]
    then
        echo -e "$2...$R FAILED $W"
    else
        echo -e "$2...$G SUCCESS $W"
    fi
}

# Check if the user is root user or not
if [ $USERID -ne 0 ]
then
    echo "Please run this script as super user"
    exit 1
fi

# Check if the package is already installed
dnf list installed mysql-server &>> $LOGFILE

if [ $? -eq 0 ]
then
    echo -e "MySQL Server package is already installed...$Y SKIPPED $W"
else
    dnf install mysql-server -y &>> $LOGFILE
    # Validate if the package is correctly installed
    VALIDATE $? "Installing MySQL Server"
fi

systemctl enable mysqld &>> $LOGFILE
VALIDATE $? "Enabling MySQL Server"

systemctl start mysqld &>> $LOGFILE
VALIDATE $? "Starting MySQL Server"

# Checking if the password is already set
mysql -h db.harshadevops.site -uroot -p${mysql_root_password} -e "show databases;" &>> $LOGFILE

if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>> $LOGFILE
    VALIDATE $? "Root Password Setup"
else
    echo -e "MySQL Server password already setup...$Y SKIPPED $W"
fi