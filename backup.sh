#!/bin/bash

# write timestamp file
echo $(date +%Y-%m-%d\ %H:%M:%S) > /backup.ts

# specify rotation
rot=9

scpuser=''
scphost=''
scpport=''
scpkeyfile=''
scppath=$(hostname --fqdn)

backup=(
  /backup.ts
  /etc
  /home
  /var/spool/cron/crontabs
  /var/log/
)
exclude=(
  /srv/dummy
)

# build rotation commands
for (( i=${rot}; i>=0; i-- ))
do
  rot_cmd+=("mkdir -p ${scppath}.${i}; mv ${scppath}.${i} ${scppath}.$((i+1));")

  if [ ${i} -eq 0 ]; then
    rot_cmd+=("mv ${scppath}.$((rot+1)) ${scppath}.0")
  fi
done

# execute rotation commands on remote machine
ssh -T -p ${scpport} -i ${scpkeyfile} ${scpuser}@${scphost} ${rot_cmd[*]}

if [ $? -ne 0 ]; then
  >&2 echo 'error: rotating directories failed!'
fi

# sync current data
rsync -Raze "ssh -p ${scpport} -i ${scpkeyfile}" \
  --delete \
  --copy-links \
  --link-dest=../${scppath}.1 \
  --exclude ${exclude[*]} ${backup[*]} ${scpuser}@${scphost}:${scppath}.0

if [ $? -ne 0 ]; then
  >&2 echo 'error: rsync command failed!'
fi
