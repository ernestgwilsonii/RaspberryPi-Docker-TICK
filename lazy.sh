#!/bin/bash

# Telegraf - https://hub.docker.com/r/arm64v8/telegraf
mkdir -p /opt/docker/telegraf/etc/telegraf
cp -n telegraf.conf /opt/docker/telegraf/etc/telegraf/telegraf.conf
chmod -R a+rw /opt/docker/telegraf

# InfluxDB - https://hub.docker.com/r/arm64v8/influxdb
mkdir -p /opt/docker/influxdb/etc/influxdb
cp -n influxdb.conf /opt/docker/influxdb/etc/influxdb/influxdb.conf
mkdir -p /opt/docker/influxdb/var/lib/influxdb
chmod -R a+rw /opt/docker/influxdb

# Chronograf - https://hub.docker.com/r/arm64v8/chronograf
mkdir -p /opt/docker/chronograf/var/lib/chronograf
chmod -R a+rw /opt/docker/chronograf

# Kapacitor - https://hub.docker.com/r/arm64v8/kapacitor
mkdir -p /opt/docker/kapacitor/etc/kapacitor
cp -n kapacitor.conf /opt/docker/kapacitor/etc/kapacitor/kapacitor.conf
mkdir -p /opt/docker/kapacitor/var/lib/kapacitor
chmod -R a+rw /opt/docker/kapacitor
