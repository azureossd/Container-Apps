# FROM node:current-alpine
FROM node:18.3.0-alpine3.14
COPY . /app
WORKDIR /app
RUN apk --no-cache add curl su-exec
RUN npm install
CMD [ "node", "app.js" ]