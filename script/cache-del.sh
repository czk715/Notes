#!/bin/sh

sudo rm -rf /var/www/app/webapp/cache/_var*
sudo rm -rf /var/www/app/webapp/cache/config*
sudo rm -rf /var/www/app/webapp/cache/modules*
sudo rm -rf /var/www/app/webapp/cache/smarty/cache/_var*
sudo rm -rf /var/www/app/webapp/cache/smarty/templates_c/_var*

echo cache clear completed!
