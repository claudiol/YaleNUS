#!/bin/sh

while true; do
    inotifywait -e modify -e close_write -e move cloudforms_openstack.gv;
    if $?; then 
	echo '';
    else
	make;
    fi;
done
