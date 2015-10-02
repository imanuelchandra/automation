#!/bin/bash
unset PATH

# S3 VARIABLES
S3BUCKET=backup # S3 Bucket name

# LOCATION TO STORE BACKUPS WHILE PROCESSING
BACKUPDIR=/home/deploy/

# APACHE FILES TO BACKUP
DATA=/home/deploy/data

# PATH VARIABLES
MK=/bin/mkdir;
TAR=/bin/tar;
GZ=/bin/gzip;
RM=/bin/rm;
DATE=/bin/date;
FIND=/usr/bin/find;
S3CMD=/usr/bin/s3cmd
SPLIT=/usr/bin/split
LS=/bin/ls

# OTHER VARIABLES
NOW=$($DATE +_%b_%d_%y);
SPLITDIR=$BACKUPDIR$NOW/split

#REMOVE EXISTING BACKUP DIRECTORY
$RM -Rf $BACKUPDIR$NOW

# Create new backup dir
$MK $BACKUPDIR$NOW

#REMOVE EXISTING SPLIT DIRECTORY
$RM -Rf $SPLITDIR

# Create new SPLIT dir
$MK $SPLITDIR

# FILE BACKUP
$TAR -czf $BACKUPDIR$NOW/backup$NOW.tar.gz $DATA --exclude 'media/*' --exclude 'media'

#for i in $($FIND $DATA/* -maxdepth 0 -type d -printf '%f\n'); do
#   $TAR -czf $BACKUPDIR$NOW/data_$i.tar.gz $DATA/$i;
#done

# split file each 1GB
$SPLIT -b1000m $BACKUPDIR$NOW/backup$NOW.tar.gz $SPLITDIR/backup$NOW.tar.gz-

FOLDER=$($DATE +%Y%m%d)
# upload each file split to s3
for split in $($LS $SPLITDIR); do
  $S3CMD put $SPLITDIR/$split s3://$S3BUCKET/backup_$FOLDER/$split
done

# Remove backup directory
$RM -Rf $BACKUPDIR$NOW
