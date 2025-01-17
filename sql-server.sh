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
echo "Script is running at: $Timestamp" &>>$Log_file_name

dnf install mysql-server -y &>>$Log_file_name
Validate $? "Installing Mysql" 

systemctl enable mysqld &>>$Log_file_name
Validate $? "enabling Mysql"

systemctl start mysqld &>>$Log_file_name
Validate $? "Starting Mysql"

systemctl status mysqld &>>$Log_file_name
Validate $? "Status Mysql"



mysql -h mysql.daws30.online -u root -pExpenseApp@1 -e 'show databases;' &>>$Log_file_name


if [ $? -ne 0 ]; then 
    echo "Mysql root user setup was not successfull">>$Log_file_name
    mysql_secure_installation --set-root-pass ExpenseApp@1
    Validate $? "Mysql root user setup was ...."
else
    echo "MySQL Root password already setup.....$Y Skipping $Y"
fi