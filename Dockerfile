FROM alpine

ENV SFTP_UID=1000
ENV SFTP_GID=1000

# Set up a dedicated user for SFTP access.
# Disable password logins for this user, but don't lock the account.
RUN set -x \
	&& addgroup -g $SFTP_GID sftp \
	&& adduser -D -h /data -H -s /sbin/nologin -G sftp -u $SFTP_UID sftp \
	&& echo 'sftp:*' | chpasswd -e

# Install SSH/SFTP daemon.
RUN apk --no-cache add openssh-server openssh-sftp-server \
	&& mkdir /etc/ssh/host_keys \
	&& mkdir /etc/ssh/authorized_keys

# Create SFTP area.
# The top directory must be owned by root and have mode 755
# in order to use chroot.
RUN mkdir -p /srv/sftp/data \
	&& chmod 0755 /srv/sftp \
	&& chown sftp:sftp /srv/sftp/data

# Configure SSH/SFTP daemon.
COPY sshd_config /etc/ssh/

# Install SSH host keys.
VOLUME ["/etc/ssh/host_keys"]
VOLUME ["/etc/ssh/authorized_keys"]
VOLUME ["/srv/sftp/data"]
EXPOSE 22/tcp
