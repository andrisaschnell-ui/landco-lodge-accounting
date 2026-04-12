# Use the official Bun image
FROM oven/bun:latest

# Set the working directory
WORKDIR /app

# Copy package files first for better caching
COPY package.json bun.lock ./

# Install dependencies
RUN bun install

# Copy the rest of the application code
COPY . .

# Expose the Vite port
EXPOSE 5173

# Start the dev server with host binding so it's accessible from Windows
CMD ["bun", "run", "dev", "--host"]
