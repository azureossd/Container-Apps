# FROM node:current-alpine
FROM node:14.17.3-alpine3.14
COPY . /app
WORKDIR /app
RUN apk --no-cache add curl su-exec
RUN npm install
CMD [ "node", "app.js" ]