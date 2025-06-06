# FROM node:current-alpine
FROM node:23.11.0-alpine3.20
COPY . /app1
WORKDIR /app1
RUN npm install
CMD [ "node", "app.js" ]