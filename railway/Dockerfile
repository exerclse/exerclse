# Exerclse — single-container Railway deployment.
# Runs the openGym API (Node.js) and the web frontend (nginx) in one container.
# nginx listens on Railway's $PORT; the API listens on 127.0.0.1:3000 internally.

# ── Stage 1: build the React frontend ──────────────────────────────
FROM --platform=$BUILDPLATFORM node:22-alpine AS frontend-build
WORKDIR /app/frontend
COPY frontend/package.json frontend/package-lock.json* ./
RUN npm ci --ignore-scripts
COPY api/coach/core/ /app/api/coach/core/
COPY frontend/ ./
RUN npm run build

# ── Stage 2: prepare the API ───────────────────────────────────────
FROM node:22-alpine AS api-build
WORKDIR /app/api
COPY api/package.json api/package-lock.json* ./
RUN npm ci --omit=dev --omit=optional && npm cache clean --force
COPY api/server.js api/push-messages.js api/nudge.js api/nudge-copy.js api/verify-error.js api/password.js api/rate-limit.js api/passkeys-store.js api/device-link.js api/media.js api/queue.js api/sync-stamps.js api/durable.js ./
COPY api/coach ./coach

# ── Stage 3: final runtime (nginx + node) ─────────────────────────
FROM nginxinc/nginx-unprivileged:alpine
USER root
RUN apk add --no-cache nodejs su-exec
# nginx config (templated port at container start)
COPY railway/nginx.conf /etc/nginx/nginx.conf
COPY railway/start.sh /start.sh
RUN chmod +x /start.sh && chown -R nginx:nginx /etc/nginx
# frontend static files
COPY --from=frontend-build /app/frontend/dist /usr/share/nginx/html
# exercise animations (licensed for openGym only — see catalogue/media/NOTICE.md)
COPY catalogue/media/ /usr/share/nginx/html/exercise-media/
# API code
COPY --from=api-build /app/api /app/api
RUN mkdir -p /data
# NOTE: stays as root — start.sh fixes /data ownership (Railway volume
# mounts as root at runtime) then drops to nginx via su-exec.
ENV NODE_ENV=production
EXPOSE 8080
CMD ["/start.sh"]
