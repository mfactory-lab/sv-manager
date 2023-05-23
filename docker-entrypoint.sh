#!/bin/sh

[ "$(ls -A /ansible-custom)" ] && cp -arf /ansible-custom/* /ansible || echo "Ansible-custom Empty"

exec $@
