# FROM node:current-alpine
FROM node:14.17.3-alpine3.14
COPY . /app
WORKDIR /app
RUN npm install
EXPOSE 5000
CMD [ "node", "app.js" ]