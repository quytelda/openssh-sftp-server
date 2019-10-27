FROM debian

ENV SFTP_UID=1000
ENV SFTP_GID=1000

# Set up a dedicated user for SFTP access.
RUN groupadd --gid $SFTP_GID sftp \
	&& useradd --uid $SFTP_UID --gid $SFTP_GID \
	--home-dir /data --no-create-home \
	sftp

# Install SSH/SFTP daemon.
RUN apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y openssh-server \
	&& rm -f /etc/ssh/ssh_host_*_key*

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
