FROM willhallonline/ansible:2.13.7-alpine-3.15

RUN mkdir -p /app/ansible

COPY docker-entrypoint.sh /
COPY . /ansible

WORKDIR /ansible

RUN mv inventory_example inventory

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD [ "ansible-playbook", "--version" ]

