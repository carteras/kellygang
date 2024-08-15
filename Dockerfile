FROM alpine:latest

# Install OpenRC, SSH server, and additional utilities
RUN apk update && \
    apk add openrc openssh netcat-openbsd nmap traceroute iperf iperf3 \
    net-snmp-tools termshark tcpdump mtr arp-scan ethtool iftop nload \
    bind-tools gcc git openssl-dev nano vim ansible

RUN rc-update add sshd && \
    rc-status && \
    touch /run/openrc/softlevel

# Build-time argument to pass GitHub token (not stored in image layers)
ARG GITHUB_TOKEN

ENV GITHUB_TOKEN=${GITHUB_TOKEN}

# Clone challenge directory

RUN git clone https://${GITHUB_TOKEN}:x-oauth-basic@github.com/carteras/bushranger-kellygang.git /opt/ansible-playbook

# Create a startup script to run all Ansible playbooks
RUN echo '#!/bin/sh' > /opt/run_playbooks.sh && \
    echo 'for playbook in /opt/ansible-playbook/bushranger-kellygang/*.yml; do' >> /opt/run_playbooks.sh && \
    echo '  ansible-playbook -i localhost, $playbook --connection=local;' >> /opt/run_playbooks.sh && \
    echo 'done' >> /opt/run_playbooks.sh && \
    chmod +x /opt/run_playbooks.sh

# Expose SSH port
EXPOSE 22

# Start OpenRC and SSH server
CMD ["/sbin/init"]