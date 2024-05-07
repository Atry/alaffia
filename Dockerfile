# Use the official Node.js 14 image as the base image
FROM node:14

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install production dependencies.
RUN npm install --only=production

# Bundle app source inside Docker image
COPY . .

# The command to run our app when the container is invoked.
CMD [ "node", "src/index.js" ]
