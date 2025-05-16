FROM n8nio/n8n:1.92.2

USER root

RUN apt-get update && apt-get install -y curl

USER node
