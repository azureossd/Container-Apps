# FROM node:current-alpine
FROM node:24.1.0-alpine3.20
COPY . /app1
WORKDIR /app1
RUN npm install
CMD [ "node", "app.js" ]