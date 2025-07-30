FROM node:22

# Install packages
RUN apt-get update && apt-get install -y git curl wget


COPY ./run.sh /run.sh
COPY ./add_bash_util.sh /add_bash_util.sh

# Expose ports
EXPOSE 7860
CMD ["/run.sh"]
