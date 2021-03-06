# rasdark_infra

rasdark Infra repository for OTUS DevOps Learning

# Выполнено ДЗ №10

 - [x] Основное ДЗ
 - [x] Дополнительное ДЗ: провижен nginx в локальном vagrant окружении
 - [x] Дополнительное ДЗ: вынос роли db во внешний репозиторий

## В процессе сделано
 - Установка, изучение vagrant
 - Установка, настройка libvirt + тестовый vagrantfile для libvirt
 - Доработка ansible-ролей для работы с локальным окружением в vagrant
 - Провижинг локального vagrant окружения с использованием ansible
 - Провижинг nginx (для проксирования запросов к reddit app)
 - Тестирование роли: molecule + testinfra
 - Модификация шаблонов packer
 - Вынос роли db во внешний репозиторий

## Vagrant
  Всё штатно, без каких-либо проблем, но в этой домашке я не искал "лёгких" путей =)

### Подводные камни
  Так как для личных и рабочих нужд я использую в качестве основной ОС Linux, со "свежим",
  стабильным ядром (на текущий момент 5.18.12), а VirtualBox не имеет ["поддержки" оного](https://www.virtualbox.org/ticket/20914)
  Я принял решение в качестве vagrant-провайдера использовать libvirt.

  В ДЗ использовась standalone версия vagrant'a (бинарник).
  Для запуска которого требуется загруженный модуль ядра **fuse**.

  Штатными средствами ОС установим libvirt. В подавляющем большинстве случаев его дополнительно
  настраивать не нужно.

  Установим vagrant-плагин для работы с libvirt
  ```
  vagrant plugin install vagrant-libvirt
  ```

  Так как box "ubuntu/xenial64" не умеет в libvirt есть 3 пути:
  1. Использовать другой box, например "generic/ubuntu1604"
  2. Используя плагин vagrant-mutate сконвертировать любой box собранный для virtualbox провайдера.
  3. Собрать собственный box =)

  В домашке я не буду рассматривать все 3 пути, хотя я их прошёл, буду использовать 1й вариант.

# Molecule
  Для подключения делегированного провайдера vagrant для molecule требуется установить прежде всего
  **molecule-vagrant**
  ```
  pip install molecule-vagrant
  ```

  Таким образом, команда для инициализации default сценария видоизменяется до:
  ```
  molecule init scenario -r db -d vagrant --verifier-name testinfra default
  ```

  Модуль **testinfra** считается deprecated, рекомендовано использовать **pytest-testinfra**

  Для converge стадии molecule создаётся файл converge.yml, а не playbook.yml как в ДЗ =)


# Выполнено ДЗ №10

 - [x] Основное ДЗ
 - [x] Дополнительное ДЗ: Использование динамического инвентори

## В процессе сделано
 - Созданы роли app и db
 - Созданы "окружения" prod/stage со своими inventory и vars
 - Использование "внешний" роли из ansible-galaxy
 - Использование ansible vault
 - Динамический инвентори

## Динамический инвентори

Вариантов может быть несколько. В данной ДЗ используется вариант, когда терраформ генерирует
inventory и "фиксит" значение переменной с адресом db =)

Так же, рассматривался вариант с генерацией inventory.json и передачей mongo_ip через hostvars.

В варианте с использованием yc_compute не пришло "озарения" как "штатно" передать в hostvars что-то
кроме ansible_hosts.


# Выполнено ДЗ №9

 - [x] Основное ДЗ
 - [x] Дополнительное ДЗ: Динамический инвентори Yandex.Cloud из PR ansible =)

## В процессе сделано
 - Плейбук для деплоя приложухи "всё-в-куче"
 - Плейбук для деплоя по типу "один-плейбук-много-сценариев"
 - Несколько плейбуков + импорт "шагов" в одном
 - yc_compute плагин для динамического инвентори
 - новые пакер образы с провиженом от ansible


## Динамический инвентори
  Можно держать плагины в директории с проектом, или по стандартным путям поиска плагинов.
  Определяем путь где ansible будет искать inventory плагин в первую очередь:
  ```
  ansible-config dump | grep INVENTORY_PLUGIN_PATH
  ```
  Находим там путь в домашней папке пользователя, создаем папку, копируем сам плагин в папку:
  ```
  mkdir -p ~/.ansible/plugins/inventory && cd $_
  wget https://raw.githubusercontent.com/st8f/ansible/324dac4f674ff845bab5081f3fce18c31f1b25ca/lib/ansible/plugins/inventory/yc_compute.py
  ```
  Плагин зависит от Python-модуля yandexcloud. Установим его.
  ```
  pip install --user yandexcloud
  ```
  Проверяем, что с плагином всё норм:
  ```
  ansible-doc -t inventory yc_compute
  ```

  Правим ansible.cfg на тему нового inventory плагина yc_compute и имени инвентори файла, имя
  которого должно оканчиваться, например, на yc.yml.

  Создаем конфиг inventory_yc.yml (в коммите пример).
  Чтобы спрятать креды создаем переменную окружения: YC_ANSIBLE_OAUTH_TOKEN
  Подставляем в неё токен из:
  ```
  yc config list
  ```

  Используя функционал keyed_groups раскидываем обнаруженные плагином хосты по группам согласно
  меткам, которые мы указывали в терраформе ещё =)

  Проверяем, что плагин работает, конфиг верный, инвентори "наполяется":
  ```
  ansible-inventory --graph
  ```

  Все. Можно работать =)



# Выполнено ДЗ №8

 - [x] Основное ДЗ
 - [x] Дополнительное ДЗ: Динамический инвентори формата JSON

## В процессе сделано
 - Установка ansible была не нужна, он уже давно установлен =)
 - pip тоже давно был устатовновлен
 - Создание обычного inventory и ansible.cfg для подключения к инстансам app и db
 - Всякие исследования работы ansbile и модулями ping, command, shell
 - Написание inventory.yml
 - Создание первого плейбука для клнинирования репозитория reddit в папку /home/appuser инстанса app
 -

### Комментарии по ДЗ
  В ДЗ был вопрос: что изменилось и почему после выполнения
  ```
  ansible app -m command -a 'rm -rf ~/reddit'
  ```
  и прогона плейбука clone.

  **Ответ**: согласно конфига, ansible подключается к хостам от пользователя ubuntu, в то время как
  в плейбуке клонирование происходит в домашнюю папку пользователя appuser. По-этому, удаление
  reddit из домашней папки пользователя ubuntu ничего не удалит, так как этой папки там нет :)
  А прогон плейбука ничего не изменит, так как в /home/appuser репозиторий уже склонирован =)

### Динамический инвентори в JSON
  Во-первых, конвертация инвентори в json формат это просто:
  ```
  ansible-inventory -i inventory --list > inventory.json
  ```

  Во-вторых, ход решения задачи в лоб с созданием скрипта.
  Необходимо распарсить вывод команды:
  ```
  yc compute instances
  ```
  И сформировать inventory.

  После этого, запустить конвертацию inventory в json формат.
  Всё это завернуть в скрипт. Пример в ansible/gen_inventory_v1.sh
  И вызывать.. тераформом как local провижен.

  В-третьих, прям в баш скрипте, можно генерировать inventory) Без всяких сложных парсингов.
  Пример в ansible/inventory2.json
  Вызывать так (как local провижен для терраформа):
  ```
  ./inventory2.json --gen > inventory.json
  ```

  В-четвёртых, можно генерировать инвентори терраформом с помощью функции templatefile(). Пример в
  коммите.
  P.S.: да, я знаю, что можно генерить сразу inventory.json)



# Выполнено ДЗ №7

 - [x] Основное ДЗ
 - [x] Дополнительное ДЗ: Хранение стейтов в Yandex Object Storage
 - [x] Дополнительное ДЗ: Провижин экземпляров приложения и БД + отключение провижина по переменной

## В процессе сделано
  - Вынесение настройки сети и подсети в Y.Cloud в виде ресурса
  - Подготовка конфигов packer для app и db инстансов
  - Разбивка main.tf на "части" + лень-матушка подсказала идею не держать ID диска в переменных, а вычислять его с помощью data ресурса :)
  - Разделение проекта на prod и stage (проверено, запускается)
  - Добавление суффикса к имени инстансов согласно окружения :)

## Хранение стейтов в Yandex S3
  Сперва необходимо создать бакет (storage-bucket.tf). Тут прекрасно работают переменные.
  После этого необходимо добавить backend.tf в проект каждого окружения.

  Комментарий: в backend.tf НЕ РАБОТАЮТ переменные (на этапе инициализации terraform переменных ещё
  нет), поэтому соответствующие настройки, секреты необходимо указывать прямо в файле...

  После добавления backend, необходимо удалить .terraform и запустить
  ```
  terraform init
  ```
  И всё. Можно использовать :)

## Провижин экземпляров приложения и БД
  По аналогии с предыдущим ДЗ создаём в модулях app и db папку files.
  Для модуля app укладываем туда конфиг puma.service и deploy.sh
  Для модуля db необходимо взять базовый конфиг монги (можно выдернуть из прошлых заданий), положить
  его в files, а так же создать простой скрипт deploy.sh (который уложит на целевом хосте этот
  конфиг на "место")

  Но! Конфиги - это шаблоны, в которые можно подставлять значения из переменных.
  Поэтому, в конфиг puma.service через Environment=DATABASE_URL= передаем переменную (позже
  наполним) где будет содержаться "внутренний" адрес монги.

  В конфиг монги необходимо так же передать внутренний адрес монги.

  Далее, в main.cf добавить 2 провижена: file (который закинет на целевую систему отрендеренный
  шаблон конфига) и remote-exec (для запуска deploy.sh)

  Главное, не забыть указать в output к модулю db переменную с адресом :)
  И в main.cf модуля app добавить эту переменную.

### Отключение провижинов в зависимости от значения переменной
  Для реализации подходит null ресурс и простая логика:
  ```
  resource "null_resource" "instance" {
  count = var.enable_provision ? 1 : 0
  triggers = {
    cluster_instance_ids = yandex_compute_instance.app.id
  }
  ```
  Нужно добавить этот блок для модулей app/db, и вынести в этот блок сами провижены.

  После этого обязательно добавить переменную как в модули, так и в стейджи.

  Переинициализировать terraform (добавился новый ресурс null)

  И можно пробовать :) Например, деплой и запуск инстансов без провижена:
  ```
  cd prod && terraform apply -var='enable_provision=false'
  ```


# Выполнено ДЗ №6

 - [x] Основное ДЗ
 - [x] Дополнительное ДЗ: load balancer
 - [x] Дополнительное ДЗ: динамическое создание эземпляров приложения с балансировкой

## В процессе сделано
  - Установка древней версии terraform (0.12.31) из zip-архива
  - Подготовка .gitignore для игнорирования tfstate, tfvars...
  - Создание сервисного аккаунта terraform и предоставление ему доступа
  - Создание базового конфига main.tf (с доп.опцией получение id загрузочного диска из ресурса)
  - Конфигурация сервисного аккаунта через переменные окружения: TF_VAR_имя=...
  - Конфигурация провижинов для деплоя приложения
  - Вынос конфигурационной части в переменные
  - Добавлен load balancer, с включением хоста в группу
  - Добавлено динамическое создание экземпляров приложения (TF_VAR_instance_count регулирует число экземпляров


## Запуск
  ```
  terraform apply
  ```

## Проверка
  ```
  curl http://<внешний адрес экземпляра>:9292
  curl http://<анешний адрес балансера>
  ```


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
