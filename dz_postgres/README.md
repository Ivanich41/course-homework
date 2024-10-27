# Postgresql


## Цель домашнего задания
Научиться настраивать репликацию и создавать резервные копии в СУБД PostgreSQL

- Цель
1) Настроить hot_standby репликацию с использованием слотов
2) Настроить правильное резервное копирование

## Выполнение

- Разворачиваем виртуалки в Vagrant (master,slave,barman) с помощью Ansible устанавливаем postgresql 16 и barman 3.* версии и донастроиваем сервера.

```
Postrgresql % vagrant up
Bringing machine 'master' up with 'vmware_desktop' provider...
Bringing machine 'slave' up with 'vmware_desktop' provider...
Bringing machine 'barman' up with 'vmware_desktop' provider...
==> master: Checking if box 'bento/ubuntu-22.04' version '202401.31.0' is up to date...
==> master: Verifying vmnet devices are healthy...
==> master: Starting the VMware VM...
==> master: Waiting for the VM to receive an address...
==> master: Forwarding ports...
    master: -- 22 => 2222
==> master: Waiting for machine to boot. This may take a few minutes...
    master: SSH address: 172.16.203.171:22
    master: SSH username: vagrant
    master: SSH auth method: password
==> master: Machine booted and ready!
==> slave: Checking if box 'bento/ubuntu-22.04' version '202401.31.0' is up to date...
==> slave: Verifying vmnet devices are healthy...
==> slave: Fixed port collision for 22 => 2222. Now on port 2200.
==> slave: Starting the VMware VM...
==> slave: Waiting for the VM to receive an address...
==> slave: Forwarding ports...
    slave: -- 22 => 2200
==> slave: Waiting for machine to boot. This may take a few minutes...
    slave: SSH address: 172.16.203.172:22
    slave: SSH username: vagrant
    slave: SSH auth method: password
==> slave: Machine booted and ready!
==> barman: Checking if box 'bento/ubuntu-22.04' version '202401.31.0' is up to date...
==> barman: Verifying vmnet devices are healthy...
==> barman: Fixed port collision for 22 => 2222. Now on port 2201.
==> barman: Starting the VMware VM...
==> barman: Waiting for the VM to receive an address...
==> barman: Forwarding ports...
    barman: -- 22 => 2201
==> barman: Waiting for machine to boot. This may take a few minutes...
    barman: SSH address: 172.16.203.173:22
    barman: SSH username: vagrant
    barman: SSH auth method: password
==> barman: Machine booted and ready!
```

<details><summary>ansible-playbook postgresql.yaml</summary>
    
```
Postrgresql % ansible-playbook postgresql.yaml                        

PLAY [all] *******************************************************************************************************************************************************************************************************

TASK [update] ****************************************************************************************************************************************************************************************************
ok: [slave]
ok: [master]
ok: [barman]

TASK [Upgrade all packages] **************************************************************************************************************************************************************************************
changed: [slave]
changed: [master]
changed: [barman]

TASK [Set timezone to Europe/Moscow] *****************************************************************************************************************************************************************************
ok: [slave]
ok: [barman]
ok: [master]

TASK [Install required packages] *********************************************************************************************************************************************************************************
ok: [master]
ok: [barman]
ok: [slave]

TASK [Set up Postgres repo] **************************************************************************************************************************************************************************************
changed: [barman]
changed: [master]
changed: [slave]

TASK [Download PostgreSQL key and add it to system keyring] ******************************************************************************************************************************************************
ok: [barman]
ok: [master]
ok: [slave]

PLAY [DB] ********************************************************************************************************************************************************************************************************

TASK [Update apt cache] ******************************************************************************************************************************************************************************************
ok: [master]
ok: [slave]

TASK [Install PostgreSQL] ****************************************************************************************************************************************************************************************
ok: [master]
ok: [slave]

PLAY [barman] ****************************************************************************************************************************************************************************************************

TASK [Update apt cache] ******************************************************************************************************************************************************************************************
ok: [barman]

TASK [Install PostgreSQL] ****************************************************************************************************************************************************************************************
ok: [barman]

PLAY [install postgres 16 and set up replication] ****************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************************
ok: [master]
ok: [slave]

TASK [postgres_master : Create a Superuser PostgreSQL database user] *********************************************************************************************************************************************
skipping: [slave]
ok: [master]

TASK [postgres_master : copy postgresql.conf] ********************************************************************************************************************************************************************
skipping: [slave]
ok: [master]

TASK [postgres_master : copy pg_hba.conf] ************************************************************************************************************************************************************************
skipping: [slave]
ok: [master]

TASK [postgres_master : Restart Postgresql] **********************************************************************************************************************************************************************
skipping: [slave]
changed: [master]

TASK [postgres_replication : stop postgresql-server on slave] ****************************************************************************************************************************************************
skipping: [master]
changed: [slave]

TASK [postgres_replication : Remove files from data catalog] *****************************************************************************************************************************************************
skipping: [master]
changed: [slave]

TASK [postgres_replication : copy files from master to slave] ****************************************************************************************************************************************************
skipping: [master]
changed: [slave]

TASK [postgres_replication : Ensure PostgreSQL is listening] *****************************************************************************************************************************************************
skipping: [master]
ok: [slave]

TASK [postgres_replication : Restart Postgresql] *****************************************************************************************************************************************************************
skipping: [master]
changed: [slave]

PLAY [install and setting barman] ********************************************************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************************************************
ok: [barman]
ok: [master]
ok: [slave]

TASK [barman : install base tools] *******************************************************************************************************************************************************************************
skipping: [master]
skipping: [slave]
ok: [barman]

TASK [barman : install barman and postgresql packages on barman] *************************************************************************************************************************************************
skipping: [master]
skipping: [slave]
ok: [barman]

TASK [barman : install barman-cli and postgresql packages on nodes] **********************************************************************************************************************************************
skipping: [master]
ok: [slave]
ok: [barman]

TASK [barman : generate SSH key for postgres] ********************************************************************************************************************************************************************
skipping: [slave]
skipping: [barman]
ok: [master]

TASK [barman : generate SSH key for barman] **********************************************************************************************************************************************************************
skipping: [master]
skipping: [slave]
ok: [barman]

TASK [barman : fetch all public ssh keys master] *****************************************************************************************************************************************************************
skipping: [slave]
skipping: [barman]
changed: [master]

TASK [barman : transfer public key to barman] ********************************************************************************************************************************************************************
skipping: [slave]
skipping: [barman]
ok: [master -> barman(192.168.57.13)]

TASK [barman : fetch all public ssh keys barman] *****************************************************************************************************************************************************************
skipping: [master]
skipping: [slave]
changed: [barman]

TASK [barman : transfer public key to barman] ********************************************************************************************************************************************************************
skipping: [master]
skipping: [slave]
ok: [barman -> master(192.168.57.11)]

TASK [barman : Create barman user] *******************************************************************************************************************************************************************************
skipping: [slave]
skipping: [barman]
ok: [master]

TASK [barman : restart postgresql-server on master] **************************************************************************************************************************************************************
skipping: [slave]
skipping: [barman]
changed: [master]

TASK [barman : Create DB for backup] *****************************************************************************************************************************************************************************
skipping: [slave]
skipping: [barman]
ok: [master]

TASK [barman : Add tables to otus_backup] ************************************************************************************************************************************************************************
skipping: [slave]
skipping: [barman]
ok: [master]

TASK [barman : copy .pgpass] *************************************************************************************************************************************************************************************
skipping: [master]
skipping: [slave]
ok: [barman]

TASK [barman : copy barman.conf] *********************************************************************************************************************************************************************************
skipping: [master]
skipping: [slave]
ok: [barman]

TASK [barman : copy master.conf] *********************************************************************************************************************************************************************************
skipping: [master]
skipping: [slave]
changed: [barman]

TASK [barman : barman switch-wal master] *************************************************************************************************************************************************************************
skipping: [master]
skipping: [slave]
changed: [barman]

TASK [barman : barman cron] **************************************************************************************************************************************************************************************
skipping: [master]
skipping: [slave]
changed: [barman]

PLAY RECAP *******************************************************************************************************************************************************************************************************
barman                     : ok=20   changed=6    unreachable=0    failed=0    skipped=7    rescued=0    ignored=0   
master                     : ok=21   changed=5    unreachable=0    failed=0    skipped=16   rescued=0    ignored=0   
slave                      : ok=16   changed=6    unreachable=0    failed=0    skipped=21   rescued=0    ignored=0   

```
</details>

-  Проверяем параметры подключения в файле на master и slave /etc/postgresql/16/main/pg_hba.conf
```
root@master:~# cat /etc/postgresql/16/main/pg_hba.conf
# PostgreSQL Client Authentication Configuration File
#
# Database administrative login by Unix domain socket
local   all             postgres                               trust 

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                          trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            scram-sha-256
# IPv6 local connections:
host    all             all             ::1/128                 scram-sha-256
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     peer
host    replication     all             127.0.0.1/32            scram-sha-256
host    replication     all             ::1/128                 scram-sha-256
host    replication     replication     192.168.57.11/32        scram-sha-256
host    replication     replication     192.168.57.12/32        scram-sha-256
host    all             barman          192.168.57.13/32        scram-sha-256
host    replication     barman          192.168.57.13/32        scram-sha-256
```
```
root@slave:~# cat /etc/postgresql/16/main/pg_hba.conf
# PostgreSQL Client Authentication Configuration File
#
# Database administrative login by Unix domain socket
local   all             postgres                               trust 

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                          trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            scram-sha-256
# IPv6 local connections:
host    all             all             ::1/128                 scram-sha-256
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     peer
host    replication     all             127.0.0.1/32            scram-sha-256
host    replication     all             ::1/128                 scram-sha-256
```

### Проверка репликации: 

- На хосте master в psql проверяем список БД:
```
root@master:~# sudo psql -U postgres
psql (16.4 (Ubuntu 16.4-1.pgdg22.04+1))
Type "help" for help.

postgres=# \l
                                                       List of databases
   Name    |  Owner   | Encoding | Locale Provider |   Collate   |    Ctype    | ICU Locale | ICU Rules |   Access privileges   
-----------+----------+----------+-----------------+-------------+-------------+------------+-----------+-----------------------
 demo      | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | 
 postgres  | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | 
 template0 | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | =c/postgres          +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
 template1 | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | =c/postgres          +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
(4 rows)
```

- На хосте slave также в psql также проверим список БД (команда \l), в списке БД должна появится БД demo.
```
root@slave:~# sudo psql -U postgres
psql (16.4 (Ubuntu 16.4-1.pgdg22.04+1))
Type "help" for help.

postgres=# \l
                                                       List of databases
   Name    |  Owner   | Encoding | Locale Provider |   Collate   |    Ctype    | ICU Locale | ICU Rules |   Access privileges   
-----------+----------+----------+-----------------+-------------+-------------+------------+-----------+-----------------------
 demo      | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | 
 postgres  | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | 
 template0 | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | =c/postgres          +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
 template1 | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | =c/postgres          +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
(3 rows)
```

- Также можно проверить репликацию другим способом: 
На хосте master в psql вводим команду: select * from pg_stat_replication;
На хосте slave в psql вводим команду: select * from pg_stat_wal_receiver;
Вывод обеих команд должен быть не пустым. 
```
postgres=# select * from pg_stat_replication;
-[ RECORD 1 ]----+------------------------------
pid              | 65805
usesysid         | 16384
usename          | replication
application_name | 16/main
client_addr      | 192.168.57.12
client_hostname  | 
client_port      | 33952
backend_start    | 2024-09-17 09:51:13.784037+03
backend_xmin     | 
state            | streaming
sent_lsn         | 0/290000D8
write_lsn        | 0/290000D8
flush_lsn        | 0/290006E8
replay_lsn       | 0/290006E8
write_lag        | 00:00:00.001052
flush_lag        | 00:00:00.001052
replay_lag       | 00:00:00.001052
sync_priority    | 0
sync_state       | async
reply_time       | 2024-09-17 09:54:24.536475+03
-[ RECORD 2 ]----+------------------------------
pid              | 65814
usesysid         | 16385
usename          | barman
application_name | barman_receive_wal
client_addr      | 192.168.57.13
client_hostname  | 
client_port      | 41148
backend_start    | 2024-09-17 09:52:01.672454+03
backend_xmin     | 
state            | streaming
sent_lsn         | 0/290000D8
write_lsn        | 0/290000D8
flush_lsn        | 0/29000000
replay_lsn       | 
write_lag        | 00:00:10.009961
flush_lag        | 00:02:20.130624
replay_lag       | 00:02:20.130624
sync_priority    | 0
sync_state       | async
reply_time       | 2024-09-17 09:54:21.850501+03
```
```
postgres=# select * from pg_stat_wal_receiver;
-[ RECORD 1 ]---------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
pid                   | 63660
status                | streaming
receive_start_lsn     | 0/29000000
receive_start_tli     | 1
written_lsn           | 0/290000D8
flushed_lsn           | 0/29000000
received_tli          | 1
last_msg_send_time    | 2024-09-17 09:55:17.730047+03
last_msg_receipt_time | 2024-09-17 09:55:17.712382+03
latest_end_lsn        | 0/290000D8
latest_end_time       | 2024-09-17 09:54:47.717219+03
slot_name             | 
sender_host           | 192.168.57.11
sender_port           | 5432
conninfo              | user=replication password=******** channel_binding=prefer dbname=replication host=192.168.57.11 port=5432 fallback_application_name=16/main sslmode=prefer sslcompression=0 sslcertmode=allow sslsni=1 ssl_min_protocol_version=TLSv1.2 gssencmode=prefer krbsrvname=postgres gssdelegation=0 target_session_attrs=any load_balance_hosts=disable
```
> На этом настройка репликации завершена.

## Настройка резервного копирования

- на сервере Barman проверить настройки, что корректно отработал ansible-playbook
- Проверяем возможность подключения к postgres-серверу:
```
root@barman:~# psql -h 192.168.57.11 -U barman -d postgres
Password for user barman: 
psql (16.4 (Ubuntu 16.4-1.pgdg22.04+1))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off)
Type "help" for help.

postgres=# \q
```

- Проверяем репликацию:
```
root@barman:~# psql -h 192.168.57.11 -U barman -c "IDENTIFY_SYSTEM" replication=1
Password for user barman: 
      systemid       | timeline |  xlogpos   | dbname 
---------------------+----------+------------+--------
 7414071698640789983 |        1 | 0/2C000148 | 
(1 row)
```

- Смотрим конфиг Barman:
<details><summary>/etc/barman.conf</summary>
    
```
root@barman:~# cat /etc/barman.conf
; Barman, Backup and Recovery Manager for PostgreSQL
; http://www.pgbarman.org/ - http://www.enterprisedb.com/
;
; Main configuration file

[barman]
; System user
barman_user = barman

; Directory of configuration files. Place your sections in separate files with .conf extension
; For example place the 'main' server section in /etc/barman.d/main.conf
configuration_files_directory = /etc/barman.d

; Main directory
barman_home = /var/lib/barman

; Locks directory - default: %(barman_home)s
;barman_lock_directory = /var/run/barman

; Log location
log_file = /var/log/barman/barman.log

; Log level (see https://docs.python.org/3/library/logging.html#levels)
log_level = INFO

; Default compression level: possible values are None (default), bzip2, gzip, pigz, pygzip or pybzip2
compression = gzip
backup_method = rsync
archiver = on

; Pre/post backup hook scripts
;pre_backup_script = env | grep ^BARMAN
;pre_backup_retry_script = env | grep ^BARMAN
;post_backup_retry_script = env | grep ^BARMAN
;post_backup_script = env | grep ^BARMAN

; Pre/post archive hook scripts
;pre_archive_script = env | grep ^BARMAN
;pre_archive_retry_script = env | grep ^BARMAN
;post_archive_retry_script = env | grep ^BARMAN
;post_archive_script = env | grep ^BARMAN

; Pre/post delete scripts
;pre_delete_script = env | grep ^BARMAN
;pre_delete_retry_script = env | grep ^BARMAN
;post_delete_retry_script = env | grep ^BARMAN
;post_delete_script = env | grep ^BARMAN

; Pre/post wal delete scripts
;pre_wal_delete_script = env | grep ^BARMAN
;pre_wal_delete_retry_script = env | grep ^BARMAN
;post_wal_delete_retry_script = env | grep ^BARMAN
;post_wal_delete_script = env | grep ^BARMAN

; Global bandwidth limit in kilobytes per second - default 0 (meaning no limit)
;bandwidth_limit = 4000

; Number of parallel jobs for backup and recovery via rsync (default 1)
parallel_jobs = 1

; Immediate checkpoint for backup command - default false
immediate_checkpoint = true

; Enable network compression for data transfers - default false
;network_compression = false

; Number of retries of data copy during base backup after an error - default 0
basebackup_retry_times = 333

; Number of seconds of wait after a failed copy, before retrying - default 30
;basebackup_retry_sleep = 30

; Maximum execution time, in seconds, per server
; for a barman check command - default 30
;check_timeout = 30

; Time frame that must contain the latest backup date.
; If the latest backup is older than the time frame, barman check
; command will report an error to the user.
; If empty, the latest backup is always considered valid.
; Syntax for this option is: "i (DAYS | WEEKS | MONTHS | HOURS)" where i is an
; integer > 0 which identifies the number of days | weeks | months of
; validity of the latest backup for this check. Also known as 'smelly backup'.
last_backup_maximum_age = 4 DAYS

; Time frame that must contain the latest WAL file
; If the latest WAL file is older than the time frame, barman check
; command will report an error to the user.
; Syntax for this option is: "i (DAYS | WEEKS | MONTHS | HOURS)" where i is an
; integer > 0
;last_wal_maximum_age =

; Minimum number of required backups (redundancy)
minimum_redundancy = 1

; Global retention policy (REDUNDANCY or RECOVERY WINDOW)
; Examples of retention policies
; Retention policy (disabled, default)
; Retention policy (based on redundancy)
; Retention policy (based on recovery window)
retention_policy = REDUNDANCY 3
retention_policy = RECOVERY WINDOW OF 4 WEEKS
```
</details>

- Смотрим /etc/barman.d/master
```
root@barman:~# cat /etc/barman.d/master.conf 
[master]
#Описание задания
description = "backup master"
#Команда подключения к хосту master
ssh_command = ssh postgres@192.168.57.11
#Команда для подключения к postgres-серверу
conninfo = host=192.168.57.11 user=barman port=5432 dbname=postgres
retention_policy_mode = auto
retention_policy = RECOVERY WINDOW OF 7 days
wal_retention_policy = main
streaming_archiver=on
#Указание префикса, который будет использоваться как $PATH на хосте master
#path_prefix = /usr/local/pgsql/bin
#настройки слота
create_slot = auto
slot_name = master
#Команда для потоковой передачи от postgres-сервера
streaming_conninfo = host=192.168.57.11 user=barman
#Тип выполняемого бекапа
backup_method = postgres
archiver = off
```

- На этом настройка бекапа завершена. Теперь проверим работу barman:
```
root@barman:~# barman switch-wal master
The WAL file 000000010000000000000015 has been closed on server 'master'
2024-09-17 08:13:56,024 [69474] barman.server INFO: The WAL file 000000010000000000000015 has been closed on server 'master'
```
```
root@barman:~# barman cron
Starting WAL archiving for server master
```
```
root@barman:~# barman check master
2024-09-17 08:02:07,584 [69352] barman.utils WARNING: Failed opening the requested log file. Using standard error instead.
Server master:
        PostgreSQL: OK
        superuser or standard user with backup privileges: OK
        PostgreSQL streaming: OK
        wal_level: OK
        replication slot: OK
        directories: OK
        retention policy settings: OK
        backup maximum age: FAILED (interval provided: 4 days, latest backup age: No available backups)
        backup minimum size: OK (0 B)
        wal maximum age: OK (no last_wal_maximum_age provided)
        wal size: OK (0 B)
        compression settings: OK
        failed backups: OK (there are 0 failed backups)
        minimum redundancy requirements: FAILED (have 0 backups, expected at least 1)
        pg_basebackup: OK
        pg_basebackup compatible: OK
        pg_basebackup supports tablespaces mapping: OK
        systemid coherence: OK (no system Id stored on disk)
        pg_receivexlog: OK
        pg_receivexlog compatible: OK
        receive-wal running: OK
        archiver errors: OK
```
> Если во всех пунктах, кроме выделенных будет OK, значит бекап отработает корректно. Если в остальных пунктах вы видите FAILED, то бекап у вас не запустится. Требуется посмотреть в логах, в чём может быть проблема...

- После этого запускаем резервную копию: 
```
root@barman:~# barman backup master
Starting backup using postgres method for server master in /var/lib/barman/master/base/20240917T093131
2024-09-17 09:31:31,518 [1710] barman.backup INFO: Starting backup using postgres method for server master in /var/lib/barman/master/base/20240917T093131
Backup start at LSN: 0/240000C8 (000000010000000000000024, 000000C8)
2024-09-17 09:31:31,526 [1710] barman.backup_executor INFO: Backup start at LSN: 0/240000C8 (000000010000000000000024, 000000C8)
Starting backup copy via pg_basebackup for 20240917T093131
2024-09-17 09:31:31,526 [1710] barman.backup_executor INFO: Starting backup copy via pg_basebackup for 20240917T093131
2024-09-17 09:31:31,555 [1710] barman.backup_executor INFO: pg_basebackup: initiating base backup, waiting for checkpoint to complete
2024-09-17 09:31:31,642 [1710] barman.backup_executor INFO: pg_basebackup: checkpoint completed
2024-09-17 09:31:32,321 [1710] barman.backup_executor INFO: NOTICE:  WAL archiving is not enabled; you must ensure that all required WAL segments are copied through other means to complete the backup
2024-09-17 09:31:32,324 [1710] barman.backup_executor INFO: pg_basebackup: syncing data to disk ...
2024-09-17 09:31:32,615 [1710] barman.backup_executor INFO: pg_basebackup: renaming backup_manifest.tmp to backup_manifest
2024-09-17 09:31:32,615 [1710] barman.backup_executor INFO: pg_basebackup: base backup completed
2024-09-17 09:31:32,616 [1710] barman.backup_executor INFO: 
Copy done (time: 1 second)
2024-09-17 09:31:32,617 [1710] barman.backup_executor INFO: Copy done (time: 1 second)
Finalising the backup.
2024-09-17 09:31:32,617 [1710] barman.backup_executor INFO: Finalising the backup.
2024-09-17 09:31:32,629 [1710] barman.postgres INFO: Restore point 'barman_20240917T093131' successfully created
Backup size: 29.4 MiB
2024-09-17 09:31:32,652 [1710] barman.backup INFO: Backup size: 29.4 MiB
Backup end at LSN: 0/26000000 (000000010000000000000025, 00000000)
2024-09-17 09:31:32,652 [1710] barman.backup INFO: Backup end at LSN: 0/26000000 (000000010000000000000025, 00000000)
Backup completed (start time: 2024-09-17 09:31:31.526928, elapsed time: 1 second)
2024-09-17 09:31:32,652 [1710] barman.backup INFO: Backup completed (start time: 2024-09-17 09:31:31.526928, elapsed time: 1 second)
Waiting for the WAL file 000000010000000000000025 from server 'master'
2024-09-17 09:31:32,652 [1710] barman.server INFO: Waiting for the WAL file 000000010000000000000025 from server 'master'
2024-09-17 09:31:32,653 [1710] barman.wal_archiver INFO: Found 2 xlog segments from streaming for master. Archive all segments in one run.
Processing xlog segments from streaming for master
        000000010000000000000024
2024-09-17 09:31:32,653 [1710] barman.wal_archiver INFO: Archiving segment 1 of 2 from streaming: master/000000010000000000000024
        000000010000000000000025
2024-09-17 09:31:32,762 [1710] barman.wal_archiver INFO: Archiving segment 2 of 2 from streaming: master/000000010000000000000025
2024-09-17 09:31:32,854 [1710] barman.wal_archiver INFO: No xlog segments found from streaming for master.
```

### Проверка восстановления из бекапов:

- На хосте master в psql удаляем базы demo:
```
root@master:~# sudo psql -U postgres
psql (16.4 (Ubuntu 16.4-1.pgdg22.04+1))
Type "help" for help.

postgres=# \l
                                                       List of databases
   Name    |  Owner   | Encoding | Locale Provider |   Collate   |    Ctype    | ICU Locale | ICU Rules |   Access privileges   
-----------+----------+----------+-----------------+-------------+-------------+------------+-----------+-----------------------
 demo      | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | 
 postgres  | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | 
 template0 | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | =c/postgres          +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
 template1 | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | =c/postgres          +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
(4 rows)

postgres=# drop database demo;
DROP DATABASE
postgres=# \l
                                                       List of databases
   Name    |  Owner   | Encoding | Locale Provider |   Collate   |    Ctype    | ICU Locale | ICU Rules |   Access privileges   
-----------+----------+----------+-----------------+-------------+-------------+------------+-----------+-----------------------
 postgres  | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | 
 template0 | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | =c/postgres          +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
 template1 | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | =c/postgres          +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
(3 rows)
```

- Далее на хосте barman запустим восстановление: 
```
root@barman:~# barman recover master 20240917T083600 /var/lib/postgresql/16/main --remote-ssh-comman "ssh postgres@192.168.57.11"
2024-09-17 09:49:54,606 [1886] barman.utils WARNING: Failed opening the requested log file. Using standard error instead.
2024-09-17 09:49:54,613 [1886] barman.wal_archiver INFO: No xlog segments found from streaming for master.
The authenticity of host '192.168.57.11 (192.168.57.11)' can't be established.
ED25519 key fingerprint is SHA256:Wzrh93zwh0VpURrHouAs/R+Kg+iSOF84bI0bbHS3MgQ.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
2024-09-17 09:50:17,908 [1886] Command WARNING: Warning: Permanently added '192.168.57.11' (ED25519) to the list of known hosts.
Starting remote restore for server master using backup 20240917T083600
2024-09-17 09:50:18,524 [1886] barman.recovery_executor INFO: Starting remote restore for server master using backup 20240917T083600
Destination directory: /var/lib/postgresql/16/main
2024-09-17 09:50:18,525 [1886] barman.recovery_executor INFO: Destination directory: /var/lib/postgresql/16/main
Remote command: ssh postgres@192.168.57.11
2024-09-17 09:50:18,525 [1886] barman.recovery_executor INFO: Remote command: ssh postgres@192.168.57.11
2024-09-17 09:50:18,679 [1886] barman.recovery_executor WARNING: Unable to retrieve safe horizon time for smart rsync copy: The /var/lib/postgresql/16/main/.barman-recover.info file does not exist
Copying the base backup.
2024-09-17 09:50:18,979 [1886] barman.recovery_executor INFO: Copying the base backup.
2024-09-17 09:50:18,981 [1886] barman.copy_controller INFO: Copy started (safe before None)
2024-09-17 09:50:18,981 [1886] barman.copy_controller INFO: Copy step 1 of 4: [global] analyze PGDATA directory: /var/lib/barman/master/base/20240917T083600/data/
2024-09-17 09:50:19,219 [1886] barman.copy_controller INFO: Copy step 2 of 4: [global] create destination directories and delete unknown files for PGDATA directory: /var/lib/barman/master/base/20240917T083600/data/
2024-09-17 09:50:19,446 [1909] barman.copy_controller INFO: Copy step 3 of 4: [bucket 0] starting copy safe files from PGDATA directory: /var/lib/barman/master/base/20240917T083600/data/
2024-09-17 09:50:19,801 [1909] barman.copy_controller INFO: Copy step 3 of 4: [bucket 0] finished (duration: less than one second) copy safe files from PGDATA directory: /var/lib/barman/master/base/20240917T083600/data/
2024-09-17 09:50:19,803 [1909] barman.copy_controller INFO: Copy step 4 of 4: [bucket 0] starting copy files with checksum from PGDATA directory: /var/lib/barman/master/base/20240917T083600/data/
2024-09-17 09:50:19,999 [1909] barman.copy_controller INFO: Copy step 4 of 4: [bucket 0] finished (duration: less than one second) copy files with checksum from PGDATA directory: /var/lib/barman/master/base/20240917T083600/data/
2024-09-17 09:50:20,000 [1886] barman.copy_controller INFO: Copy finished (safe before None)
Copying required WAL segments.
2024-09-17 09:50:20,513 [1886] barman.recovery_executor INFO: Copying required WAL segments.
2024-09-17 09:50:20,514 [1886] barman.recovery_executor INFO: Starting copy of 15 WAL files 15/15 from WalFileInfo(compression='gzip', name='00000001000000000000001A', size=16466, time=1726551360.9771612) to WalFileInfo(compression='gzip', name='000000010000000000000028', size=16483, time=1726555172.7286253)
2024-09-17 09:50:24,781 [1886] barman.recovery_executor INFO: Finished copying 15 WAL files.
Generating archive status files
2024-09-17 09:50:24,782 [1886] barman.recovery_executor INFO: Generating archive status files
Identify dangerous settings in destination directory.
2024-09-17 09:50:25,284 [1886] barman.recovery_executor INFO: Identify dangerous settings in destination directory.
Recovery completed (start time: 2024-09-17 09:50:18.523656+03:00, elapsed time: 6 seconds)
Your PostgreSQL server has been successfully prepared for recovery!
```

- Далее на хосте master потребуется перезапустить postgresql-сервер и снова проверить список БД. База demo должна вернуться..
```
root@master:~# systemctl status postgresql
● postgresql.service - PostgreSQL RDBMS
     Loaded: loaded (/lib/systemd/system/postgresql.service; enabled; vendor preset: enabled)
     Active: active (exited) since Tue 2024-09-17 09:51:11 MSK; 10s ago
    Process: 65804 ExecStart=/bin/true (code=exited, status=0/SUCCESS)
   Main PID: 65804 (code=exited, status=0/SUCCESS)
        CPU: 3ms

Sep 17 09:51:11 master systemd[1]: Starting PostgreSQL RDBMS...
Sep 17 09:51:11 master systemd[1]: Finished PostgreSQL RDBMS.
root@master:~# sudo psql -U postgres
psql (16.4 (Ubuntu 16.4-1.pgdg22.04+1))
Type "help" for help.

postgres=# \l
                                                       List of databases
   Name    |  Owner   | Encoding | Locale Provider |   Collate   |    Ctype    | ICU Locale | ICU Rules |   Access privileges   
-----------+----------+----------+-----------------+-------------+-------------+------------+-----------+-----------------------
 demo      | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | 
 postgres  | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | 
 template0 | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | =c/postgres          +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
 template1 | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | =c/postgres          +
           |          |          |                 |             |             |            |           | postgres=CTc/postgres
(4 rows)
```
