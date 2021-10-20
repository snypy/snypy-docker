# https://hub.docker.com/_/node
FROM node:16 AS build
WORKDIR /usr/src/app
RUN apt-get update && apt-get install git -y
RUN git clone https://github.com/nezhar/snypy-frontend .
RUN npm install
RUN npm run build --prod


# https://hub.docker.com/_/nginx
FROM nginx:1.21-alpine
WORKDIR /root/
COPY --from=build /usr/src/app/dist /usr/share/nginx/html
COPY default.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh entrypoint.sh
CMD ["sh", "entrypoint.sh"]
