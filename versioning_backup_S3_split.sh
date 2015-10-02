#!/bin/bash
unset PATH

# S3 VARIABLES
S3BUCKET=downy-bucket # S3 Bucket name

# LOCATION TO STORE BACKUPS WHILE PROCESSING
BACKUPDIR=/home/deploy/backup

# FILES TO BACKUP
APPDATA=/home/deploy/downy

# PATH VARIABLES
MK=/bin/mkdir;
TAR=/bin/tar;
GZ=/bin/gzip;
RM=/bin/rm;
FIND=/usr/bin/find;
DATE=/bin/date;
S3CMD=/usr/bin/s3cmd
MYSQLDUMP=/usr/bin/mysqldump 

# OTHER VARIABLES
NOW=$($DATE +%d%m%y);

# MYSQL CREDENTIAL
SQLROOTPASS='63R5W~8Ej&,!_85'
SQLDB=downy_pro

# FILE BACKUP APPDATA
$TAR czvf $BACKUPDIR/application_backup_$NOW.tar.gz $APPDATA

# FILE BACKUP MYSQLDATA
$MYSQLDUMP -uroot -p$SQLROOTPASS $SQLDB | $GZ > $BACKUPDIR/mysql_backup_$NOW.sql.gz

# UPLOAD APPDATA TO S3
$S3CMD put $BACKUPDIR/application_backup_$NOW.tar.gz s3://$S3BUCKET/application_backup_$NOW.tar.gz

# UPLOAD MYSQLDATA TO S3
$S3CMD put $BACKUPDIR/mysql_backup_$NOW.sql.gz s3://$S3BUCKET/mysql_backup_$NOW.sql.gz

# FIND BACKUPDATA AND DELETE
$FIND $BACKUPDIR -type f -name '*.gz' -mtime 1 -exec $RM {} \;
