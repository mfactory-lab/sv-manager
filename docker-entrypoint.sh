#!/bin/sh

[ "$(ls -A /app/ansible/)" ] && cp -arf /app/ansible/* /ansible || echo "App ansible is empty"

exec $@
