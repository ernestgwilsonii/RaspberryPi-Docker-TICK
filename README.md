# RaspberryPi-Docker-tick
Raspberry Pi Docker TICK Stack

```
#########################################################################
# TICK Stack - Telegraf, InfluxDB, Chronograf, and Kapacitor            #
#              (in Docker Containers) for Raspberry Pi                  #
#    REF: https://www.influxdata.com/time-series-platform/              #
#    REF: https://www.influxdata.com/time-series-platform/telegraf/     #
#    REF: https://www.influxdata.com/products/influxdb/                 #
#    REF: https://www.influxdata.com/time-series-platform/chronograf/   #
#    REF: https://www.influxdata.com/time-series-platform/kapacitor/    #
#########################################################################

# 64 bit https://docs.influxdata.com/influxdb/v2.2/install/?t=Docker
# REF: https://hub.docker.com/r/arm64v8/influxdb
# Examples: https://github.com/influxdata/sandbox


###############################################################################
# Prerequisites
###############
ssh pi@YourPiIPAddressHere
sudo apt-get update && apt-get dist-upgrade -y
sudo curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh
sudo pip install --upgrade docker-compose
sudo docker swarm init
###############################################################################


###############################################################################
# Quick (if using Docker Swarm and bind mounted data in /opt/docker)
sudo -u root bash
mkdir -p /opt/docker-compose
cd /opt/docker-compose
mkdir -p /opt/docker-compose/W3GUY
cd /opt/docker-compose/W3GUY
git clone git@github.com:ernestgwilsonii/RaspberryPi-Docker-tick.git
cd RaspberryPi-Docker-tick
sudo ./lazy.sh
docker stack deploy -c docker-compose.yml tick-stack
docker stack ls
docker service ls
docker ps
# http://YourPiIPAddressHere:8888
#docker stack rm tick-stack
#rm -Rf /opt/docker/chronograf /opt/docker/influxdb /opt/docker/kapacitor /opt/docker/telegraf
#docker system prune -af
###############################################################################


###############################################################################
# Docker Images
sudo bash
time docker pull arm64v8/telegraf:1.22.4        # REF: https://hub.docker.com/r/arm64v8/telegraf
time docker pull arm64v8/influxdb:2.2.0-alpine  # REF: https://hub.docker.com/r/arm64v8/influxdb
time docker pull arm64v8/chronograf:1.9.4       # REF: https://hub.docker.com/r/arm64v8/chronograf
time docker pull arm64v8/kapacitor:1.6.4        # REF: https://hub.docker.com/r/arm64v8/kapacitor
docker images

# Generate new config files (optional)
#docker run --rm -p 8092:8092/udp -p 8094:8094/tcp -p 8125:8125/tcp arm64v8/telegraf:1.22.4 telegraf config > telegraf.conf
#docker run --rm -v /opt/docker/influxdb/etc/influxdb:/etc/influxdb -v /opt/docker/influxdb/var/lib/influxdb:/var/lib/influxdb -p 2003:2003/tcp -p 8094:8094/tcp -p 8125:8125/tcp arm64v8/influxdb:2.2.0-alpine influxd config > influxdb.conf
#docker run --rm -v /opt/docker/kapacitor/var/lib/kapacitor:/var/lib/kapacitor -p 9092:9092 arm32v7/kapacitor:1.9.4 kapacitord config > kapacitor.conf

# Verify (no persistence, start each container manually for testing and then shutdown and remove)
docker network create influxdb
docker run -d --name influxdb --net=influxdb -p 8086:8086/tcp -p 2003:2003/tcp -e INFLUXDB_GRAPHITE_ENABLED=true arm64v8/influxdb:2.2.0-alpine influxd
docker run -d --name telegraf --net=influxdb -e HOST_ETC=/host/etc -e HOST_PROC=/host/proc -e HOST_SYS=/host/sys -p 8092:8092/udp -p 8094:8094/tcp -p 8125:8125/tcp -v /etc:/host/etc:ro -v /proc:/host/proc:ro -v /sys:/host/sys:ro -v /var/run/docker.sock:/var/run/docker.sock -e HOST_PROC=/host/proc -e INFLUX_URL="http://$(hostname -I | awk '{print $1}'):8086" arm64v8/telegraf:1.22.4 telegraf
docker run -d --name chronograf --net=influxdb -p 8888:8888 -e influxdb-url=http://influxdb:8086 arm64v8/chronograf:1.9.4 chronograf
docker run -d --name kapacitor --net=influxdb -p 9092:9092 -e KAPACITOR_INFLUXDB_0_URLS_0=http://influxdb:8086 arm64v8/kapacitor:1.6.4       kapacitord
docker ps
# REF: https://docs.influxdata.com/influxdb/v1.8/tools/api/
# Test stuff!
docker stop telegraf chronograf kapacitor influxdb
docker rm telegraf chronograf kapacitor influxdb
docker network rm influxdb
###############################################################################


###############################################################################
# First time setup #
####################
# Create bind mounted directories

# Telegraf - https://hub.docker.com/r/arm32v7/telegraf
mkdir -p /opt/docker/telegraf/etc/telegraf
cp -n telegraf.conf /opt/docker/telegraf/etc/telegraf/telegraf.conf
chmod -R a+rw /opt/docker/telegraf

# InfluxDB - https://hub.docker.com/r/arm32v7/influxdb
mkdir -p /opt/docker/influxdb/etc/influxdb
cp -n influxdb.conf /opt/docker/influxdb/etc/influxdb/influxdb.conf
mkdir -p /opt/docker/influxdb/var/lib/influxdb/meta
mkdir -p /opt/docker/influxdb/var/lib/influxdb/data
chmod -R a+rw /opt/docker/influxdb

# Chronograf - https://hub.docker.com/r/arm32v7/chronograf
mkdir -p /opt/docker/chronograf/var/lib/chronograf
chmod -R a+rw /opt/docker/chronograf

# Kapacitor - https://hub.docker.com/r/arm32v7/kapacitor
mkdir -p /opt/docker/kapacitor/etc/kapacitor
cp -n kapacitor.conf /opt/docker/kapacitor/etc/kapacitor/kapacitor.conf
mkdir -p /opt/docker/kapacitor/var/lib/kapacitor
chmod -R a+rw /opt/docker/kapacitor

###############################################################################


###############################################################################
# Deploy #
##########
# Deploy the stack into a Docker Swarm
docker stack deploy -c docker-compose.yml tick-stack
#docker stack rm tick-stack

# Development UI and API endpoint: http://172.28.0.41:8086 # See starting username/password in docker-compose environment
# FUTURE: Influx now has a full web UI with dashboards/alerting https://docs.influxdata.com/influxdb/v2.2/visualize-data/dashboards/

# Verify
docker stack ls
docker service ls | grep tick-stack
docker service logs -f tick-stack_telegraf
docker service logs -f tick-stack_influxdb
docker service logs -f tick-stack_chronograf
docker service logs -f tick-stack_kapacitor
docker ps
###############################################################################
```
