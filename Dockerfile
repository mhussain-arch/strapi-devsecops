# Stage 1: Builder - Install dependencies and build the project
FROM node:18-slim AS builder

WORKDIR /app

# Switch to Yarn Classic (v1) as Strapi works better with it
RUN npm install -g yarn

# Copy package files and workspace directories first
COPY package.json yarn.lock .yarnrc* ./

# Install dependencies
RUN yarn install

# Copy remaining application files
COPY . .

# Build the project
RUN yarn build

# Stage 2: Production - Create final optimized image
FROM node:18-slim

WORKDIR /app

# Create non-root user first
RUN addgroup --system --gid 1001 strapi && \
    adduser --system --uid 1001 strapi --ingroup strapi

# Copy necessary files from builder
COPY --from=builder --chown=strapi:strapi /app/node_modules ./node_modules
COPY --from=builder --chown=strapi:strapi /app/package.json /app/yarn.lock ./
COPY --from=builder --chown=strapi:strapi /app/config ./config
COPY --from=builder --chown=strapi:strapi /app/extensions ./extensions
COPY --from=builder --chown=strapi:strapi /app/build ./build

USER strapi

EXPOSE 1337

CMD ["yarn", "start"]