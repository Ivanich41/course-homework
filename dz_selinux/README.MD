# Домашняя работа по занятию "SELinux"
Описание домашнего задания:
Что нужно сделать?

1. Запустить nginx на нестандартном порту 3-мя разными способами:
- переключатели setsebool;
- добавление нестандартного порта в имеющийся тип;
- формирование и установка модуля SELinux.
К сдаче:
README с описанием каждого решения (скриншоты и демонстрация приветствуются).

2. Обеспечить работоспособность приложения при включенном selinux.
- развернуть приложенный стенд https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems;
- выяснить причину неработоспособности механизма обновления зоны (см. README);
- предложить решение (или решения) для данной проблемы;
- выбрать одно из решений для реализации, предварительно обосновав выбор;
- реализовать выбранное решение и продемонстрировать его работоспособность.

К сдаче:
README с анализом причины неработоспособности, возможными способами решения и обоснованием выбора одного из них;
исправленный стенд или демонстрация работоспособной системы скриншотами и описанием.

---
## Часть 1 (nginx)
После страта ВМ nginx ожидаемо не запустился 

![1](./images/1.png)

Проверка Firewalld, синтаксиса nginx и статуса SELinux

![2](./images/2.png)

Просмотр лога аудита на предмет ошибки nginx 

![3](./images/3.png)

#### Метод 1 

Запуск nginx после переключения nis_enabled 

![4](./images/4.png)

#### Метод 2 

Запуск nginx после добавления порта в тип для http соединений 

![5](./images/5.png)

#### Метод 3 

Запуск nginx после установки модуля SElinux 

![6](./images/6.png)

## Часть 2 (траблшутинг DNS)

Первая попытка внесения изменения в зону c с ошибкой 

![7](./images/7.png)

Ошибки на клиенте не обнаружены, на сервере обнаружен неправильный контекст безопасности SELinux

![8](./images/8.png)

Меняем контекст безопансости наа `named_zone_t`, так как конфигурационые файлы расположены в другом месте 

![9](./images/9.png)

Теперь изменяем зону NS успешно 

![9_1](./images/9_1.png)

Возвращение дефолтного контекста для каталога 

![10](./images/10.png)



