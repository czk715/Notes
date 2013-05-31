#!/bin/sh

cd /var/www/staging
find app html -user beaunet ! -group web -exec chgrp -R web {} \;
find app html -user beaunet -type f -exec chmod 664 {} \;
find app html -user beaunet -type d -exec chmod 775 {} \;

sudo /var/www/scripts/rsync/rsync.sh

echo "staging, web1, web2  setup ok"
exit 0
