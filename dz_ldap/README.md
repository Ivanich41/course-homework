# LDAP на базе FreeIPA

##  Цели домашнего задания
Научиться настраивать LDAP-сервер и подключать к нему LDAP-клиентов

## Описание домашнего задания

1) Установить FreeIPA
2) Написать Ansible-playbook для конфигурации клиента

## Выполнение домашнего задания

- После создания Vagrantfile, запустим виртуальные машины командой vagrant up. Будут созданы 3 виртуальных машины с ОС CentOS 8 Stream. Каждая ВМ будет иметь по 2ГБ ОЗУ и по одному ядру CPU. 


### Установка FreeIPA сервера
> Все команды выполняем на сервере  ipa.otus.lan

- Для начала нам необходимо настроить FreeIPA-сервер. Подключимся к нему по SSH с помощью команды: vagrant ssh ipa.otus.lan и перейдём в root-пользователя: sudo -i 
- Начнем настройку FreeIPA-сервера: 
- Установим часовой пояс:
   timedatectl set-timezone Europe/Moscow
- Установим утилиту chrony: yum install -y chrony
- Запустим chrony и добавим его в автозагрузку: systemctl enable chronyd
- Если требуется, поменяем имя нашего сервера: hostnamectl set-hostname <имя сервера>
- Выключим Firewall: systemctl stop firewalld
- Отключаем автозапуск Firewalld: systemctl disable firewalld
- Остановим Selinux: setenforce 0
```
[root@ipa ~]# yum install -y chrony
[root@ipa ~]# timedatectl set-timezone Europe/Moscow
[root@ipa ~]# systemctl enable chronyd
[root@ipa ~]# hostnamectl set-hostname ipa.otus.lan
[root@ipa ~]# systemctl stop firewalld
[root@ipa ~]# systemctl disable firewalld
[root@ipa ~]# setenforce 0
[root@ipa ~]# vi /etc/selinux/config
```
- Поменяем в файле /etc/selinux/config, параметр Selinux на disabled
```
[root@ipa ~]# vi /etc/selinux/config

# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=disabled
# SELINUXTYPE= can take one of these three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected. 
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
```

- Для дальнейшей настройки FreeIPA нам потребуется, чтобы DNS-сервер хранил запись о нашем LDAP-сервере. В рамках данной лабораторной работы мы не будем настраивать отдельный DNS-сервер и просто добавим запись в файл /etc/hosts
```
[root@ipa ~]#  vi /etc/hosts

127.0.0.1   localhost localhost.localdomain 
127.0.1.1 ipa.otus.lan ipa
192.168.57.10 ipa.otus.lan ipa
```

- Установим модуль DL1:
```
[root@ipa ~]# yum install -y @idm:DL1
Last metadata expiration check: 0:04:32 ago on Tue 20 Aug 2024 03:46:28 PM MSK.
Dependencies resolved.
```

- Установим FreeIPA-сервер:
```
[root@ipa ~]# yum install -y ipa-server
Last metadata expiration check: 0:05:12 ago on Tue 20 Aug 2024 03:46:28 PM MSK.
Dependencies resolved.
```

- Запустим скрипт установки: ipa-server-install
Далее, нам потребуется указать параметры нашего LDAP-сервера, после ввода каждого параметра нажимаем Enter, если нас устраивает параметр, указанный в квадратных скобках, то можно сразу нажимать Enter:
```
Do you want to configure integrated DNS (BIND)? [no]: no
Server host name [ipa.otus.lan]: <Нажимаем Enter>
Please confirm the domain name [otus.lan]: <Нажимем Enter>
Please provide a realm name [OTUS.LAN]: <Нажимаем Enter>
Directory Manager password: <Указываем пароль минимум 8 символов>
Password (confirm): <Дублируем указанный пароль>
IPA admin password: <Указываем пароль минимум 8 символов>
Password (confirm): <Дублируем указанный пароль>
NetBIOS domain name [OTUS]: <Нажимаем Enter>
Do you want to configure chrony with NTP server or pool address? [no]: no
The IPA Master Server will be configured with:
Hostname:       ipa.otus.lan
IP address(es): 192.168.57.10
Domain name:    otus.lan
Realm name:     OTUS.LAN

The CA will be configured with:
Subject DN:   CN=Certificate Authority,O=OTUS.LAN
Subject base: O=OTUS.LAN
Chaining:     self-signed
Проверяем параметры, если всё устраивает, то нажимаем yes
Continue to configure the system with these values? [no]: yes
```

- Далее начнется процесс установки. Процесс установки занимает примерно 10-15 минут (иногда время может быть другим). Если мастер успешно выполнит настройку FreeIPA то в конце мы получим сообщение: 
```
...
Be sure to back up the CA certificates stored in /root/cacert.p12
These files are required to create replicas. The password for these
files is the Directory Manager password
The ipa-server-install command was successful
```

- При вводе параметров установки мы вводили 2 пароля: </br>
Directory Manager password — это пароль администратора сервера каталогов, У этого пользователя есть полный доступ к каталогу.</br>
IPA admin password — пароль от пользователя FreeIPA admin</br>

- После успешной установки FreeIPA, проверим, что сервер Kerberos может выдать нам билет:
```
[root@ipa ~]# kinit admin
```

- Password for admin@OTUS.LAN:  #Указываем Directory Manager password


- Запросим список билетов Kerberos
```
[root@ipa ~]# klist
Ticket cache: KCM:0
Default principal: admin@OTUS.LAN

Valid starting       Expires              Service principal
08/20/2024 17:23:46  08/21/2024 17:22:30  krbtgt/OTUS.LAN@OTUS.LAN
```

- Для удаление полученного билета воспользуемся командой: kdestroy

Мы можем зайти в Web-интерфейс нашего FreeIPA-сервера, для этого на нашей хостой машине нужно прописать следующую строку в файле Hosts:
192.168.57.10 ipa.otus.lan

- В Unix-based системах файл хост находится по адресу /etc/hosts

- После добавления DNS-записи откроем c нашей хост-машины веб-страницу ipa.otus.lan
![1](./1.png)

- Откроется окно управления FreeIPA-сервером. В имени пользователя укажем admin, в пароле укажем наш IPA admin password и нажмём войти. 


- Откроется веб-консоль управления FreeIPA. Данные во FreeIPA можно вносить как через веб-консоль, так и средствами командной строки.

- На этом установка и настройка FreeIPA-сервера завершена.

### Ansible playbook для конфигурации клиента

- Настройка клиента похожа на настройку сервера. На хосте также нужно:
- Настроить синхронизацию времени и часовой пояс
- Настроить (или отключить) firewall
- Настроить (или отключить) SElinux
- В файле hosts должна быть указана запись с FreeIPA-сервером и хостом

- Хостов, которые требуется добавить к серверу может быть много, для упрощения нашей работы выполним настройки с помощью Ansible:

- В каталоге с нашей лабораторной работой создадим каталог Ansible: mkdir ansible
- В каталоге ansible создадим файл hosts со следующими параметрами:
```
[clients]
client1.otus.lan ansible_host=192.168.57.11 ansible_user=vagrant ansible_ssh_private_key_file=./.vagrant/machines/client1.otus.lan/virtualbox/private_key
client2.otus.lan ansible_host=192.168.57.12 ansible_user=vagrant ansible_ssh_private_key_file=./.vagrant/machines/client2.otus.lan/virtualbox/private_key
```

- Файл содержит группу clients в которой прописаны 2 хоста: 
```
client1.otus.lan
client2.otus.lan
```

- Также указаны и ip-адреса, имя пользователя от которого будет логин и ssh-ключ.

- Далее создадим файл provision.yml в котором непосредственно будет выполняться настройка клиентов: 
```
- name: Base set up
  hosts: all
  #Выполнять действия от root-пользователя
  become: yes
  tasks:
  #Установка текстового редактора Vim и chrony
  - name: install softs on CentOS
    yum:
      name:
        - vim
        - chrony
      state: present
      update_cache: true
  
  #Отключение firewalld и удаление его из автозагрузки
  - name: disable firewalld
    service:
      name: firewalld
      state: stopped
      enabled: false
  
  #Отключение SElinux из автозагрузки
  #Будет применено после перезагрузки
  - name: disable SElinux
    selinux:
      state: disabled
  
  #Отключение SElinux до перезагрузки
  - name: disable SElinux now
    shell: setenforce 0

  #Установка временной зоны Европа/Москва    
  - name: Set up timezone
    timezone:
      name: "Europe/Moscow"
  
  #Запуск службы Chrony, добавление её в автозагрузку
  - name: enable chrony
    service:
      name: chronyd
      state: restarted
      enabled: true
  
  #Копирование файла /etc/hosts c правами root:root 0644
  - name: change /etc/hosts
    template:
      src: hosts.j2
      dest: /etc/hosts
      owner: root
      group: root
      mode: 0644
  
  #Установка клиента Freeipa
  - name: install module ipa-client
    yum:
      name:
        - freeipa-client
      state: present
      update_cache: true
  
  #Запуск скрипта добавления хоста к серверу
  - name: add host to ipa-server
    shell: echo -e "yes\nyes" | ipa-client-install --mkhomedir --domain=OTUS.LAN --server=ipa.otus.lan --no-ntp -p admin -w otus2022
```

- Template файла /etc/hosts выглядит следующим образом:
```
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.57.10 ipa.otus.lan ipa
```

- Почти все модули нам уже знакомы, давайте подробнее остановимся на последней команде echo -e "yes\nyes" | ipa-client-install --mkhomedir --domain=OTUS.LAN --server=ipa.otus.lan --no-ntp -p admin -w otus2022

- При добавлении хоста к домену мы можем просто ввести команду ipa-client-install и следовать мастеру подключения к FreeIPA-серверу (как было в первом пункте).

- Однако команда позволяет нам сразу задать требуемые нам параметры:
```
--domain — имя домена
--server — имя FreeIPA-сервера
--no-ntp — не настраивать дополнительно ntp (мы уже настроили chrony)
-p — имя админа домена
-w — пароль администратора домена (IPA password)
--mkhomedir — создать директории пользователей при их первом логине
```
Если мы сразу укажем все параметры, то можем добавить эту команду в Ansible и автоматизировать процесс добавления хостов в домен. 

Альтернативным вариантом мы можем найти на GitHub отдельные модули по подключениею хостов к FreeIPA-сервер. 

После подключения хостов к FreeIPA-сервер нужно проверить, что мы можем получить билет от Kerberos сервера: kinit admin
Если подключение выполнено правильно, то мы сможем получить билет, после ввода пароля. 


-Давайте проверим работу LDAP, для этого на сервере FreeIPA создадим пользователя и попробуем залогиниться к клиенту:
Авторизируемся на сервере: 
```
[root@ipa ~]# kinit admin
```

- Создадим пользователя otus-user
```
[root@ipa ~]# klist
klist: Credentials cache 'KCM:0' not found
[root@ipa ~]# kinit admin
Password for admin@OTUS.LAN: 
[root@ipa ~]# ipa user-add otus-user-client1 --first=Otus --last=User --password
Password: 
Enter Password again to verify: 
------------------------------
Added user "otus-user-client1"
------------------------------
  User login: otus-user-client1
  First name: Otus
  Last name: User
  Full name: Otus User
  Display name: Otus User
  Initials: OU
  Home directory: /home/otus-user-client1
  GECOS: Otus User
  Login shell: /bin/sh
  Principal name: otus-user-client1@OTUS.LAN
  Principal alias: otus-user-client1@OTUS.LAN
  User password expiration: 20240820135654Z
  Email address: otus-user-client1@otus.lan
  UID: 1178800004
  GID: 1178800004
  Password: True
  Member of groups: ipausers
  Kerberos keys available: True
```

- Создал 2х пользователейЮ, под каждый клиент
- На хосте client1 или client2 выполним команду kinit otus-user
```
[vagrant@client1 ~]$ kinit otus-user-client1
Password for otus-user-client1@OTUS.LAN: 
Password expired.  You must change it now.
Enter new password: 
Enter it again: 
[root@client1 ~]#
...
[root@client2 ~]# kinit otus-user-client2
Password for otus-user-client2@OTUS.LAN: 
Password expired.  You must change it now.
Enter new password: 
Enter it again: 
[root@client2 ~]# 
```
- Система запросит у нас пароль и попросит ввести новый пароль. 

- На этом процесс добавления хостов к FreeIPA-серверу завершен.

