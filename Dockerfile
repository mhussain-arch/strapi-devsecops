# Stage 1: Builder - Install dependencies and build the project
FROM node:18-slim AS builder

WORKDIR /app

# Enable Corepack for Yarn Berry (optional)
RUN corepack enable && \
    corepack prepare yarn@stable --activate

# Copy package files
COPY package.json yarn.lock ./

# Install all dependencies (including devDependencies)
RUN yarn install --frozen-lockfile

# Copy application code
COPY . .

# Build the project (remove if not needed)
RUN yarn build

# Remove development dependencies
RUN rm -rf node_modules

# Stage 2: Production - Create final optimized image
FROM node:18-slim

WORKDIR /app

# Copy application files from builder
COPY --from=builder /app .

# Enable Corepack for Yarn Berry (optional)
RUN corepack enable && \
    corepack prepare yarn@stable --activate

# Install production dependencies only
RUN yarn install --frozen-lockfile --production

# Create non-root user and set permissions
RUN addgroup --system --gid 1001 strapi && \
    adduser --system --uid 1001 strapi --ingroup strapi && \
    chown -R strapi:strapi /app

USER strapi

# Expose Strapi port
EXPOSE 1337

# Start Strapi in production mode
CMD ["yarn", "start"]