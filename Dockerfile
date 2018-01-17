FROM centos

EXPOSE 80 443

WORKDIR /opt

RUN useradd -s /bin/false pmm
RUN yum -y install epel-release && yum -y install ansible

COPY playbook-install.yml /opt/playbook-install.yml
RUN ansible-playbook -vvv -i 'localhost,' -c local /opt/playbook-install.yml

COPY supervisord.conf /etc/supervisord.d/pmm.ini
COPY playbook-init.yml /opt/playbook-init.yml
RUN sed -i'' -e 's/percona-prometheus-1.8.2/percona-prometheus2/' /usr/share/pmm-update/ansible/v010503/main.yml
RUN rm -rf /usr/share/percona-dashboards/dashboards \
    && git clone https://github.com/percona/grafana-dashboards.git /tmp/pd \
    && cd /tmp/pd \
    && git config --global user.email "nobody@percona.com" \
    && git config --global user.name "Nobody" \
    && git checkout v1.5.3 \
    && git cherry-pick 3844377 \
    && mv /tmp/pd/dashboards /usr/share/percona-dashboards/dashboards \
    && rm -rf /tmp/pd
RUN sed -i'' -e 's/v1.5.3/1.5.3-prom2.0-alpha1/' /usr/share/pmm-server/landing-page/index.html

RUN ansible-playbook -vvv -i 'localhost,' -c local /opt/playbook-init.yml

COPY entrypoint.sh /opt

CMD ["/opt/entrypoint.sh"]
