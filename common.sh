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
CHECKROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "Please run this script as super user"
        exit 1
    fi
}