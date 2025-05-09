# Stage 1: Builder - Install dependencies and build the project
FROM node:20-slim AS builder

WORKDIR /app

# Force Yarn Classic installation and configuration
RUN npm install -g yarn@1.22.19 && \
    yarn set version classic && \
    yarn config set ignore-engines true

# Copy essential Yarn configuration first
COPY package.json yarn.lock .yarnrc ./

# Install dependencies first (caching optimization)
RUN yarn install

# Copy application files
COPY . .

# Build the project
RUN yarn build

# Stage 2: Production - Create final optimized image
FROM node:20-slim

WORKDIR /app

# Create non-root user
RUN addgroup --system --gid 1001 strapi && \
    adduser --system --uid 1001 strapi --ingroup strapi

# Copy production files from builder
COPY --from=builder --chown=strapi:strapi /app/node_modules ./node_modules
COPY --from=builder --chown=strapi:strapi /app/package.json /app/yarn.lock ./
COPY --from=builder --chown=strapi:strapi /app/config ./config
COPY --from=builder --chown=strapi:strapi /app/extensions ./extensions
COPY --from=builder --chown=strapi:strapi /app/build ./build

USER strapi

EXPOSE 1337

CMD ["yarn", "start"]