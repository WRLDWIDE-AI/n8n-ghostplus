FROM n8nio/n8n:1.92.2

USER root

# Install curl for healthchecks (Alpine-based)
RUN apk update && apk add curl git

# Install pnpm (required for Ghost Plus)
RUN npm install -g pnpm

# Clone and build Ghost Plus
RUN mkdir -p /home/node/.n8n/custom && \
    cd /home/node/.n8n/custom && \
    git clone https://github.com/VladoPortos/N8N-ghost-plus.git && \
    cd N8N-ghost-plus && \
    pnpm install --no-optional --legacy-peer-deps && \
    pnpm run build

ENV N8N_CUSTOM_EXTENSIONS=/home/node/.n8n/custom/N8N-ghost-plus

USER node
