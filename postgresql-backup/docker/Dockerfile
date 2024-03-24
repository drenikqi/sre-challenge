FROM postgres:latest
RUN apt-get update && apt-get install -y awscli
COPY backup-script.sh /backup-script.sh
RUN chmod +x /backup-script.sh
ENTRYPOINT ["/backup-script.sh"]
