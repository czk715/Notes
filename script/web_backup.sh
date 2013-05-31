#!/bin/sh

str=`date +%Y%m%d`

find /var/www/staging/app >> TempList
find /var/www/manage/app >> TempList
find /var/www/staging/html -iname *.html >> TempList
find /var/www/staging/html -iname *.css >> TempList
find /var/www/staging/html -iname *.js >> TempList
find /var/www/staging/html -iname *.csv >> TempList
find /var/www/staging/html -iname *.ini >> TempList

sudo tar -cpzf /home/IMJ/beaunet/backup$str.tar.gz -T TempList
sudo rm -rf TempList

