FROM node:22

# Install packages
RUN apt-get update && apt-get install -y git curl wget jq


COPY ./run.sh /run.sh
COPY ./add_bash_util.sh /add_bash_util.sh
COPY ./Caddyfile /Caddyfile
# Expose ports

EXPOSE 7860

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s \
  CMD curl -f http://localhost:7860/ || exit 1
ENTRYPOINT ["/bin/bash", "/run.sh"]
# CMD ["/run.sh"]
