FROM debian

ENV SFTP_UID=1000
ENV SFTP_GID=1000
ENV SFTP_HOME=/data

# Set up a dedicated user for SFTP access.
RUN groupadd --gid $SFTP_GID sftp \
	&& useradd --uid $SFTP_UID --gid $SFTP_GID \
	--home-dir $SFTP_HOME --no-create-home \
	sftp
