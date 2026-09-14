FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 8080
#remapping nginx (port 80) to 8080
RUN sed -i 's/listen\s*80;/listen 8080;/' /etc/nginx/conf.d/default.conf