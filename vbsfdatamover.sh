#!/bin/bash

# Move PostgreSQL 13 data folder to /veeamdata
# ============================================

# Manual verification of PostgreSQL data_directory
#
# sudo -u postgres psql
#
# SHOW data_directory;
#
#     data_directory
# ------------------------
# /var/lib/pgsql/13/data
# (1 row)
#
#
# /q

# The script assumes you are going to move the PostgreSQL data directory to /veeamdata 

# Stop PostgreSQL

systemctl stop postgresql-13

# Wait for 5 seconds

sleep 5

# Move '/var/lib/pgsql/' folder to '/veeamdata'

sudo mv /var/lib/pgsql /veeamdata

# Update the 'postgresql.conf' and 'postgresql-13.service' files with new path

sed -i "s/#data_directory = 'ConfigDir'/data_directory = '\/veeamdata\/pgsql\/13\/data'/g" /veeamdata/pgsql/13/data/postgresql.conf

sed -i "s/Environment=PGDATA=\/var\/lib/Environment=PGDATA=\/veeamdata/g" /usr/lib/systemd/system/postgresql-13.service

# If sed fails:
#
# sudo nano /veeamdata/pgsql/13/data/postgresql.conf
#
# >> data_directory = '/veeamdata/pgsql/13/data'    # use data in another directory
#
# sudo nano /usr/lib/systemd/system/postgresql-13.service
# 
# >> Environment=PGDATA=/veeamdata/pgsql/13/data/

# Restart PostgreSQL

systemctl daemon-reload

systemctl start postgresql-13


# Manual verification of PostgreSQL databases
#
# systemctl status postgresql-13
#
# sudo -u postgres psql
#
# SELECT oid as object_id, datname as database_name FROM pg_database;
#
# object_id | database_name
# -----------+---------------
#     13436 | postgres
#     16385 | veeam
#         1 | template1
#     13435 | template0
#     17369 | veeam_data
# (5 rows)


# Move VBSF folder to /veeamdata
# ==============================

# Stop relevant services

systemctl stop veeam-updater.service 
systemctl stop nginx.service
systemctl stop vbsf-restore.service
systemctl stop vbsf-backend.service

# Wait for 5 seconds

sleep 5

# Move '/opt/vbsf' folder to '/veeamdata'

sudo mv /opt/vbsf /veeamdata

ln -s  /veeamdata/vbsf /opt/vbsf


# Start relevant services

systemctl start vbsf-backend.service
systemctl start vbsf-restore.service
systemctl start nginx.service
systemctl start veeam-updater.service 
