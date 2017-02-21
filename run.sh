#!/bin/sh
xhost +

docker run -v /tmp/.X11-unix:/tmp/.X11-unix -v $PWD:/pga -e DISPLAY=unix$DISPLAY --rm -i -t pgatoolkit bash -c "cd /pga; bash"
xhost -
