# Multi-stage build to run Flyway migrations
FROM flyway/flyway:9.22.3-alpine AS flyway-builder
COPY ./migrations /flyway/sql
RUN true

# PostgreSQL with Flyway integration
FROM postgres:15-alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Copy Flyway to the container
COPY --from=flyway-builder /flyway /flyway

# Copy migration scripts
COPY ./migrations /flyway/sql

# Create init script that runs Flyway
RUN mkdir -p /docker-entrypoint-initdb.d

COPY ./flyway-init.sh /docker-entrypoint-initdb.d/01-flyway-init.sh
RUN chmod +x /docker-entrypoint-initdb.d/01-flyway-init.sh

# Health check
HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
    CMD pg_isready -U postgres || exit 1

    
EXPOSE 5432
