FROM alpine/git:latest

# copy the entrypoint.sh file
COPY entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
