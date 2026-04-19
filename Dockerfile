FROM node:22-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy all project files
COPY . .

# Vite config specifies port 8080
EXPOSE 8080

# Start the Vite development server
CMD ["npm", "run", "dev", "--", "--host"]
