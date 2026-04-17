#!/bin/bash
# Example: Install MMM-PIR-Sensor module

docker exec mm bash -c "cd /opt/magic_mirror/modules && git clone https://github.com/paviro/MMM-PIR-Sensor.git"
docker exec mm bash -c "cd /opt/magic_mirror/modules/MMM-PIR-Sensor && npm install"
