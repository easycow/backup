#!/bin/bash

# mysql connection
mysqluser=''
mysqlpass=''
mysqlhost=''

# local backup
path=''

# remote connection
scpuser=''
scphost=''
scpport=''
scpkeyfile=''
scppath=''

# retention
days=14

# main
backup=`mysql -u ${mysqluser} -p${mysqlpass} -h ${mysqlhost} -D mysql -N -s -e 'SELECT DISTINCT db FROM db;'`
if [ $? -ne 0 ]; then
  >&2 echo 'gettings dbs for backup failed'
  exit 1
fi

for db in ${backup[@]}; do
  file="mysql_${db}_$(date +%Y%m%d).sql.gz"

  mysqldump -u ${mysqluser} -p${mysqlpass} -h ${mysqlhost} --default-character-set=utf8 ${db} | gzip > ${path}/${file}
  if [ $? -ne 0 ]; then
    >&2 echo "mysqldump for ${db} failed"
    exit 1
  fi

  scp -P ${scpport} -i ${scpkeyfile} ${path}/${file} ${scpuser}@${scphost}:${scppath}/${file}
  if [ $? -ne 0 ]; then
    >&2 echo 'scp failed'
    exit 1
  fi
done

find ${path}/* -mtime +${days} -delete

if [ $? -ne 0 ]; then
  >&2 echo 'clean up old files failed'
  exit 1
fi
