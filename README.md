# rasdark_infra

rasdark Infra repository for OTUS DevOps Learning

## HomeWork №3 (cloud-bastion)

[x] Основное ДЗ
[x] Дополнительное ДЗ: алиас для однострочного подключения к внутреннему хосту через бастион
[x] Дополнительное ДЗ: замена самоподписанного сертификата для VPN на сертификат выданный LE

## В процессе сделано
  - Создание и подключение платёжного аккаунта к облаку cloud-otus в Yandex Cloud
  - Создание пары rsa ключей (для ssh) для подключения к инстансам VM
  - Создание инстансов VM из веб-интерфейса Yandex Cloud
  - Подключение по ssh через бастион-хост
  - Разворачивание сервиса VPN для безопасного подключения к инфраструктуре
  - Настройка ssl сертификатов для VPN

## Реквизиты VM
  bastion_IP = 51.250.88.111
  someinternalhost_IP = 10.128.0.30

## Подключение по ssh
### Подключение с нестандартным ключем
```
ssh -i <path_to_public_key> <username>@<bastion_IP>
```
### Варианты сквозного подключения по ssh
  1. SSH Agent Forwarding
    - Запуск ssh agent'a
      ```
      eval `ssh-agent -s`
      ```
    - Добавление ключа агенту
      ```
      ssh-add <path_to_private_key>
      ```
    - Дальнейшие подключения к любым внутренним хостам возможны после подключения к бастион
      ```
      ssh -i <path_to_public_key> -A <username>@<bastion_IP>
      ssh someinternalhost_IP
      ```
  2. ProxyJump. Демон ssh может "ходить" на внутренние хосты через цепочку "бастионов"
    ```
    ssh -i <path_to_public_key> <username>@<bastion_IP>,<username>@bastion2_IP> <username>@someinternalhost_IP
    ```
  3. ProxyCommand. Deprecated. (ssh version < 7.4). Но, необходимо "форвардить" как минимум хост-порт для передачи параметров прокси.
    ```
    ssh <username>@<someinternalhost_IP> -o "proxycommand ssh -W %h:%p -i <path_to_public_key> username@<bastion_IP"
    ```

### Подключение через бастион-хост с использованием алиаса
  Создать (отредактировать) файл ~/.ssh/config в котором указать следующее:

  ```
Host someinternalhost
    Hostname 10.128.0.30
    User appuser
    ForwardAgent yes
    ProxyJump appuser@51.250.88.111
  ```

## Установка и настройка vpn сервера
  Следуем инструкции к ДЗ. В процессе сталкиваемся с проблемами.

### Проблемы при установки VPN
  1. Не скачивается mongodb (санкции).
    Решение: завернуть все адреса хоста repo.mongodb.org через "свой" vpn.
    Например, через wireguard. Для этого необходимо создать подключение к vpn-серверу и добавить
    маршруты.
  2. После установки и настройки pritun1, запуска vpn-сервера - нет доступа к внутренней сети.
    Решение: добавить маршрут к внутренней сети в настройках vpn-сервера.

### Замена самоподписанного сертификата для панели управления Pritunl

  Используя сервис sslip.io, заходим на нашу панель управления по адресу:
  https://<external_bastion_ip>.sslip.io

  Логинимся, заходим в настройки, в LE Domain вводим имя хоста (всё что после https://)). Сохраняем.

  Идём по ssh на bastion. Рестартуем сервис pritunl.

  Возвращаемся в браузер. Проверяем. Готово :)
