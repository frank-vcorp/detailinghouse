# DetailingHouse — Static site served via NGINX
FROM nginx:alpine

# Copiar archivos del sitio
COPY . /usr/share/nginx/html/

# Copiar configuración de NGINX
COPY nginx.conf /etc/nginx/templates/default.conf.template

# Puerto dinámico de Railway (variable $PORT)
ENV PORT=8080
EXPOSE $PORT

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:$PORT/ || exit 1

CMD ["sh", "-c", "envsubst '$PORT' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
