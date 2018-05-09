#!/bin/bash

# get password without echoing it
echo "(using root user)"
echo -n "mysql password: "
read -s password
echo

mysql -uroot -p"$password"  -e "show databases" | grep -v Database | grep -v mysql | grep -v information_schema | grep -v test | grep -v OLD | gawk '{print "drop database " $1 ";select sleep(0.1);"}' | mysql -uroot -p"$password"
