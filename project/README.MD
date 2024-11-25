# Project 

## Запуск
```bash 
vagrant ssh deployer 
sudo cp -r /deployer/ /home/vagrant/
cd /home/vagrant/deployer/
ansible-playbook -i hosts.ini pg_primary.yml pg_replica.yml web.yml nginx.yml monitoring.yml send_logs.yml
```



## Настройка вм backup при выводе из строя какой либо другой 

1. Зайти на вм и вначале удалить её стандартный адрес и установить адресс отключенной вм

```bash
vagrant ssh backup 
sudo vim /etc/netplan/50-vagrant.yaml
sudo netplan apply
sudo systemctl restart networking.service
```
В нетплане заменить `192.168.2.60` на ip выведенной из строя вм. Если это nginx то также попправить ip в сети 57. на 57.11

2. Запустить с соотвествующий плейбук настройки