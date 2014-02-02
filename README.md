Create Virtual Host
================

В консольке добавить www-data в группу домашнего пользователя:
```bash
sudo usermod -a -G имя_пользователя www-data
```

проверим наличие пользователя:
```bash
groups www-data
```
Запуск скрипта. Заходим в папку со скриптом, делаем его исполняемым:
```bash
chmod +x ubuntu.sh
```

запускаем:
```bash
. ubuntu.sh
```
