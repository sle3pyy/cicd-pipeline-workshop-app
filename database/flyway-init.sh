#!/bin/bash
# Flyway initialization script for PostgreSQL Docker
# This script creates the database and runs Flyway migrations

set -e

echo "Starting Flyway database initialization..."

# Wait for PostgreSQL to be ready
until pg_isready -h localhost -U postgres; do
    echo "Waiting for PostgreSQL..."
    sleep 2
done

# Create the workshop database if it doesn't exist
PGPASSWORD=$POSTGRES_PASSWORD psql -h localhost -U postgres <<EOF
    CREATE DATABASE workshop_db;
    CREATE USER workshop_user WITH PASSWORD '$WORKSHOP_USER_PASSWORD';
    GRANT ALL PRIVILEGES ON DATABASE workshop_db TO workshop_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO workshop_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO workshop_user;
EOF

echo "Database and user created successfully"

# Run Flyway migrations
echo "Running Flyway database migrations..."
/flyway/flyway -url=jdbc:postgresql://localhost:5432/workshop_db \
    -user=workshop_user \
    -password="$WORKSHOP_USER_PASSWORD" \
    -locations=filesystem:/flyway/sql \
    migrate

echo "Flyway migrations completed successfully"
