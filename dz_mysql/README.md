# MySQL

## Цель домашнего задания
Репликация mysql

## Что нужно сделать?
В материалах приложены ссылки на вагрант для репликации и дамп базы bet.dmp

Базу развернуть на мастере и настроить так, чтобы реплицировались таблицы:
```
| bookmaker   |
| competition |
| market      |
| odds        |
| outcome     |
```
Настроить GTID репликацию

## Выполнение

- Разворачивает виртуалки в Vagrant (master,slave) с установкой mysql версии 8.0

```
vagrant up
```

- Percona устанавливается при разворачивании стенда и переносит необходимый конфиг.


По умолчанию Percona хранит файлы в таком виде:

- Основной конфиг в /etc/mysql/
- Так же инклудится директориā /etc/mysql/mysql.conf.d/ - куда мы и будем складывать наши конфиги
- Дата файлы в /var/lib/mysql

- Проверяем службу mysql
```
root@master:~# systemctl status mysql
● mysql.service - Percona Server
     Loaded: loaded (/lib/systemd/system/mysql.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2024-09-05 02:12:26 MSK; 2h 9min left
   Main PID: 1009 (mysqld)
     Status: "Server is operational"
      Tasks: 41 (limit: 2207)
     Memory: 450.2M
        CPU: 39.540s
     CGroup: /system.slice/mysql.service
             └─1009 /usr/sbin/mysqld

Sep 05 02:12:25 master systemd[1]: Starting Percona Server...
Sep 05 02:12:26 master systemd[1]: Started Percona Server.
```

- Подключаемся к mysql и меняем пароль для доступа к полному функционалу

```
mysql -uroot 

ALTER USER USER() IDENTIFIED BY 'P@ssw0rd';
```

- Репликацию будем настраивать с использованием GTID. Что это такое и зачем это надо можно почитать [здесь](https://dev.mysql.com/doc/refman/5.6/en/replication-gtids-concepts.html).

- - Следует обратить внимание, что атрибут server-id на мастер-сервере должен обязательно отличаться от server-id слейв-сервера. Проверить какая переменная установлена в текущий момент можно следующим образом
```
mysql> SELECT @@server_id;
+-------------+
| @@server_id |
+-------------+
|           1 |
+-------------+
1 row in set (0.00 sec)
```

- Убеждаемся что GTID включен
```
mysql> SHOW VARIABLES LIKE 'gtid_mode';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| gtid_mode     | ON    |
+---------------+-------+
1 row in set (0.03 sec)
```

- Создадим тестовую базу bet и загрузим в нее дамп и проверим
```
mysql> CREATE DATABASE bet;
Query OK, 1 row affected (0.01 sec)
```
```
root@master:~# mysql -uroot -p -D bet < /home/vagrant/bet.dmp
```
```
mysql> USE bet;
Database changed
mysql> SHOW TABLES;
+------------------+
| Tables_in_bet    |
+------------------+
| bookmaker        |
| competition      |
| events_on_demand |
| market           |
| odds             |
| outcome          |
| v_same_event     |
+------------------+
7 rows in set (0.00 sec)
```

- Создадим полþзователā для репликации и даем ему права на эту саму репликацию:
```
mysql> CREATE USER 'repl'@'%' IDENTIFIED BY '!OtusLinux2024';
Query OK, 0 rows affected (0.02 sec)
```
```
mysql> SELECT user,host FROM mysql.user where user='repl';
+------+------+
| user | host |
+------+------+
| repl | %    |
+------+------+
1 row in set (0.00 sec)
```
```
mysql> GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
Query OK, 0 rows affected (0.01 sec)

mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.01 sec)
```

- Дампим базу длā последующего залива на слэйв и игнорируем таблицы по заданию:
```
root@master:~# mysqldump --all-databases --triggers --routines --master-data --ignore-table=bet.events_on_demand --ignore-table=bet.v_same_event -uroot -p > /home/vagrant/master.sql
```

- копируем дамп на slave

```
vagrant plugin install vagrant-scp
vagrant scp master:/vagrant/master.sql .
vagrant scp master.sql slave:/vagrant/
```

> На этом настройка Master-а завершена. Файл дампа нужно залить на слейв.

- Проверяем на slave директиву server-id = 2
```
mysql> SELECT @@server_id;
+-------------+
| @@server_id |
+-------------+
|           2 |
+-------------+
1 row in set (0.00 sec)
```

- Заливаем дамп мастера и убеждаемся, что база есть и она без лишних таблиц
```
mysql> SOURCE /home/vagrant/master.sql
Query OK, 0 rows affected (0.00 sec)

Query OK, 0 rows affected (0.00 sec)

Query OK, 0 rows affected (0.00 sec)
...

mysql> SHOW DATABASES LIKE 'bet';
+----------------+
| Database (bet) |
+----------------+
| bet            |
+----------------+
1 row in set (0.00 sec)

mysql> use bet;
Database changed
mysql> SHOW TABLES;
+---------------+
| Tables_in_bet |
+---------------+
| bookmaker     |
| competition   |
| market        |
| odds          |
| outcome       |
+---------------+
5 rows in set (0.00 sec)
```

> видим что таблиц v_same_event и events_on_demand нет

- Ну и собственно подключаем и запускаем слейв

```
mysql> START SLAVE;
Query OK, 0 rows affected, 1 warning (0.02 sec)

mysql> SHOW SLAVE STATUS\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for source to send event
                  Master_Host: 192.168.11.150
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000006
          Read_Master_Log_Pos: 1097
               Relay_Log_File: relay-log-server.000003
                Relay_Log_Pos: 460
        Relay_Master_Log_File: mysql-bin.000006
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes     
```

- Видно что репликация работает, gtid работает и игнорятся таблички по заданию

```
    Master_UUID: dad6833f-6ada-11ef-bcf8-000c29621886
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Replica has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: dad6833f-6ada-11ef-bcf8-000c29621886:40-43
            Executed_Gtid_Set: dad6833f-6ada-11ef-bcf8-000c29621886:1-43
```

- Проверим репликацю в действии. На мастере

```
mysql> USE bet;
Database changed
mysql> INSERT INTO bookmaker (id,bookmaker_name) VALUES(1,'1xbet');
Query OK, 1 row affected (0.00 sec)

mysql> SELECT * FROM bookmaker;
+----+----------------+
| id | bookmaker_name |
+----+----------------+
|  1 | 1xbet          |
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  3 | unibet         |
+----+----------------+
5 rows in set (0.00 sec)
```

- На слейве

```
mysql> SELECT * FROM bookmaker;
+----+----------------+
| id | bookmaker_name |
+----+----------------+
|  1 | 1xbet          |
|  4 | betway         |
|  5 | bwin           |
|  6 | ladbrokes      |
|  3 | unibet         |
+----+----------------+
5 rows in set (0.00 sec)
```

- В binlog-ах на cлейве также видно последнее изменение, туда же он пишет информацию о GTID

```
mysql> SHOW BINLOG EVENTS;
+------------------+-----+----------------+-----------+-------------+--------------------------------------+
| Log_name         | Pos | Event_type     | Server_id | End_log_pos | Info                                 |
+------------------+-----+----------------+-----------+-------------+--------------------------------------+
| mysql-bin.000001 |   4 | Format_desc    |         2 |         126 | Server ver: 8.0.37-29, Binlog ver: 4 |
| mysql-bin.000001 | 126 | Previous_gtids |         2 |         157 |                                      |
| mysql-bin.000001 | 157 | Stop           |         2 |         180 |                                      |
+------------------+-----+----------------+-----------+-------------+--------------------------------------+
3 rows in set (0.00 sec)
```

> При выполнении команд mysql> START SLAVE; mysql> SHOW SLAVE STATUS\G отчет выдал ошибку:



> Для ее устранения нужно выполнить команду на master и slave
```
mysql> CHANGE MASTER TO GET_MASTER_PUBLIC_KEY=1;
Query OK, 0 rows affected, 2 warnings (0.01 sec)
```
