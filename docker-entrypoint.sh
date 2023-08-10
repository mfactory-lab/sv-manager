#!/bin/sh

[ "$(ls -A /app/ansible/)" ] && cp -arf /app/ansible/* /ansible || echo "App ansible is empty"
cp -r /app/ansible/inventory/group_vars /etc/sv_manager/
exec $@
rm -rf /etc/sv_manager/group_vars