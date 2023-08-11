#!/bin/sh

[ "$(ls -A /app/ansible/)" ] && cp -arf /app/ansible/* /ansible || echo "App ansible is empty"
if [ ! -d "/etc/sv_manager/group_vars" ]
then
  cp -r /ansible/inventory/group_vars /etc/sv_manager/
fi
exec $@
rm -rf /etc/sv_manager/group_vars