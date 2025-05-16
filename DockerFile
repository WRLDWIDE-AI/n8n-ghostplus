FROM n8nio/n8n:1.92.2

USER root

RUN npm install -g @vladoportos/n8n-nodes-ghostplus

USER node
