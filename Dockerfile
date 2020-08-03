FROM docker.io/library/alpine:latest

ENV SFTP_UID=1000
ENV SFTP_GID=1000

# Create a dedicated user for SFTP access.
RUN set -eux; \
    addgroup -g "$SFTP_GID" sftp; \
    adduser -D -h /data -H -s /sbin/nologin -G sftp -u "$SFTP_UID" sftp; \
# Disable password logins for the user, but don't lock the account.
    echo 'sftp:*' | chpasswd -e;

RUN set -eux; \
# Install SSH/SFTP daemon.
    apk --no-cache add openssh-server openssh-sftp-server; \
    \
    mkdir /etc/ssh/host_keys; \
    mkdir /etc/ssh/authorized_keys; \
    \
# Create SFTP area; the top directory must be owned by root and have mode 755 in
# order to use chroot.
    mkdir -p /srv/sftp; \
    chmod 0755 /srv/sftp;

# Configure SSH/SFTP daemon.
COPY sshd_config /etc/ssh/
COPY sshd-foreground /usr/local/bin/
COPY ssh-authorized-keys /usr/local/bin/

VOLUME /etc/ssh/host_keys
VOLUME /etc/ssh/authorized_keys
EXPOSE 22/tcp

ENTRYPOINT ["/usr/local/bin/sshd-foreground"]
