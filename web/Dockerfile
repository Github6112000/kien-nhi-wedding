# Thiệp cưới online - Nguyễn Phương Nhi & Nguyễn Đình Kiên
# Static site served by nginx. Build & run:
#   docker build -t thiep-cuoi .
#   docker run -d -p 8080:80 --name thiep-cuoi thiep-cuoi
# Then open http://localhost:8080

FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY index.html /usr/share/nginx/html/index.html
COPY css/ /usr/share/nginx/html/css/
COPY js/ /usr/share/nginx/html/js/
COPY assets/ /usr/share/nginx/html/assets/

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
    CMD wget -qO- http://127.0.0.1/ > /dev/null 2>&1 || exit 1

CMD ["nginx", "-g", "daemon off;"]
