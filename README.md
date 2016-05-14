Generic scripts for performing backups on linux based machines

= Requirements =
rsync

= backup.sh =
Backup files to a remote via ssh. To save time, bandwidth and disk space this script makes use of rsync. Only changed files are transmitted. This is a very convenient and easy way to create snapshots.

= backup_mysql.sh =
Backup all mysql databases as sql dumps and copy them over via ssh to a remote location