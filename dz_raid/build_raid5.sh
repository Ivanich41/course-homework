#!/bin/bash
mdadm --create --verbose /dev/md0 -l 5 -n 3 /dev/sd{b,c,d}
mkdir /etc/mdadm/
cp /vagrant/mdadm.conf /etc/mdadm/mdadm.conf