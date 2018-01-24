FROM centos

EXPOSE 80 443

WORKDIR /opt

RUN useradd -s /bin/false pmm
RUN yum -y install epel-release && yum -y install ansible

COPY playbook-install.yml /opt/playbook-install.yml
RUN ansible-playbook -vvv -i 'localhost,' -c local /opt/playbook-install.yml

COPY supervisord.conf /etc/supervisord.d/pmm.ini
COPY playbook-init.yml /opt/playbook-init.yml
RUN sed -i'' -e 's/percona-prometheus-1.8.2/percona-prometheus2/' /usr/share/pmm-update/ansible/v010600/main.yml
RUN rm -rf /usr/share/percona-dashboards/dashboards \
    && git clone https://github.com/percona/grafana-dashboards.git /tmp/pd \
    && cd /tmp/pd \
    && git checkout prometheus2 \
    && mv /tmp/pd/dashboards /usr/share/percona-dashboards/dashboards \
    && rm -rf /tmp/pd
RUN sed -i'' -e 's/v1.6.0/1.6.0-prom2.1/' /usr/share/pmm-server/landing-page/index.html

RUN ansible-playbook -vvv -i 'localhost,' -c local /opt/playbook-init.yml

COPY entrypoint.sh /opt

CMD ["/opt/entrypoint.sh"]
