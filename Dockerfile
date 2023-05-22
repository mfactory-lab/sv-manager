FROM willhallonline/ansible:2.13.7-alpine-3.15

COPY . /ansible

CMD [ "ansible-playbook", "--version" ]

