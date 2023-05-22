FROM willhallonline/ansible:2.13.7-alpine-3.15

COPY . /ansible

WORKDIR /ansible

RUN mv inventory_example inventory

CMD [ "ansible-playbook", "--version" ]

