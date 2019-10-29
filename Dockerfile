FROM alpine

ENV SFTP_UID=1000
ENV SFTP_GID=1000

# Set up a dedicated user for SFTP access.
# Disable password logins for this user, but don't lock the account.
RUN set -x \
	&& addgroup -g $SFTP_GID sftp \
	&& adduser -D -h /data -H -s /sbin/nologin -G sftp -u $SFTP_UID sftp \
	&& echo 'sftp:*' | chpasswd -e

RUN set -eux; \
# Install SSH/SFTP daemon.
	apk --no-cache add openssh-server openssh-sftp-server; \
	mkdir /etc/ssh/host_keys; \
	\
# Create SFTP area; the top directory must be owned by root and have mode 755 in
# order to use chroot.
	mkdir -p /srv/sftp/data; \
	chmod 0755 /srv/sftp; \
	chown sftp:sftp /srv/sftp/data;

# Configure SSH/SFTP daemon.
COPY sshd_config /etc/ssh/

VOLUME ["/etc/ssh/host_keys/"]
VOLUME ["/etc/ssh/sftp.authorized_keys"] # Could be a file or directory
VOLUME ["/srv/sftp/data/"]
EXPOSE 22/tcp

COPY sshd-foreground /usr/local/bin/
COPY ssh-authorized-keys /usr/local/bin/
ENTRYPOINT ["sshd-foreground"]
