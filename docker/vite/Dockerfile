FROM node:18-alpine

WORKDIR /var/www/html

COPY src/package*.json ./
RUN npm install

CMD ["npm", "run", "dev"]