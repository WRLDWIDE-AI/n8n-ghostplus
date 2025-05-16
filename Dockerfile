FROM n8nio/n8n:1.92.2

USER root
RUN apk add --no-cache curl

COPY --from=builder /tmp/ghostplus /home/node/.n8n/custom/n8n-nodes-ghostplus
RUN chown -R node:node /home/node/.n8n/custom

ENV N8N_CUSTOM_EXTENSIONS=/home/node/.n8n/custom/n8n-nodes-ghostplus \
    N8N_RUNNERS_ENABLED=true

RUN cat << 'EOF' > /healthcheck.sh
#!/bin/sh
count=0
while [ $count -lt 30 ]; do
  status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5678/ || echo "000")
  if [ "$status" = "200" ]; then
    exit 0
  fi
  count=$((count+1))
  sleep 2
done
exit 1
EOF

RUN chmod +x /healthcheck.sh

USER node

HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 CMD ["/healthcheck.sh"]
