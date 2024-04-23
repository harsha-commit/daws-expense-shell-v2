#!/bin/bash

# PREREQUISITE: chmod u+x common.sh
source ./common.sh

echo "Enter MySQL DB Password:"
read -s mysql_root_password # ExpenseApp@1

CHECKROOT

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