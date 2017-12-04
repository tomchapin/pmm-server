FROM centos

EXPOSE 80 443

WORKDIR /opt

RUN useradd -s /bin/false pmm
RUN yum -y install epel-release && yum -y install ansible

COPY playbook-install.yml /opt/playbook-install.yml
RUN ansible-playbook -vvv -i 'localhost,' -c local /opt/playbook-install.yml

COPY supervisord.conf /etc/supervisord.d/pmm.ini
COPY playbook-init.yml /opt/playbook-init.yml
RUN sed -i'' -e 's/percona-prometheus-1.8.2/percona-prometheus2/' /usr/share/pmm-update/ansible/v010502/main.yml
RUN ansible-playbook -vvv -i 'localhost,' -c local /opt/playbook-init.yml

COPY entrypoint.sh /opt

CMD ["/opt/entrypoint.sh"]
