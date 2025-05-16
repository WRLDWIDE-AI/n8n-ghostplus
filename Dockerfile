FROM n8nio/n8n:1.92.2 as builder

# Install necessary build tools
RUN apk add --no-cache curl git

# Safely install pnpm
RUN rm -f /usr/local/bin/pnpx /usr/local/bin/pnpm && npm install -g pnpm

# Install Ghost Plus node
WORKDIR /tmp/build
RUN git clone https://github.com/n8n-nodes-ghostplus.git . \
    && pnpm install \
    && pnpm build

# Final image
FROM n8nio/n8n:1.92.2

# Install curl for health checks
RUN apk add --no-cache curl

# Copy built extension from builder stage
COPY --from=builder /tmp/build/dist /usr/local/lib/node_modules/n8n-nodes-ghostplus
RUN npm link /usr/local/lib/node_modules/n8n-nodes-ghostplus

# Configure n8n to use the custom node
ENV N8N_CUSTOM_EXTENSIONS=/usr/local/lib/node_modules/n8n-nodes-ghostplus

# Add healthcheck script
USER root
RUN echo '#!/bin/sh\n\
max_retries=30\n\
retry_interval=1\n\
retry_count=0\n\
\n\
while [ $retry_count -lt $max_retries ]; do\n\
  response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5678/healthz || echo "000")\n\
  \n\
  if [ "$response" = "200" ]; then\n\
    exit 0\n\
  fi\n\
  \n\
  echo "Health check attempt $retry_count failed with status $response, retrying in ${retry_interval}s..."\n\
  sleep $retry_interval\n\
  retry_count=$((retry_count + 1))\n\
  retry_interval=$((retry_interval + 1))\n\
done\n\
\n\
echo "Health check failed after $max_retries attempts"\n\
exit 1' > /healthcheck.sh && chmod +x /healthcheck.sh

# Switch back to node user
USER node

# Define the health check with generous parameters
HEALTHCHECK --interval=30s --timeout=30s --start-period=120s --retries=3 \
  CMD /healthcheck.sh
