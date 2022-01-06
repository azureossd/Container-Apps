# FROM node:current-alpine
FROM node:14.17.3-alpine3.14
COPY . /app
WORKDIR /app
RUN npm install
CMD [ "node", "app.js" ]