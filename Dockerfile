# Use the official Node.js 20 image as the base image
FROM node:20

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install production dependencies.
RUN npm install

# Bundle app source inside Docker image
COPY . .

# Compile TypeScript using npx to use the local TypeScript version
RUN npx tsc -p tsconfig.build.json

# Start the application using ts-node via nodemon via run script
CMD ["npm run dev"]
