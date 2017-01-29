#!/bin/bash
docker start 'sx296' 'sx297' 'sx299' 'sx300';
docker ps | perl -ne 's/0.0.0.0/localhost/g;/\s(localhost:\d+)->/;print "root@".$1."\n" if $1 ' > ~/github/netscpwrapper/local_test_files/mygroupfile;
chown alexandros:alexandros ~/github/netscpwrapper/local_test_files/mygroupfile;
chmod 777 ~/github/netscpwrapper/local_test_files/mygroupfile; 
cat ~/github/netscpwrapper/local_test_files/mygroupfile;
