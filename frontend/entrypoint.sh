find '/usr/share/nginx/html' -name '*.js' -exec sed -i -e 's,REST_API_URL,'"$REST_API_URL"',g' {} \;
nginx -g "daemon off;"