#!/bin/bash
# Установим nginx 
yum -y localinstall /vagrant/packages/*.rpm

# Также скопируем конфинг nginx и запускаем
cp -p /vagrant/nginx.conf /etc/nginx/nginx.conf 
systemctl start nginx

# Cкопируем собранные пакеты в директорию nginx 
mkdir -p /usr/share/nginx/html/repo
cp /vagrant/packages/*.rpm /usr/share/nginx/html/repo/

# Создаем репозиторий 
createrepo /usr/share/nginx/html/repo/
# и добавляем его в систему 
cp -p /vagrant/otus.repo /etc/yum.repos.d/otus.repo

# Проверка 
yum repolist enabled | grep otus
curl http://localhost/repo/

