FROM n8nio/n8n:1.92.2

USER root

# Create custom nodes directory and clone Ghost Plus repo
RUN mkdir -p /home/node/.n8n/custom && \
    cd /home/node/.n8n/custom && \
    git clone https://github.com/VladoPortos/N8N-ghost-plus.git && \
    cd N8N-ghost-plus && \
    npm install --omit=dev && \
    npm run build

# Set environment variable so n8n loads the custom Ghost Plus node
ENV N8N_CUSTOM_EXTENSIONS=/home/node/.n8n/custom/N8N-ghost-plus

USER node
