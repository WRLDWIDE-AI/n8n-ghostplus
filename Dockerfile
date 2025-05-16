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
 && pnpm build

# 2) Final image: n8n with the custom Ghost Plus node
FROM n8nio/n8n:1.92.2

USER root
RUN apk add --no-cache curl

# Copy built extension and link it
COPY --from=builder /tmp/ghostplus/dist /usr/local/lib/node_modules/n8n-nodes-ghostplus
RUN npm link /usr/local/lib/node_modules/n8n-nodes-ghostplus

# Enable custom extension and task runners
env N8N_CUSTOM_EXTENSIONS=/usr/local/lib/node_modules/n8n-nodes-ghostplus \
    N8N_RUNNERS_ENABLED=true

# Create healthcheck script
RUN cat << 'EOF' > /healthcheck.sh
#!/bin/sh
count=0
while [ $count -lt 30 ]; do
  status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5678/healthz || echo "000")
  if [ "$status" = "200" ]; then
    exit 0
  fi
  count=$((count+1))
  sleep 2
done
exit 1
EOF

RUN chmod +x /healthcheck.sh

# Switch back to non-root
USER node

# Define container healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 CMD ["/healthcheck.sh"]
