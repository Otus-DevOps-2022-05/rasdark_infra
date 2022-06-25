# rasdark_infra

rasdark Infra repository for OTUS DevOps Learning

# Выполнено ДЗ №4

 - [x] Основное ДЗ
 - [x] Дополнительное ДЗ: скрипт для автодеплоя и запуска приложения после создания инстанса

## В процессе сделано
  - Подготовлены скрипты для установки необходимых компонент ОС
  - Подготовлен скрипт для деплоя приложения

## Реквизиты VM
  testapp_IP = 51.250.86.108
  testapp_port = 9292

## Дополнительное ДЗ
  Создан мета-файл, описывающий необходимые операции по автодеплою: auto_startup.yaml

  Поднятие инстанса производится командой:
  ```
  yc compute instance create --name reddit-app-auto --hostname reddit-app-auto \
  --memory=4 --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 --metadata-from-file user-data=auto_startup.yaml
  ```

# Выполнено ДЗ №3

 - [x] Основное ДЗ
 - [x] Дополнительное ДЗ: алиас для однострочного подключения к внутреннему хосту через бастион
 - [x] Дополнительное ДЗ: замена самоподписанного сертификата для VPN на сертификат выданный LE

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

### Варианты сквозного подключения по ssh
  1. **SSH Agent Forwarding**

Запуск ssh agent'a
```shell
eval `ssh-agent -s`
```
Добавление ключа агенту
```shell
ssh-add <path_to_private_key>
```
Дальнейшие подключения к любым внутренним хостам возможны после подключения к бастион
```shell
ssh -i <path_to_public_key> -A <username>@<bastion_IP>
ssh someinternalhost_IP
```
  2. **ProxyJump**. Демон ssh может "ходить" на внутренние хосты через цепочку "бастионов"
```shell
ssh -i <path_to_public_key> <username>@<bastion_IP>,<username>@bastion2_IP> <username>@someinternalhost_IP
```
  3. **ProxyCommand**. Deprecated. (ssh version < 7.4). Необходимо "форвардить" как минимум хост-порт для передачи параметров прокси.
```shell
ssh <username>@<someinternalhost_IP> -o "proxycommand ssh -W %h:%p -i <path_to_public_key> sername@<bastion_IP"
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
### Замена самоподписанного сертификата для панели управления Pritunl

  Используя сервис sslip.io, заходим на нашу панель управления по адресу:  [https://<bastion_IP>.sslip.io](https://51.250.88.111.sslip.io/)

  Логинимся, заходим в настройки, в LE Domain вводим имя хоста (всё что после https://)). Сохраняем.

  Идём по ssh на bastion. Рестартуем сервис pritunl.

  Возвращаемся в браузер. Проверяем.
