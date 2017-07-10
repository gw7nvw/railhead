#!/bin/bash
RAILS_ENV=production rake assets:clean assets:precompile
sudo rm -r /var/www/html/railhead/*
sudo cp -r /home/mbriggs/rails_projects/railhead/* /var/www/html/railhead/
sudo chmod a+rw /var/www/html/railhead/log/*
sudo service apache2 restart
sudo /etc/rc.local
