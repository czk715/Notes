#!/bin/sh

NICE="/bin/nice"
RSYNC="/usr/bin/rsync"
DATE="/bin/date"
SSH="/usr/bin/ssh"
USER="webrsync"
LOG="/usr/bin/logger -i -p local1.debug"  # => /var/www/scripts/rsync/logs/rsync.log
DESTSERVERS="web1.local web2.local"
SRCDIR="/var/www/staging"
DSTDIR="/var/www"
EXCLUDE="/var/www/scripts/rsync/rsync.exclude"
LOCK="/var/www/scripts/rsync/lock/rsync.lock"

if [ -f ${LOCK} ]; then
    echo 'excuting.....'
else

    touch ${LOCK}

    echo "===== ${SRCDIR} to ${DSTDIR}" | ${LOG}

    for DESTSERVER in ${DESTSERVERS}
    do
        echo "-----[$$]Start Date: `${DATE}` to ${DESTSERVER}" | ${LOG}
#        ${NICE} -n -19 ${RSYNC} -e ${SSH} -avz --dry-run --exclude-from=${EXCLUDE} ${SRCDIR}/ ${USER}@${DESTSERVER}:${DSTDIR} 2>&1 | ${LOG}
        ${NICE} -n -19 ${RSYNC} -e ${SSH} -avz --delete --exclude-from=${EXCLUDE} ${SRCDIR}/ ${USER}@${DESTSERVER}:${DSTDIR} 2>&1 | ${LOG}
        echo "-----[$$]End Date  : `${DATE}`" | ${LOG}
        echo "" | ${LOG}
        echo "" | ${LOG}
        echo "" | ${LOG}
    done

    rm ${LOCK}

fi
