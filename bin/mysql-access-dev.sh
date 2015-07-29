#!/bin/bash

# get password without echoing it
echo "(using root user)"
echo -n "mysql password: "
read -s password
echo

user="develro"
userpasswd="d3v3lRO"

mysql -uroot -p"$password"  -e "
    CREATE DATABASE IF NOT EXISTS Doba;
    CREATE DATABASE IF NOT EXISTS test_Doba;

    CREATE USER IF NOT EXISTS 'develro'@'localhost' IDENTIFIED BY 'd3v3lRO';

    GRANT ALL PRIVILEGES  ON Doba.*
    TO 'develro'@'localhost' IDENTIFIED BY 'd3v3lRO'
    WITH GRANT OPTION;

    GRANT ALL PRIVILEGES  ON test_Doba.*
    TO 'develro'@'localhost' IDENTIFIED BY 'd3v3lRO'
    WITH GRANT OPTION;
"
