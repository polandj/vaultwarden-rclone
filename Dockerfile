FROM vaultwarden/server:1.30.0

WORKDIR /

# Install cron
RUN apt-get update
RUN apt-get install -y -qq --allow-downgrades \
		--allow-remove-essential \
		--allow-change-held-packages \
		sqlite3 rclone cron

# Default environment variables
ENV BKUP_DT_FORMAT="+%Y-%m"
ENV BKUP_PROVIDER_NAME="backblaze"
ENV BKUP_PROVIDER_TYPE="b2"
ENV BKUP_AT_MIN=17
ENV BKUP_AT_HOUR=3

# Need to pass in these two
#BKUP_PROVIDER_AUTH="account ACCT key KEY"
#BKUP_PROVIDER_DEST="BUCKET"

ADD entry.sh /entry.sh
RUN chmod 755 /entry.sh

# Copy the backup script and make it executable
# (the backup script name is referenced in entry.sh)
ADD backup.sh /backup.sh
RUN chmod 755 /backup.sh

# Copy the entrypoint and run a helper script as the command
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/entry.sh"]
