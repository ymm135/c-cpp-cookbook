#!/bin/bash
while :
do
    echo "start test"
    /root/redis-5.0.14/src/redis-cli  -n 0 set "note" "123456789"
    /root/redis-5.0.14/src/redis-cli  -n 0 get "note"
    /root/redis-5.0.14/src/redis-cli  -n 0 del "note"
done