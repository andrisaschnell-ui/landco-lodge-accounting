FROM node:20-alpine
# Install postgresql-client so pg_dump / psql are available for backup/restore
RUN apk add --no-cache postgresql15-client
WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev
COPY . .
RUN mkdir -p /app/backups
EXPOSE 4000
CMD ["node", "server.js"]
