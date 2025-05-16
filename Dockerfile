FROM n8nio/n8n:1.92.2

USER root
RUN apk add --no-cache curl

# Copy your built extension (adjust as needed)
COPY --from=builder /tmp/ghostplus /home/node/.n8n/custom/n8n-nodes-ghostplus
RUN chown -R node:node /home/node/.n8n/custom

ENV N8N_CUSTOM_EXTENSIONS=/home/node/.n8n/custom/n8n-nodes-ghostplus \
    N8N_RUNNERS_ENABLED=true

# Copy healthcheck script from build context
COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh

USER node

HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 CMD ["/healthcheck.sh"]
