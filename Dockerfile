# ---- STAGE 1: Install Dependencies ----
FROM node:18-alpine AS deps
RUN apk add --no-cache python3 make g++ git

WORKDIR /app
COPY package.json yarn.lock ./
RUN corepack enable \
    && corepack prepare yarn@4.5.0 --activate \
    && yarn install

# ---- STAGE 2: Build Admin UI ----
FROM node:18-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN yarn build

# ---- STAGE 3: Runtime ----
FROM node:18-alpine AS runtime
WORKDIR /app

COPY --from=deps    /app/node_modules ./node_modules
COPY --from=builder /app/build        ./build
COPY --from=builder /app/public       ./public
COPY --from=builder /app/server.js    ./server.js
COPY --from=builder /app/config       ./config

# Create a non-root user and chown
RUN addgroup -S strapi && adduser -S strapi -G strapi \
    && chown -R strapi:strapi /app
USER strapi

EXPOSE 1337
CMD ["node", "server.js"]    