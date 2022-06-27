# rasdark_infra

rasdark Infra repository for OTUS DevOps Learning

# Выполнено ДЗ №5

 - [x] Основное ДЗ: Сборка packer'ом с вынесением секретов в variables
 - [x] Дополнительное ДЗ: Построение bake-образа
 - [x] Дополнительное ДЗ: Автоматизация создания ВМ из bake-образа

## В процессе сделано
 - Установка packer
 - Создание сервисного аккаунта, предоставление доступов в FOLDER, создание секретов (Ya.Clod)
 - Подготовка шаблона, скриптов для будущего образа (fry)
 - Создание образа

## Как запустить
 - Скопировать packer/variables.json.example в packer/variables.json
 - Отредактировать packer/variables.json
 - Выполнить последовательность команд:
 ```
 cd packer
 packer validate -var-file=variables.json ubuntu16.json
 packer build -var-file=variables.json ubuntu16.json
 ```

## Построение bake-образа

Строим образ на базе созданного ранее базового образа. Для этого в качестве образа источника
указываем reddit-base, так же необходимо указать id папки (по совместительнову это FOLDER_ID) в
которой хранится базовый образ.

В провижен необходимо добавить шаги, необходимые для того чтобы установить и настроить приложение.

После редактирования файла с переменными и шаблона immutable.json можно "запекать" образ.

 ```
 cd packer
 packer validate -var-file=variables.json immutable.json
 packer build -var-file=variables.json immutable.json
 ```

Проверяем получившиеся образы (должно быть 2):
```
yc compute image list
```

## Автоматизация создания ВМ

Прежде чем начать создавать ВМ, необходимо определиться с сетями. Или завести новые:

Выдираем из вывода следующей команды ID новой сети:
```
yc vpc network create --name reddit-test
```

Подставляем в --network-id следующей команды:
```
yc vpc subnet create --name central-a --description "For test reddit-app deploy" \
--folder-id b1gqpofo13bvldc6bvi4 --network-id enp3m070r365cvbuf8fd  \
--zone ru-central1-a --range 10.61.0.0/24
```

Создаём ВМ, не забывая указать image-family к параметрам загрузочного диска и subnet-name к
параметрам сети:
```
yc compute instance create --name reddit-app --memory=4 \
--create-boot-disk name=reddit-full,size=12,image-family=reddit-full \
--network-interface subnet-name=central-a,nat-ip-version=ipv4 \
--metadata serial-port-enable=1 --ssh-key ~/.ssh/appuser.pub
```

Подглядываем внешний IP адрес и проверяем работу подключившись по ссш от имени yc-user
```
eval `ssh-agent -s`
ssh -i ~/.ssh/appuser yc-user@<IP>
```

## Дополнительное ДЗ



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
