# FROM node:current-alpine
FROM node:18.3.0-alpine3.14
COPY . /app
WORKDIR /app
RUN apk add --no-cache netcat-openbsd
RUN npm install
CMD [ "node", "app.js" ]