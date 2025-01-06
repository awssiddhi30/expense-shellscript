#!/bin/bash

R="\[e31m"
G="\[e32m"
Y="\[e33m"
N="\[e0m"

logs_folder="/var/log/expense-logs"
log_file=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
Log_file_name="$Log_folder/$Log_file-$Timestamp.log"

Validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ...$R Failure $N"
        exit 1
    else
        echo -e "$2 ...$G Success $N"
    fi
}

Check_root(){
    if [ UserID -ne 0]; then
        echo -e " $R Error: You should have root access to run this script $N"
        exit 1
    fi
}


dnf module disable nodejs -y &>>$Log_file_name
validate $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>>$Log_file_name
validate $? "Enabling nodejs"

dnf install nodejs -y &>>$Log_file_name
validate  $? "Installing nodejs"

id expense &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
    useradd expense &>>$LOG_FILE_NAME
    VALIDATE $? "Adding expense user"
else
    echo -e "expense user already exists ... $Y SKIPPING $N"
fi

mkdir /app &>>$Log_file_name
validate $? "making directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$Log_file_name
validate $? "downloading application"

cd /app 
rm -rf /app/*

unzip /tmp/backend.zip &>>$Log_file_name
validate $? "unziping code"

npm install &>>$Log_file_name
validate $? "installing dependencies"

cp backend.server/home/ec2-user//etc/systemd/system/backend.service

dnf install mysql -y &>>$Log_file_name
validate $? "installing mysql"

mysql -h mysql.daws30.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$Log_file_name
validate $? "setting transaction and tables"

systemctl daemon-reload &>>$Log_file_name
validate $? "daemon reload"

systemctl start backend &>>$Log_file_name
validate $? "starting backend"

systemctl enable backend &>>$Log_file_name
validate $? "enabling backend"

systemctl restart backend &>>$Log_file_name
validate $? "restarting backend"