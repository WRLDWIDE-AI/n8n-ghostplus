# syntax=docker/dockerfile:1

# 1) Builder stage: build the Ghost Plus extension
FROM n8nio/n8n:1.92.2 AS builder

USER root
RUN apk add --no-cache curl git \
  && rm -f /usr/local/bin/pnpx /usr/local/bin/pnpm \
  && npm install -g pnpm

WORKDIR /tmp/ghostplus
RUN git clone https://github.com/VladoPortos/N8N-ghost-plus.git . \
 && pnpm install \
 && pnpm run build

# 2) Final image: n8n with the custom Ghost Plus node
FROM n8nio/n8n:1.92.2

USER root
RUN apk add --no-cache curl

# Copy built extension from builder stage
COPY --from=builder /tmp/ghostplus /home/node/.n8n/custom/n8n-nodes-ghostplus

# Fix permissions so n8n (node user) can access the extension
RUN chown -R node:node /home/node/.n8n/custom

# Set environment variables to load the custom extension and enable runners
ENV N8N_CUSTOM_EXTENSIONS=/home/node/.n8n/custom/n8n-nodes-ghostplus \
    N8N_RUNNERS_ENABLED=true

# Copy healthcheck script and make it executable
COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh

# Switch back to non-root user
USER node

# Define container healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 CMD ["/healthcheck.sh"]
# … your existing final-stage bits …

# make sure Coolify sees port 5678
EXPOSE 5678
