#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

bail_on_root
bail_on_missing_yay

yay -S --noconfirm \
intellij-idea-ultimate-edition \
php \
composer \
ruby \
sonar-scanner \
postgresql \
xdebug

curl -L https://phar.phpunit.de/phpunit.phar --output /tmp/phpunit.phar
sudo mv /tmp/phpunit.phar /usr/bin/phpunit
sudo chmod +x /usr/bin/phpunit

if [ -f /etc/php/conf.d/xdebug.ini ]; then
    sudo sed -i -- "s/^;zend_extension=xdebug.so/zend_extension=xdebug.so/g" /etc/php/conf.d/xdebug.ini
fi


#
## Installation
#
#```
#yay -S ruby rubygems v8
## add '/home/re/.gem/ruby/2.6.0/bin' to PATH
#docker-compose build
##docker-compose run web gem install rails
##docker-compose run web gem install 'dotenv-rails'
##docker-compose run web gem install execjs
##docker-compose run web gem install bundler
##docker-compose run web bundle install
##docker-compose run web bundle update --bundler
#docker-compose run web rails db:create db:migrate <--- Fehler: Findet den DB-Server nicht
#docker-compose up
#```
#
#```
#curl -sSL https://get.rvm.io | bash -s stable
#rvm install "ruby-2.5.3"
#sudo yay -S postgresql
#sudo mkdir -p /var/lib/postgres/data /run/postgresql
#sudo touch /var/lib/postgres/log
#sudo chown -R postgres:postgres /var/lib/postgres/data /var/lib/postgres/log
#sudo chown -R root:root /run/postgresql
#sudo -iu postgres # then:
#initdb -D /var/lib/postgres/data # then:
#pg_ctl -D /var/lib/postgres/data -l /var/lib/postgres/log start # then:
#
#psql
#> CREATE DATABASE esndev;
#
#> CREATE USER re WITH ENCRYPTED PASSWORD 're';
#> ALTER USER re CREATEDB;
#> GRANT ALL PRIVILEGES ON DATABASE esndev TO re;
#
#> CREATE USER esndev WITH ENCRYPTED PASSWORD 'esndev';
#> ALTER USER esndev CREATEDB;
#> GRANT ALL PRIVILEGES ON DATABASE esndev TO esndev;
#> exit
#exit
#sudo systemctl start postgresql # evtl. auch schon früher
#gem install rails
#gem install 'dotenv-rails'
#gem install bundler
#bundle update --bundler
#rails db:create db:migrate
#rails server
#
#```
#
## Sonar-Scanner
#
#
#
#```
#yay -S sonar-scanner
## add to ~/.bashrc or ~/.profile:
#export SONAR_SCANNER_HOME="/opt/sonar-scanner"
#export PATH="${PATH}:${SONAR_SCANNER_HOME}/bin"
## set sonar.host.url=https://sonar.dev.eon.com:9000 in /etc/sonar-scanner/sonar-scanner.properties
#
#```
#
## Links
#
#- https://www.postgresqltutorial.com/postgresql-list-users/
#- https://bundler.io/v2.0/guides/bundler_docker_guide.html
#- https://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner