# Use an official Node.js runtime as a parent image
# AS builder label names this stage so Stage 2 can reference it later
FROM node:18-alpine AS builder

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory of the container
COPY package*.json ./

# Install dependencies - exactly what is in package-lock.json to ensure consistent installs
RUN npm ci

# Copy the rest of the application code to the working directory of the container
COPY . .

# Accept the backend URL as a build argument from the pipeline
ARG VITE_API_URL

# Expose it as an environment variable so Vite can read it during the build
ENV VITE_API_URL=$VITE_API_URL

# Build the application
RUN npm run build

# Use an official Nginx image to serve the built application
# This stage will copy the built application from the builder stage to the Nginx image
FROM nginx:alpine

# Copy the built application from the builder stage to the Nginx HTML directory
# The --from=builder flag tells Docker to copy files from the builder stage
# Copies only the dist folder from the builder stage to the Nginx HTML directory
# this helps to keep the final image size small by excluding unnecessary files
COPY --from=builder /app/dist /usr/share/nginx/html

# The port the app runs on
EXPOSE 80

# Start the Nginx server
CMD ["nginx", "-g", "daemon off;"]