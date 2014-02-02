#!/bin/bash

# Устанавливаем название каталога где будут храниться проекты
echo -e "\033[1mУкажите имя для папки в которой будут располагаться проекты или имя папки которая существует для проектов в вашем домашнем каталоге:\033[0m"; read WORK_DIR
echo -e "\033[1mУкажите название проекта:\033[0m"; read NAME_OF_PROJECT

echo -e "\033[1mCоздаем папки проекта\033[0m"
mkdir -p ~/$WORK_DIR/$NAME_OF_PROJECT/
cd ~/$WORK_DIR/$NAME_OF_PROJECT/
mkdir cgi-bin logs

echo -e "\033[1mСоздаем тестовую страничку в корень проекта\033[0m"
touch ~/$WORK_DIR/$NAME_OF_PROJECT/index.php
echo "<h2>It Works! $NAME_OF_PROJECT</h2><?php phpinfo(); ?>" >> ~/$WORK_DIR/$NAME_OF_PROJECT/index.php
touch ~/$WORK_DIR/$NAME_OF_PROJECT/logs/${NAME_OF_PROJECT}_error.log
touch ~/$WORK_DIR/$NAME_OF_PROJECT/logs/${NAME_OF_PROJECT}_access.log

echo -e "\033[1mсоздаем виртуал хост\033[0m"
virtual_host="
<VirtualHost *:80>
	ServerName $NAME_OF_PROJECT
        ServerAlias www.$NAME_OF_PROJECT
        ServerAdmin admin@$NAME_OF_PROJECT
        DocumentRoot $HOME/$WORK_DIR/$NAME_OF_PROJECT
        <Directory $HOME/$WORK_DIR/$NAME_OF_PROJECT/>
                Options Indexes FollowSymLinks MultiViews Includes
                AllowOverride All
                Order allow,deny
                allow from all
                AddType text/html .html
                AddOutputFilter INCLUDES .html
        </Directory>

        ScriptAlias /cgi-bin/ $HOME/$WORK_DIR/$NAME_OF_PROJECT/cgi-bin/
        <Directory "$HOME/$WORK_DIR/$NAME_OF_PROJECT/cgi-bin">
                AllowOverride All
                Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                Order allow,deny
                Allow from all
        </Directory>

        ErrorLog $HOME/$WORK_DIR/$NAME_OF_PROJECT/logs/${NAME_OF_PROJECT}_error.log
        LogLevel warn
        CustomLog $HOME/$WORK_DIR/$NAME_OF_PROJECT/logs/${NAME_OF_PROJECT}_access.log combined
</VirtualHost>"

host="127.0.0.1 $NAME_OF_PROJECT"

#Добавляем новый хост
sudo sh -c "echo '$host' >> /etc/hosts"
sudo sh -c "touch /etc/apache2/sites-available/$NAME_OF_PROJECT"
sudo sh -c "echo '$virtual_host' >> /etc/apache2/sites-available/$NAME_OF_PROJECT"

#Включаем конфигурацию сайта
sudo a2ensite $NAME_OF_PROJECT

#Создаем БД
echo -e "\033[1mСоздать БД для проекта?(yes/no)\033[0m"
read CREATE_DB

if  [ "$CREATE_DB" = "yes" -o "$CREATE_DB" = "y" -o "$CREATE_BAZA" = "YES" ]; then
	echo -e "\033[1mВведите имя базы данных:\033[0m";
	read DB_NAME
	echo -e "\033[1mВВедите пароль для нового пользователя ${NAME_OF_PROJECT}_user который будет обладать всем правами на вновь созданную базу:\033[0m";
	read -s DB_PASS
	# Создаем базу данных имя которой мы ввели
echo -e "\033[1mТеперь будет необходимо ввести 2 раза пароль root MySQL, если пароля нет, просто нажмите Enter\033[0m";
	mysql -uroot -p --execute="CREATE DATABASE $DB_NAME;"
	# Создаем нового пользователя
	mysql -uroot -p --execute="GRANT ALL PRIVILEGES ON $NAME_OF_PROJECT.* TO ${NAME_OF_PROJECT}_user@localhost IDENTIFIED by '$DB_PASS'  WITH GRANT OPTION;"

 echo -e "\033[1mБаза данных $NAME_OF_PROJECT создана.\033[0m";

else
     echo -e "\033[1mБаза данных не была создана\033[0m";
fi

echo "Reload apache..."
sudo /etc/init.d/apache2 reload
echo -e "\033[1mСоздаем конфигурационный файл проекта\033[0m";
touch ~/$WORK_DIR/$NAME_OF_PROJECT/config.txt
echo -e "Name Project: $NAME_OF_PROJECT\nDB_NAME:$DB_NAME\nDB_USER:${NAME_OF_PROJECT}_user\nDB_PASS:$DB_PASS\nDirectory Project:$HOME/$WORK_DIR/$NAME_OF_PROJECT/" >> ~/$WORK_DIR/$NAME_OF_PROJECT/config.txt
echo "*************************************"
echo -e "\033[1mЛокальный сайт готов к работе.Файл конфигурации находится в $HOME/$WORK_DIR/$NAME_OF_PROJECT/\033[0m"