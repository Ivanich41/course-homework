# DNS

## Цель домашнего задания
- Создать домашнюю сетевую лабораторию. Изучить основы DNS, научиться работать с технологией Split-DNS в Linux-based системах

### Описание домашнего задания

1. взять стенд https://github.com/erlong15/vagrant-bind 
- добавить еще один сервер client2
- завести в зоне dns.lab имена:

web1 - смотрит на клиент1

web2  смотрит на клиент2
- завести еще одну зону newdns.lab
  завести в ней запись
  www - смотрит на обоих клиентов

2. настроить split-dns
- клиент1 - видит обе зоны, но в зоне dns.lab только web1
- клиент2 видит только dns.lab


## Работа со стендом и настройка DNS

# 1. Развернуть стенд

- Скачать стенд <https://github.com/erlong15/vagrant-bind> и изучить содержимое файлов:
```
[yurpv@precision3561 DNS]$ git clone https://github.com/erlong15/vagrant-bind
Cloning into 'vagrant-bind'...
remote: Enumerating objects: 27, done.
remote: Total 27 (delta 0), reused 0 (delta 0), pack-reused 27 (from 1)
Receiving objects: 100% (27/27), 4.40 KiB | 4.40 MiB/s, done.
Resolving deltas: 100% (9/9), done.
[yurpv@precision3561 DNS]$ cd vagrant-bind/
[yurpv@precision3561 vagrant-bind]$ ls -l
total 12
drwxr-xr-x 2 yurpv yurpv 4096 авг 30 12:45 provisioning
-rw-r--r-- 1 yurpv yurpv  414 авг 30 12:45 README.md
-rw-r--r-- 1 yurpv yurpv  820 авг 30 12:45 Vagrantfile
```

- В файл Vagrantfile добавить еще один сервер client2 - [Vagrantfile]

>- Vagranfile описывает создание 4 виртуальных машин на CentOS 7, каждой машине будет выделено по 256 МБ ОЗУ. В начале файла есть модуль, который отвечает за настройку ВМ с помощью Ansible.

 - [playbook.yml] — это Ansible-playbook, в котором содержатся инструкции по настройке стенда
 - client-motd — файл, содержимое которого будет появляться перед пользователем, который подключился по SSH
 - named.ddns.lab и named.dns.lab — файлы описания зон ddns.lab и dns.lab соответсвенно
 - master-named.conf и slave-named.conf — конфигурационные файлы, в которых хранятся настройки DNS-сервера
 - client-resolv.conf и servers-resolv.conf — файлы, в которых содержатся IP-адреса DNS-серверов

>- **Для нормальной работы DNS-серверов, на них должно быть настроено одинаковое время.** Для того, чтобы на всех серверах было одинаковое время, необходимо настроить NTP. В CentOS по умолчанию уже есть NTP-клиент Chrony. Обычно он всегда включен и добавлен в автозагрузку. Проверить работу службы можно командой: systemctl status chronyd

>- **При варианте установки утилиты ntp, после установки необходимо:**
>-  - Остановить службу chronyd: systemctl stop chronyd
>-  - Удалить службу chronyd из автозагрузки: systemctl disable chronyd
>-  - Включить службу ntpd: systemctl start ntpd
>-  - Добавить службу ntpd в автозагрузку: systemctl enable ntpd

>- Пример данной настройки в Ansible (YAML-формат):
```
- name: stop and disable chronyd
  service:
    name: chronyd
    state: stopped
    enabled: false
- name: start and enable ntpd
  service:
    name: ntpd
    state: started
    enabled: true
```
>- **Альтернативный вариант — не устанавливать ntp и просто запустить службу chronyd: systemctl start chronyd**
>- Пример данной настройки в Ansible (YAML формат):

```
- name: install packages
  yum:
    name:
    - bind
    - bind-utils
    - vim
    state: latest
    update_cache: true

- name: start chronyd
  service:
    name: chronyd
    state: restarted
    enabled: true
```
- В данном развертывании будет установлена утилита ntp
>- **vagrant up --provision** - это команда, которая используется для настройки внутреннего окружения имеющейся виртуальной машины. Например, она позволяет добавить новые инструкции (скрипты) в ранее созданную виртуальную машину.

- Перед выполнением следующих заданий, нужно обратить внимание, на каком адресе и порту работают наши DNS-сервера. 

- Проверим на каком адресе и порту работают DNS-сервера:
- - Посмотреть с помощью команды SS: ss -tulpn
```
[root@ns01 ~]# ss -tunlp
Netid  State      Recv-Q Send-Q                                                         Local Address:Port                                                                        Peer Address:Port              
udp    UNCONN     0      0                                                              192.168.50.10:53                                                                                     *:*                   users:(("named",pid=16689,fd=512))
udp    UNCONN     0      0                                                                          *:68                                                                                     *:*                   users:(("dhclient",pid=2512,fd=6))
udp    UNCONN     0      0                                                                          *:111                                                                                    *:*                   users:(("rpcbind",pid=344,fd=6))
udp    UNCONN     0      0                                                              192.168.50.10:123                                                                                    *:*                   users:(("ntpd",pid=14804,fd=20))
udp    UNCONN     0      0                                                                  10.0.2.15:123                                                                                    *:*                   users:(("ntpd",pid=14804,fd=19))
udp    UNCONN     0      0                                                                  127.0.0.1:123                                                                                    *:*                   users:(("ntpd",pid=14804,fd=18))
udp    UNCONN     0      0                                                                          *:123                                                                                    *:*                   users:(("ntpd",pid=14804,fd=16))
udp    UNCONN     0      0                                                                          *:930                                                                                    *:*                   users:(("rpcbind",pid=344,fd=7))
udp    UNCONN     0      0                                                                      [::1]:53                                                                                  [::]:*                   users:(("named",pid=16689,fd=513))
udp    UNCONN     0      0                                                                       [::]:111                                                                                 [::]:*                   users:(("rpcbind",pid=344,fd=9))
udp    UNCONN     0      0                                            [fe80::a00:27ff:fe69:44b0]%eth1:123                                                                                 [::]:*                   users:(("ntpd",pid=14804,fd=23))
udp    UNCONN     0      0                                             [fe80::5054:ff:fe4d:77d3]%eth0:123                                                                                 [::]:*                   users:(("ntpd",pid=14804,fd=22))
udp    UNCONN     0      0                                                                      [::1]:123                                                                                 [::]:*                   users:(("ntpd",pid=14804,fd=21))
udp    UNCONN     0      0                                                                       [::]:123                                                                                 [::]:*                   users:(("ntpd",pid=14804,fd=17))
udp    UNCONN     0      0                                                                       [::]:930                                                                                 [::]:*                   users:(("rpcbind",pid=344,fd=10))
tcp    LISTEN     0      128                                                                        *:111                                                                                    *:*                   users:(("rpcbind",pid=344,fd=8))
tcp    LISTEN     0      10                                                             192.168.50.10:53                                                                                     *:*                   users:(("named",pid=16689,fd=21))
tcp    LISTEN     0      128                                                                        *:22                                                                                     *:*                   users:(("sshd",pid=5058,fd=3))
tcp    LISTEN     0      128                                                            192.168.50.10:953                                                                                    *:*                   users:(("named",pid=16689,fd=23))
tcp    LISTEN     0      100                                                                127.0.0.1:25                                                                                     *:*                   users:(("master",pid=811,fd=13))
tcp    LISTEN     0      128                                                                     [::]:111                                                                                 [::]:*                   users:(("rpcbind",pid=344,fd=11))
tcp    LISTEN     0      10                                                                     [::1]:53                                                                                  [::]:*                   users:(("named",pid=16689,fd=22))
tcp    LISTEN     0      128                                                                     [::]:22                                                                                  [::]:*                   users:(("sshd",pid=5058,fd=4))
tcp    LISTEN     0      100                                                                    [::1]:25                                                                                  [::]:*                   users:(("master",pid=811,fd=14))
```

- Посмотреть информацию в настройках DNS-сервера (**/etc/named.conf**)
```
[root@ns01 ~]# cat /etc/named.conf
options {

    // network
        listen-on port 53 { 192.168.50.10; };
        listen-on-v6 port 53 { ::1; };
```
```
[root@ns02 ~]# cat /etc/named.conf
options {

    // network
        listen-on port 53 { 192.168.50.11; };
        listen-on-v6 port 53 { ::1; };
```

- На основе данной информации, нужно внести корректировки в файл /etc/resolv.conf для DNS-серверов:на хосте ns01 указать nameserver 192.168.50.21, а на хосте ns02 — 192.168.50.11

>- В Ansible для этого можно воспользоваться шаблоном с Jinja. Изменим имя файла servers-resolv.conf на servers-resolv.conf.j2 и укажем там следующие условия:

```bash
domain dns.lab
search dns.lab
#Если имя сервера ns02, то указываем nameserver 192.168.50.11
{% if ansible_hostname == 'ns02' %}
nameserver 192.168.50.11
{% endif %}
#Если имя сервера ns01, то указываем nameserver 192.168.50.10
{% if ansible_hostname == 'ns01' %}
nameserver 192.168.50.10
{% endif %}
```
>- После внесения измений в файл, нужно изменить ansible-playbook - вместо модуля copy модуль template:

```
- name: copy resolv.conf to the servers
  template: src=servers-resolv.conf.j2 dest=/etc/resolv.conf owner=root group=root mode=0644
```
 YAML-формат:

```
- name: copy resolv.conf to the servers
  template:
    src: servers-resolv.conf.j2
    dest: /etc/resolv.conf
    owner: root
    group: root
    mode: 0644
```

### 2. Настройка  DNS

- **Добавление имён в зону dns.lab**
- Проверить, что зона dns.lab уже существует на DNS-серверах:

```
// Имя зоны
zone "dns.lab" {
    type master;
    // Тем, у кого есть ключ zonetransfer.key можно получать копию файла зоны
    allow-transfer { key "zonetransfer.key"; };
    // Файл с настройками зоны
    file "/etc/named/named.dns.lab";
};
```
- Фрагмент файла /etc/named.conf на сервере ns01:
```
// lab's zone
zone "dns.lab" {
    type master;
    allow-transfer { key "zonetransfer.key"; };
    file "/etc/named/named.dns.lab";
};
```

- Похожий фрагмент файла /etc/named.conf находится на slave-сервере ns02:
```
// lab's zone
zone "dns.lab" {
    type slave;
    masters { 192.168.50.10; };
    file "/etc/named/named.dns.lab";
};
```

- На хосте ns01 мы видим файл /etc/named/named.dns.lab с настройкой зоны:

```
[root@ns01 ~]# cat /etc/named/named.dns.lab
$TTL 3600
$ORIGIN dns.lab.
@               IN      SOA     ns01.dns.lab. root.dns.lab. (
                            2711201407 ; serial
                            3600       ; refresh (1 hour)
                            600        ; retry (10 minutes)
                            86400      ; expire (1 day)
                            600        ; minimum (10 minutes)
                        )

                IN      NS      ns01.dns.lab.
                IN      NS      ns02.dns.lab.

; DNS Servers
ns01            IN      A       192.168.50.10
ns02            IN      A       192.168.50.11
```
- В этот файл добавить имена:

```bash
;Web
web1            IN      A       192.168.50.15
web2            IN      A       192.168.50.16
```
```
[root@ns01 ~]# vi /etc/named/named.dns.lab
[root@ns01 ~]# cat /etc/named/named.dns.lab
$TTL 3600
$ORIGIN dns.lab.
@               IN      SOA     ns01.dns.lab. root.dns.lab. (
                            2711201407 ; serial
                            3600       ; refresh (1 hour)
                            600        ; retry (10 minutes)
                            86400      ; expire (1 day)
                            600        ; minimum (10 minutes)
                        )

                IN      NS      ns01.dns.lab.
                IN      NS      ns02.dns.lab.

; DNS Servers
ns01            IN      A       192.168.50.10
ns02            IN      A       192.168.50.11
; WWW
web1            IN      A       192.168.50.15
web2            IN      A       192.168.50.16
```

>- Если изменения внесены вручную, то для применения настроек нужно:
-  Перезапустить службу named: systemctl restart named
-  Изменить значение Serial (добавить +1 к числу 2711201407), изменение значения serial укажет slave-серверам на то, что были внесены изменения и что им надо обновить свои файлы с зонами.

- Выполнить проверку с клиента - обращениек  разным DNS-серверам с разными запросами:
```
[root@client ~]# dig @192.168.50.10 web1.dns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.16 <<>> @192.168.50.10 web1.dns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 55430
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;web1.dns.lab.                  IN      A

;; ANSWER SECTION:
web1.dns.lab.           3600    IN      A       192.168.50.15

;; AUTHORITY SECTION:
dns.lab.                3600    IN      NS      ns02.dns.lab.
dns.lab.                3600    IN      NS      ns01.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.           3600    IN      A       192.168.50.10
ns02.dns.lab.           3600    IN      A       192.168.50.11

;; Query time: 0 msec
;; SERVER: 192.168.50.10#53(192.168.50.10)
;; WHEN: Fri Aug 30 13:23:28 MSK 2024
;; MSG SIZE  rcvd: 127
```
```
[root@client2 ~]# dig @192.168.50.11 web2.dns.lab

; <<>> DiG 9.11.4-P2-RedHat-9.11.4-26.P2.el7_9.16 <<>> @192.168.50.11 web2.dns.lab
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 21687
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 3

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;web2.dns.lab.                  IN      A

;; ANSWER SECTION:
web2.dns.lab.           3600    IN      A       192.168.50.16

;; AUTHORITY SECTION:
dns.lab.                3600    IN      NS      ns02.dns.lab.
dns.lab.                3600    IN      NS      ns01.dns.lab.

;; ADDITIONAL SECTION:
ns01.dns.lab.           3600    IN      A       192.168.50.10
ns02.dns.lab.           3600    IN      A       192.168.50.11

;; Query time: 0 msec
;; SERVER: 192.168.50.11#53(192.168.50.11)
;; WHEN: Fri Aug 30 13:25:01 MSK 2024
;; MSG SIZE  rcvd: 127
```

- Добавление имён в зону dns.lab с помощью Ansible

>- В существующем Ansible-playbook менять ничего не потребуется, нужно добавить строки с новыми именами в файл [named.dns.lab] и снова запустить Ansible.

- **Создание новой зоны и добавление в неё записей**

- Для того, чтобы прописать на DNS-серверах новую зону необходимо:

- На хосте ns01 добавить зону в файл /etc/named.conf:

```bash
// lab's newdns zone
zone "newdns.lab" {
     type master;
     allow-transfer { key "zonetransfer.key"; };
     allow-update { key "zonetransfer.key"; };
     file "/etc/named/named.newdns.lab";
};
```

- На хосте ns02 также добавить зону и указать с какого сервера запрашивать информацию об этой зоне (фрагмент файла /etc/named.conf):

```bash
// lab's newdns zone
zone "newdns.lab" {
    type slave;
    masters { 192.168.50.10; };
    file "/etc/named/named.newdns.lab";
};
```
- На хосте ns01 создадим файл /etc/named/named.newdns.lab
```
[root@ns01 ~]# vi /etc/named/named.newdns.lab
$TTL 3600
$ORIGIN newdns.lab.
@               IN      SOA     ns01.dns.lab. root.dns.lab. (
                            2711201407 ; serial
                            3600       ; refresh (1 hour)
                            600        ; retry (10 minutes)
                            86400      ; expire (1 day)
                            600        ; minimum (10 minutes)
                        )

                IN      NS      ns01.dns.lab.
                IN      NS      ns02.dns.lab.

; DNS Servers
ns01            IN      A       192.168.50.10
ns02            IN      A       192.168.50.11
; WWW
www            IN      A       192.168.50.15
www            IN      A       192.168.50.16
```

В конце этого файла добавим записи "www". У файла должны быть права 660, владелец — root, группа — named.
```
[root@ns01 ~]# ls -l /etc/named/named.newdns.lab
-rw-rw----. 1 root named 698 Aug 30 12:08 /etc/named/named.newdns.lab
```
- После внесения данных изменений, изменяем значение serial (добавлем +1 к значению 2711201007) и перезапускаем named: systemctl restart named

- Создание новой зоны и добавление в неё записей **с помощью Ansible**. Для создания зоны и добавления в неё записей, нужно добавить зону в файл /etc/named.conf на хостах ns01 [master-named.conf] и ns02 [slave-named.conf ], а также создать файл [named.newdns.lab](named.dns.lab), которые будут копироваться на сервер ns01 и ns02 через playbook.
- Добавить в модуль copy файл named.newdns.lab [playbook]

```yml
- name: copy zones
    copy: src={{ item }} dest=/etc/named/ owner=root group=named mode=0660
    with_fileglob:
      - named.d*
      - named.newdns.lab
```
>- Соответственно файл named.newdns.lab будет скопирован на хост ns01 по адресу /etc/named/named.newdns.lab

### Настройка Split-DNS

- Прописанные зоны dns.lab и newdns.lab. 
  Необходимо:
   - client1 должен видеть запись web1.dns.lab и не видеть запись web2.dns.lab. 
   - client2 может видеть обе записи из домена dns.lab, но не должен видеть записи домена newdns.lab

- **Для настройки Split-DNS нужно:**

- Создать дополнительный файл зоны dns.lab, в котором будет прописана только одна запись: vim /etc/named/named.dns.lab.client
>- **Имя файла может отличаться от указанной зоны. У файла должны быть права 660, владелец — root, группа — named.**
```
[root@ns01 ~]# touch /etc/named/named.dns.lab.client
[root@ns01 ~]# chgrp named /etc/named/named.dns.lab.client
[root@ns01 ~]# chmod 660 /etc/named/named.dns.lab.client
[root@ns01 ~]# ls -l /etc/named/named.dns.lab.client
-rw-rw----. 1 root named 651 Aug 30 12:08 /etc/named/named.dns.lab.client
```
```
[root@ns01 ~]# cat /etc/named/named.dns.lab.client
$TTL 3600
$ORIGIN dns.lab.
@               IN      SOA     ns01.dns.lab. root.dns.lab. (
                            2711201407 ; serial
                            3600       ; refresh (1 hour)
                            600        ; retry (10 minutes)
                            86400      ; expire (1 day)
                            600        ; minimum (10 minutes)
                        )

                IN      NS      ns01.dns.lab.
                IN      NS      ns02.dns.lab.

; DNS Servers
ns01            IN      A       192.168.50.10
ns02            IN      A       192.168.50.11
; Web
web1            IN      A       192.168.50.15
```

- Внести изменения в файл /etc/named.conf на хостах ns01 и ns02

- Прежде всего нужно сделать access листы для хостов client и client2. Сначала сгенерируем ключи для хостов client и client2, для этого на хосте ns01 запустим утилиту tsig-keygen (ключ может генериться 5 минут и более):
```
[root@ns01 ~]# tsig-keygen
key "tsig-key" {
        algorithm hmac-sha256;
        secret "iU+S7SS2P6iWfENaWQIFRKoHQmIaTbu4jA6uw9a5Yyo=";
};
```

- После генерации, мы увидем ключ (secret) и алгоритм с помощью которого он был сгенерирован. Оба этих параметра нам потребуются в access листе.
>- Если нам потребуется, использовать другой алогоритм, то мы можем его указать как аргумент к команде, например: tsig-keygen -a hmac-md5

- Всего нам потребуется 2 таких ключа. 
```
[root@client ~]# tsig-keygen client-key
key "client-key" {
        algorithm hmac-sha256;
        secret "8V5VqHXrloRjSsUGK0YESZyYesHIzxCvsDT6/RwzoNs=";
};
```
```
[root@client2 ~]# tsig-keygen client2-key
key "client2-key" {
        algorithm hmac-sha256;
        secret "b6Ncwas9gRXqO5en+yzQmIKXD44hdtGp7jsTuA9EpQ4=";
};
```

- После их генерации добавим блок с access листами в конец файла /etc/named.conf

```
key "client-key" {
 algorithm hmac-sha256;
 secret "8V5VqHXrloRjSsUGK0YESZyYesHIzxCvsDT6/RwzoNs=";
};

key "client2-key" {
 algorithm hmac-sha256;
 secret "b6Ncwas9gRXqO5en+yzQmIKXD44hdtGp7jsTuA9EpQ4=";
};

acl client { !key client2-key; key client-key; 192.168.50.15; };
acl client2 { !key client-key; key client2-key; 192.168.50.16; };
```
- В данном блоке access листов мы выделяем 2 блока:

- client имеет адрес 192.168.50.15, использует client-key и не использует client2-key
- client2 имеет адрес 192.168.50.16, использует clinet2-key и не использует client-key

- Описание ключей и access листов будет одинаковое для master и slave сервера.

- - Далее нужно создать файл с настройками зоны dns.lab для client, для этого на мастер сервере создаём файл /etc/named/named.dns.lab.client и добавляем в него следующее содержимое:
```
$TTL 3600
$ORIGIN dns.lab.
@               IN      SOA     ns01.dns.lab. root.dns.lab. (
                            2711201407 ; serial
                            3600       ; refresh (1 hour)
                            600        ; retry (10 minutes)
                            86400      ; expire (1 day)
                            600        ; minimum (10 minutes)
                        )

                IN      NS      ns01.dns.lab.
                IN      NS      ns02.dns.lab.

; DNS Servers
ns01            IN      A       192.168.50.10
ns02            IN      A       192.168.50.11
; Web
web1            IN      A       192.168.50.15
```

>- Это почти скопированный файл зоны dns.lab, в конце которого удалена строка с записью web2. Имя зоны надо оставить такое же — dns.lab

- Далее нужно внести правки в /etc/named.conf

>- Технология Split-DNS реализуется с помощью описания представлений (view), для каждого отдельного acl. В каждое представление (view) добавляются только те зоны, которые разрешено видеть хостам, адреса которых указаны в access листе.

>- **Все ранее описанные зоны должны быть перенесены в модули view. Вне view зон быть недолжно, зона 'any' должна всегда находиться в самом низу.**

- После применения всех вышеуказанных правил на хосте ns01 мы получим следующее содержимое файла [/etc/named.conf](master-named.conf)

- Внести изменения в файл /etc/named.conf на сервере ns02. Файл будет похож на файл для ns01, только в настройках будет указание забирать информацию с сервера ns01 и указан тип slave. Итоговый файл для ns02 [/etc/named.conf](slave-named.conf)

>- Так как файлы с конфигурациями получаются достаточно большими — возрастает вероятность сделать ошибку. При их правке можно воспользоваться утилитой **named-checkconf**. Она укажет в каких строчках есть ошибки. Использование данной утилиты рекомендуется после изменения настроек на DNS-сервере.
```
named-checkconf /etc/named.conf
named-checkconf -t /var/named/chroot /etc/named.conf 
```
- После внесения данных изменений можно перезапустить (по очереди) службу named на серверах ns01 и ns02.

- Проверка работы Split-DNS с хостов client и client2. Для проверки можно использовать утилиту ping:
```
ping www.newdns.lab
ping web1.dns.lab
ping web2.dns.lab
```

![image2](./1.png)
>- **На хосте мы видим, что client1 видит обе зоны (dns.lab и newdns.lab), однако информацию о хосте web2.dns.lab он получить не может.**

![image2](./2.png)
>- Тут мы понимаем, что client2 видит всю зону dns.lab и не видит зону newdns.lab
Для того, чтобы проверить что master и slave сервера отдают одинаковую информацию, в файле /etc/resolv.conf можно удалить на время nameserver 192.168.50.10 и попробовать выполнить все те же проверки. Результат должен быть идентичный. 

### Настройка Split-DNS c помощью Ansible

- [Ansible-playbook] менять ничего не потребуется. Нужно изменить содержимое файлов master-named.conf и slave-named.conf, а также добавить файл [named.dns.lab.client].

>- После перезапуска виртуалок стенда, файл /etc/resolv.conf перезаписывался
>- Запрет изменения файла /etc/resolv.conf
```
[root@client2 ~]# chattr +i /etc/resolv.conf
[root@client2 ~]# ls -la /etc/resolv.conf
-rw-r--r--. 1 root root 80 Aug 30 12:16 /etc/resolv.conf
[root@client2 ~]# lsattr /etc/resolv.conf
----i----------- /etc/resolv.conf
```
>- Запрет изменения файла /etc/resolv.conf добавлено в playbook для клиентов
```
  - name: makefile immutable 
    command: chattr +i /etc/resolv.conf 
```


