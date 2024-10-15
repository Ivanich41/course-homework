# VLAN

## Цели домашнего задания
Научиться настраивать VLAN и LACP. 

## Описание домашнего задания
в Office1 в тестовой подсети появляется сервера с доп интерфейсами и адресами
в internal сети testLAN: 
- testClient1 - 10.10.10.254
- testClient2 - 10.10.10.254
- testServer1- 10.10.10.1 
- testServer2- 10.10.10.1

Равести вланами:
testClient1 <-> testServer1
testClient2 <-> testServer2

Между centralRouter и inetRouter "пробросить" 2 линка (общая inernal сеть) и объединить их в бонд, проверить работу c отключением интерфейсов

Формат сдачи ДЗ - vagrant + ansible

### Предварительная настройка хостов

- Перед настройкой VLAN и LACP рекомендуется установить на хосты следующие утилиты:
```
vim
traceroute
tcpdump
net-tools
```

- Установка пакетов на CentOS 8 Stream: 
```
yum install -y vim traceroute tcpdump net-tools 
```

- Установка пакетов на Ubuntu 22.04:
```
apt install -y vim traceroute tcpdump net-tools 
```

## Настройка VLAN на хостах

### Настройка VLAN на RHEL-based системах:

- На хосте testClient1 требуется создать файл /etc/sysconfig/network-scripts/ifcfg-vlan1 со следующим параметрами:
```
[root@testClient1 /]# vi /etc/sysconfig/network-scripts/ifcfg-vlan1
VLAN=yes
#Тип интерфейса - VLAN
TYPE=Vlan
#Указываем физическое устройство, через которые будет работать VLAN
PHYSDEV=eth1
#Указываем номер VLAN (VLAN_ID)
VLAN_ID=1
VLAN_NAME_TYPE=DEV_PLUS_VID_NO_PAD
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
#Указываем IP-адрес интерфейса
IPADDR=10.10.10.254
#Указываем префикс (маску) подсети
PREFIX=24
#Указываем имя vlan
NAME=vlan1
#Указываем имя подинтерфейса
DEVICE=eth1.1
ONBOOT=yes
```
- На хосте testServer1 создадим идентичный файл с другим IP-адресом (10.10.10.1).
```
VLAN=yes
#Тип интерфейса - VLAN
TYPE=Vlan
#Указываем физическое устройство, через которые будет работать VLAN
PHYSDEV=eth1
#Указываем номер VLAN (VLAN_ID)
VLAN_ID=1
VLAN_NAME_TYPE=DEV_PLUS_VID_NO_PAD
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
#Указываем IP-адрес интерфейса
IPADDR=10.10.10.1
#Указываем префикс (маску) подсети
PREFIX=24
#Указываем имя vlan
NAME=vlan1
#Указываем имя подинтерфейса
DEVICE=eth1.1
ONBOOT=yes
```

- После создания файлов нужно перезапустить сеть на обоих хостах:
systemctl restart NetworkManager

- Проверим настройку интерфейса, если настройка произведена правильно, то с хоста testClient1 будет проходить ping до хоста testServer1:
```
[root@testClient1 /]# systemctl restart NetworkManager
[root@testClient1 /]# ip a 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:7a:b7:00 brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute eth0
       valid_lft 86386sec preferred_lft 86386sec
    inet6 fe80::5054:ff:fe7a:b700/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:88:e4:ae brd ff:ff:ff:ff:ff:ff
    altname enp0s8
    inet6 fe80::d32b:306f:f281:6120/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:3b:8b:4a brd ff:ff:ff:ff:ff:ff
    altname enp0s19
    inet 192.168.56.21/24 brd 192.168.56.255 scope global noprefixroute eth2
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe3b:8b4a/64 scope link 
       valid_lft forever preferred_lft forever
5: eth1.1@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:88:e4:ae brd ff:ff:ff:ff:ff:ff
    inet 10.10.10.254/24 brd 10.10.10.255 scope global noprefixroute eth1.1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe88:e4ae/64 scope link 
       valid_lft forever preferred_lft forever
[root@testClient1 /]#  ping 10.10.10.254
PING 10.10.10.254 (10.10.10.254) 56(84) bytes of data.
64 bytes from 10.10.10.254: icmp_seq=1 ttl=64 time=0.021 ms
64 bytes from 10.10.10.254: icmp_seq=2 ttl=64 time=0.052 ms
64 bytes from 10.10.10.254: icmp_seq=3 ttl=64 time=0.027 ms
^C
--- 10.10.10.254 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2047ms
rtt min/avg/max/mdev = 0.021/0.033/0.052/0.014 ms
```
```
[root@testServer1 /]# systemctl restart NetworkManager
[root@testServer1 /]# ip a 
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:7a:b7:00 brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute eth0
       valid_lft 86367sec preferred_lft 86367sec
    inet6 fe80::5054:ff:fe7a:b700/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:71:ea:dd brd ff:ff:ff:ff:ff:ff
    altname enp0s8
    inet6 fe80::82e0:7b5:f0c9:870a/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:23:64:b6 brd ff:ff:ff:ff:ff:ff
    altname enp0s19
    inet 192.168.56.22/24 brd 192.168.56.255 scope global noprefixroute eth2
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe23:64b6/64 scope link 
       valid_lft forever preferred_lft forever
5: eth1.1@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 08:00:27:71:ea:dd brd ff:ff:ff:ff:ff:ff
    inet 10.10.10.1/24 brd 10.10.10.255 scope global noprefixroute eth1.1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe71:eadd/64 scope link 
       valid_lft forever preferred_lft forever
```

### Настройка VLAN на Ubuntu:

- На хосте testClient2 требуется создать файл /etc/netplan/50-cloud-init.yaml со следующим параметрами:
```
root@testClient2:~# cat /etc/netplan/50-cloud-init.yaml
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    version: 2
    ethernets:
        enp0s3:
            dhcp4: true
        #В разделе ethernets добавляем порт, на котором будем настраивать VLAN
        enp0s8: {}
    #Настройка VLAN
    vlans:
        #Имя VLANа
        vlan2:
          #Указываем номер VLAN`а
          id: 2
          #Имя физического интерфейса
          link: enp0s8
          #Отключение DHCP-клиента
          dhcp4: no
          #Указываем ip-адрес
          addresses: [10.10.10.254/24]
```

- На хосте testServer2 создадим идентичный файл с другим IP-адресом (10.10.10.1).</br>
После создания файлов нужно перезапустить сеть на обоих хостах: netplan apply
```
root@testServer2:~# cat /etc/netplan/50-cloud-init.yaml
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    version: 2
    ethernets:
        enp0s3:
            dhcp4: true
        #В разделе ethernets добавляем порт, на котором будем настраивать VLAN
        enp0s8: {}
    #Настройка VLAN
    vlans:
        #Имя VLANа
        vlan2:
          #Указываем номер VLAN`а
          id: 2
          #Имя физического интерфейса
          link: enp0s8
          #Отключение DHCP-клиента
          dhcp4: no
          #Указываем ip-адрес
          addresses: [10.10.10.1/24]
```

- После настройки второго VLAN`а ping должен работать между хостами testClient1, testServer1 и между хостами testClient2, testServer2.
```
[root@testServer1 /]# ping 10.10.10.254
PING 10.10.10.254 (10.10.10.254) 56(84) bytes of data.
64 bytes from 10.10.10.254: icmp_seq=1 ttl=64 time=1.19 ms
64 bytes from 10.10.10.254: icmp_seq=2 ttl=64 time=1.01 ms
64 bytes from 10.10.10.254: icmp_seq=3 ttl=64 time=0.919 ms
64 bytes from 10.10.10.254: icmp_seq=4 ttl=64 time=0.891 ms
^C
--- 10.10.10.254 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
rtt min/avg/max/mdev = 0.891/1.002/1.185/0.114 ms
```
```
[root@testClient1 /]# ping 10.10.10.1
PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=0.907 ms
64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=0.788 ms
64 bytes from 10.10.10.1: icmp_seq=3 ttl=64 time=0.827 ms
^C
--- 10.10.10.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2046ms
rtt min/avg/max/mdev = 0.788/0.840/0.907/0.059 ms
```
```
root@testServer2:~# ping 10.10.10.254
PING 10.10.10.254 (10.10.10.254) 56(84) bytes of data.
64 bytes from 10.10.10.254: icmp_seq=1 ttl=64 time=0.383 ms
64 bytes from 10.10.10.254: icmp_seq=2 ttl=64 time=0.403 ms
64 bytes from 10.10.10.254: icmp_seq=3 ttl=64 time=0.298 ms
64 bytes from 10.10.10.254: icmp_seq=4 ttl=64 time=0.679 ms
^C
--- 10.10.10.254 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3362ms
rtt min/avg/max/mdev = 0.298/0.440/0.679/0.143 ms
```
```
root@testClient2:~# ping 10.10.10.1
PING 10.10.10.1 (10.10.10.1) 56(84) bytes of data.
64 bytes from 10.10.10.1: icmp_seq=1 ttl=64 time=1.29 ms
64 bytes from 10.10.10.1: icmp_seq=2 ttl=64 time=0.842 ms
64 bytes from 10.10.10.1: icmp_seq=3 ttl=64 time=0.885 ms
^C
--- 10.10.10.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2017ms
rtt min/avg/max/mdev = 0.842/1.005/1.289/0.201 ms
```

## Настройка LACP между хостами inetRouter и centralRouter

- Bond интерфейс будет работать через порты eth1 и eth2. 

- Изначально необходимо на обоих хостах добавить конфигурационные файлы для интерфейсов eth1 и eth2:</br>
(У интерфейса ifcfg-eth2 идентичный конфигурационный файл, в котором нужно изменить имя интерфейса.)
```
[root@inetRouter ~]# cat /etc/sysconfig/network-scripts/ifcfg-eth1
#Имя физического интерфейса
DEVICE=eth1
#Включать интерфейс при запуске системы
ONBOOT=yes
#Отключение DHCP-клиента
BOOTPROTO=none
#Указываем, что порт часть bond-интерфейса
MASTER=bond0
#Указываем роль bond
SLAVE=yes
NM_CONTROLLED=yes
USERCTL=no
```
```
[root@inetRouter ~]# cat /etc/sysconfig/network-scripts/ifcfg-eth2
#Имя физического интерфейса
DEVICE=eth2
#Включать интерфейс при запуске системы
ONBOOT=yes
#Отключение DHCP-клиента
BOOTPROTO=none
#Указываем, что порт часть bond-интерфейса
MASTER=bond0
#Указываем роль bond
SLAVE=yes
NM_CONTROLLED=yes
USERCTL=no
```
```
[root@centralRouter ~]# cat /etc/sysconfig/network-scripts/ifcfg-eth1
#Имя физического интерфейса
DEVICE=eth1
#Включать интерфейс при запуске системы
ONBOOT=yes
#Отключение DHCP-клиента
BOOTPROTO=none
#Указываем, что порт часть bond-интерфейса
MASTER=bond0
#Указываем роль bond
SLAVE=yes
NM_CONTROLLED=yes
USERCTL=no
```
```
[root@centralRouter ~]# cat /etc/sysconfig/network-scripts/ifcfg-eth2
#Имя физического интерфейса
DEVICE=eth2
#Включать интерфейс при запуске системы
ONBOOT=yes
#Отключение DHCP-клиента
BOOTPROTO=none
#Указываем, что порт часть bond-интерфейса
MASTER=bond0
#Указываем роль bond
SLAVE=yes
NM_CONTROLLED=yes
USERCTL=no
```

- После настройки интерфейсов eth1 и eth2 нужно настроить bond-интерфейс, для этого создадим файл /etc/sysconfig/network-scripts/ifcfg-bond0
```
[root@inetRouter ~]# cat /etc/sysconfig/network-scripts/ifcfg-bond0
DEVICE=bond0
NAME=bond0
#Тип интерфейса — bond
TYPE=Bond
BONDING_MASTER=yes
#Указаваем IP-адрес 
IPADDR=192.168.255.1
#Указываем маску подсети
NETMASK=255.255.255.252
ONBOOT=yes
BOOTPROTO=static
#Указываем режим работы bond-интерфейса Active-Backup
# fail_over_mac=1 — данная опция «разрешает отвалиться» одному интерфейсу
BONDING_OPTS="mode=1 miimon=100 fail_over_mac=1"
NM_CONTROLLED=yes
```

- После создания данных конфигурационных файлов необходимо перезапустить сеть:
systemctl restart NetworkManager
> На некоторых версиях RHEL/CentOS перезапуск сетевого интерфейса не запустит bond-интерфейс, в этом случае рекомендуется перезапустить хост.

- После настройки агрегации портов, необходимо проверить работу bond-интерфейса, для этого, на хосте inetRouter (192.168.255.1) запустим ping до centralRouter (192.168.255.2):
```
[root@inetRouter ~]# ping 192.168.255.2
PING 192.168.255.2 (192.168.255.2) 56(84) bytes of data.
64 bytes from 192.168.255.2: icmp_seq=1 ttl=64 time=0.532 ms
64 bytes from 192.168.255.2: icmp_seq=2 ttl=64 time=0.901 ms
64 bytes from 192.168.255.2: icmp_seq=3 ttl=64 time=0.423 ms
64 bytes from 192.168.255.2: icmp_seq=4 ttl=64 time=0.765 ms
^C
--- 192.168.255.2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3077ms
rtt min/avg/max/mdev = 0.423/0.655/0.901/0.188 ms
```

- Не отменяя ping подключаемся к хосту centralRouter и выключаем там интерфейс eth1: 
```
[root@inetRouter ~]# ip link set down eth1
[root@inetRouter ~]# ping 192.168.255.2
PING 192.168.255.2 (192.168.255.2) 56(84) bytes of data.
From 192.168.255.1 icmp_seq=1 Destination Host Unreachable
From 192.168.255.1 icmp_seq=2 Destination Host Unreachable
From 192.168.255.1 icmp_seq=3 Destination Host Unreachable
From 192.168.255.1 icmp_seq=4 Destination Host Unreachable
From 192.168.255.1 icmp_seq=5 Destination Host Unreachable
From 192.168.255.1 icmp_seq=6 Destination Host Unreachable
^C
--- 192.168.255.2 ping statistics ---
7 packets transmitted, 0 received, +6 errors, 100% packet loss, time 6170ms
pipe 3
```
