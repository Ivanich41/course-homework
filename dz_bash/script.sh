#!/bin/bash
# Путь к лог-файлу
LOG_FILE="./access.log"

# Проверка на то что скрипт уже запущен
LOCKFILE='/tmp/script.lock'
if [ -e $LOCKFILE ] && kill -0 `cat $LOCKFILE`; then
    echo "Скрипт уже выполняется."
    exit
fi
trap "rm -f $LOCKFILE; exit" INT TERM EXIT
echo $$ > $LOCKFILE

START_DATE=$(head -n1  $LOG_FILE | awk '{print $4}' | cut -d'[' -f2-)
END_DATE=$(tail -n1  $LOG_FILE | awk '{print $4}' | cut -d'[' -f2-)

EMAIL="vagrant@localhost"
SUBJECT="Report"
EMAIL_CONTENT="./email"
# Формирование данных для письма
{
    echo "Отчет за период с $START_DATE до $END_DATE"
    echo 
    echo "Список IP адресов (с наибольшим кол-вом запросов):"
    cat $LOG_FILE | awk '{print $1}'  | sort | uniq -c | sort -nr | head -n 10
    echo
    echo "Список запрашиваемых URL (с наибольшим кол-вом запросов):"
    cat $LOG_FILE | awk '{print $7}' | sort | uniq -c | sort -nr | head -n 10
    echo
    echo "Ошибки веб-сервера/приложения:"
    cat $LOG_FILE | grep ' 50[0-9] '
    echo
    echo "Список всех кодов HTTP ответа:"
    cat $LOG_FILE | awk '{print $9}' | sort | uniq -c | sort -nr
} > $EMAIL_CONTENT

#cat $EMAIL_CONTENT
# Отправка письма
mail -s "$SUBJECT" $EMAIL < $EMAIL_CONTENT

rm -f $LOCKFILE
rm -f $EMAIL_CONTENT