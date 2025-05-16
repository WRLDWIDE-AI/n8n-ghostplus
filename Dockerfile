FROM n8nio/n8n:1.92.2

USER root

RUN mkdir -p /home/node/.n8n/custom && \
    cd /home/node/.n8n/custom && \
    git clone https://github.com/VladoPortos/N8N-ghost-plus.git && \
    cd N8N-ghost-plus && \
    npm install --omit=dev --legacy-peer-deps && \
    npm run build

ENV N8N_CUSTOM_EXTENSIONS=/home/node/.n8n/custom/N8N-ghost-plus

USER node
