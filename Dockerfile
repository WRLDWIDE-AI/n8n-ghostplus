# syntax=docker/dockerfile:1

# 1) Builder stage: build the Ghost Plus extension
FROM n8nio/n8n:1.92.2 AS builder

USER root
RUN apk add --no-cache curl git \
  && rm -f /usr/local/bin/pnpx /usr/local/bin/pnpm \
  && npm install -g pnpm

WORKDIR /tmp/build
RUN git clone https://github.com/VladoPortos/N8N-ghost-plus.git . \
    && pnpm install \
    && pnpm build

# 2) Final image: n8n with the custom Ghost Plus node
FROM n8nio/n8n:1.92.2

USER root
RUN apk add --no-cache curl

# Copy built extension and link it
COPY --from=builder /tmp/build/dist /usr/local/lib/node_modules/n8n-nodes-ghostplus
RUN npm link /usr/local/lib/node_modules/n8n-nodes-ghostplus

# Enable custom extension and task runners
env N8N_CUSTOM_EXTENSIONS=/usr/local/lib/node_modules/n8n-nodes-ghostplus \
    N8N_RUNNERS_ENABLED=true

# Create healthcheck script
RUN cat << 'EOF' > /healthcheck.sh
#!/bin/sh
max_retries=30
retry_interval=2
retry_count=0

while [ $retry_count -lt $max_retries ]; do
  status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5678/healthz || echo "000")
  if [ "$status" = "200" ]; then
    exit 0
  fi
  echo "healthcheck attempt $retry_count failed: $status"
  sleep $retry_interval
  retry_count=$((retry_count + 1))
  retry_interval=$((retry_interval + 1))
done

echo "healthcheck failed after $max_retries attempts"
exit 1
EOF

RUN chmod +x /healthcheck.sh

# Switch back to non-root
USER node

# Define container healthcheck\ nhealthcheck --interval=30s --timeout=5s --start-period=120s --retries=3 CMD ["/healthcheck.sh"]
