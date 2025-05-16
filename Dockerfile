FROM n8nio/n8n:1.92.2

USER root

# Clone the N8N-ghost-plus extension, install dependencies, and build it
RUN mkdir -p /home/node/.n8n/custom && \
    cd /home/node/.n8n/custom && \
    git clone https://github.com/VladoPortos/N8N-ghost-plus.git && \
    cd N8N-ghost-plus && \
    pnpm install --no-optional && \
    pnpm run build

# Set environment variable to load the custom extension
ENV N8N_CUSTOM_EXTENSIONS=/home/node/.n8n/custom/N8N-ghost-plus

USER node
