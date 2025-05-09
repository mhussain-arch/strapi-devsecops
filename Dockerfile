# 1. Build stage using official Strapi builder (Node 18)
FROM strapi/strapi:latest AS builder

WORKDIR /usr/src/api
COPY package.json yarn.lock ./

RUN yarn install

# Copy source and build admin UI
COPY . .
RUN yarn build

# 2. Runtime stage (also Node 18)
FROM strapi/strapi:latest

WORKDIR /usr/src/api
# Copy only what’s needed at runtime
COPY --from=builder /usr/src/api/node_modules ./node_modules
COPY --from=builder /usr/src/api/build       ./build
COPY --from=builder /usr/src/api/public      ./public
COPY --from=builder /usr/src/api/server.js   ./server.js
COPY --from=builder /usr/src/api/config      ./config

# Drop to non-root user
USER node

EXPOSE 1337
CMD ["node", "server.js"]