## Until it is set up in teamcity (which requires merge to master)
## build the container with:
./teamcity-build.sh

docker network create pg_nw
docker volume create db_data
docker volume create barman_data
docker volume create barman_restore

docker run --rm -d \
       --name db \
       --network pg_nw \
       -p 5435:5432 \
       -v db_data:/pgdata \
       docker.montagu.dide.ic.ac.uk:5000/montagu-db:i1333
docker exec db montagu-wait.sh

## This will fit pretty happily into the general deployment approach
## that we have.  This, in addition to setting barman's password, also
## creates the replication slot on the server if it is not there
## already.
docker exec db enable-replication.sh changeme changeme

## Restore the db - this takes *ages* unfortunately, particularly on
## docker cp db.dump db:/db.dump
## docker exec db restore-dump.sh /db.dump
## docker exec rm /db.dump

## Or, put at least one transaction worth of data in:
docker exec -it db psql -w -U vimc -d montagu -c 'CREATE TABLE foo (bar INTEGER)'
docker exec -it db psql -w -U vimc -d montagu -c 'INSERT INTO foo VALUES (1);'

docker run -d --rm \
       --name barman_container \
       --network pg_nw \
       -v barman_data:/var/lib/barman \
       -v barman_restore:/restore \
       docker.montagu.dide.ic.ac.uk:5000/montagu-barman:i1333

docker exec barman_container setup-barman
docker exec barman_container barman list-backup all
docker exec barman_container restore-last

## Then try and use the instance:
docker run --rm -d \
       --name db_recovered \
       -v barman_restore:/pgdata \
       docker.montagu.dide.ic.ac.uk:5000/montagu-db:i1333
docker exec db_recovered montagu-wait.sh
docker exec -it db_recovered \
       psql -U vimc -d montagu -c \
       "\dt"

## Again, but without the server running:
docker stop db
docker stop db_recovered
docker exec barman_container wipe-restore
docker stop barman_container

docker run --rm \
       --entrypoint restore-last-no-server \
       -v barman_data:/var/lib/barman \
       -v barman_restore:/restore \
       docker.montagu.dide.ic.ac.uk:5000/montagu-barman:i1333

docker run --rm -d \
       --name db_recovered \
       -v barman_restore:/pgdata \
       docker.montagu.dide.ic.ac.uk:5000/montagu-db:i1333
docker exec db_recovered montagu-wait.sh
docker exec -it db_recovered \
       psql -U vimc -d montagu -c \
       "\dt"
docker stop db_recovered