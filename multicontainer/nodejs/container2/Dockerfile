# FROM node:current-alpine
FROM node:18.3.0-alpine3.14
COPY . /app
WORKDIR /app
RUN npm install
EXPOSE 5000
CMD [ "node", "app.js" ]