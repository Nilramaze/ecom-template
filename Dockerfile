ARG NODE_VERSION=16.14.0

# Setup the build container.
FROM node:${NODE_VERSION}-alpine AS build

WORKDIR /home/node


ENV PAYLOAD_SECRET=8vS7e8tco8Vz/iRPfenERsK1M4LjP+yF
ENV DATABASE_URI=mongodb+srv://bb24630ce53e71b5:4100d526b050797650b2a6db55f7666b@mongo-0.ecom-db--mfg54m5dzw2h.addon.code.run:27017/b9907ab2653f?replicaSet=rs0&authSource=b9907ab2653f&tls=true
ENV MONGODBURI=mongodb+srv://bb24630ce53e71b5:4100d526b050797650b2a6db55f7666b@mongo-0.ecom-db--mfg54m5dzw2h.addon.code.run:27017/b9907ab2653f?replicaSet=rs0&authSource=b9907ab2653f&tls=true
# Install dependencies.
COPY package*.json .

ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools
RUN yarn install

# Copy the source files.
COPY src src
COPY tsconfig.json .
COPY tsconfig.server.json .

# Build the application.
RUN yarn build && yarn cache clean

# Setup the runtime container.
FROM node:${NODE_VERSION}-alpine

WORKDIR /home/node

# Copy the built application.
COPY --from=build /home/node /home/node

# Expose the service's port.
EXPOSE 3000

# Run the service.
CMD ["yarn", "run", "serve"]
