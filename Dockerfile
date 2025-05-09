# 1. Build stage using the official Strapi builder
FROM strapi/strapi:latest AS builder

# Copy your app into the container
WORKDIR /usr/src/api
COPY package.json yarn.lock ./
# Install dependencies (production only)
RUN yarn install --production

# Copy your code and build the admin UI
COPY . .
RUN yarn build

# 2. Runtime stage using the official Strapi image
FROM strapi/strapi:latest

WORKDIR /usr/src/api
# Copy only runtime dependencies and built admin
COPY --from=builder /usr/src/api/node_modules ./node_modules
COPY --from=builder /usr/src/api/build ./build
COPY --from=builder /usr/src/api/public ./public
COPY --from=builder /usr/src/api/server.js ./server.js
# Copy config (database, env, etc)
COPY --from=builder /usr/src/api/config ./config

# Drop root privileges
USER node

EXPOSE 1337
CMD ["node", "server.js"]