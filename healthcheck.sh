#!/bin/sh
count=0
while [ $count -lt 30 ]; do
  status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5678/ || echo "000")
  if [ "$status" = "200" ]; then
    exit 0
  fi
  count=$((count+1))
  sleep 2
done
exit 1
