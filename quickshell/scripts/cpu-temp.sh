#!/bin/bash
cat /sys/class/thermal/thermal_zone0/temp | awk '{print int($1/1000)}'
