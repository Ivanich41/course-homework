#!/bin/bash
apt update -y 
# Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова

cp /vagrant/configs/watchlog /etc/default/watchlog
cp /vagrant/configs/watchlog.log /var/log/watchlog.log
cp /vagrant/configs/watchlog.sh /opt/watchlog.sh
chmod +x /opt/watchlog.sh
cp /vagrant/configs/watchlog.service /etc/systemd/system/watchlog.service
cp /vagrant/configs/watchlog.timer /etc/systemd/system/watchlog.timer

systemctl start watchlog.timer
tail -n 1000 /var/log/syslog  | grep word

# Установить spawn-fcgi и создать unit-файл (spawn-fcgi.sevice) с помощью переделки init-скрипта

apt install spawn-fcgi php php-cgi php-cli \
 apache2 libapache2-mod-fcgid -y

mkdir /etc/spawn-fcgi
cp /vagrant/configs/fcgi.conf /etc/spawn-fcgi/fcgi.conf
cp /vagrant/configs/spawn-fcgi.service /etc/systemd/system/spawn-fcgi.service

systemctl start spawn-fcgi
systemctl status spawn-fcgi
systemctl stop apache2
# Доработать unit-файл Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно

apt install nginx -y
rm /etc/nginx/sites-enabled/default
systemctl stop nginx

cp /vagrant/configs/nginx@.service /etc/systemd/system/nginx@.service
cp /vagrant/configs/nginx-first.conf /etc/nginx/nginx-first.conf
cp /vagrant/configs/nginx-second.conf /etc/nginx/nginx-second.conf

systemctl start nginx@first
systemctl start nginx@second

ss -tnulp | grep nginx