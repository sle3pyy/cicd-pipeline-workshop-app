# Flyway Database Migrations

This document explains how Flyway is used to manage database schema versions and migrations in the DevOps Porto Get-Together.

## What is Flyway?

Flyway is an open-source database migration tool that tracks and executes versioned SQL migration scripts. It ensures:

- **Version control** for database schema
- **Reproducibility** across environments
- **Consistency** between development and production
- **Auditability** of all schema changes

## Migration File Naming Convention

All migration files follow Flyway's naming convention:

### Versioned Migrations
```
V<version>__<description>.sql
```

- `V` = Versioned migration prefix (required)
- `<version>` = Numeric version (1, 2, 10, etc.) or semantic (1.0.1, etc.)
- `__` = Double underscore separator (required)
- `<description>` = Migration description (underscores replace spaces)

### Examples
```
V1__create_initial_schema.sql       # Create base tables
V2__seed_initial_data.sql           # Insert sample data
V3__add_event_status_column.sql     # Add new column
V4__create_indexes.sql              # Create performance indexes
V5__add_foreign_keys.sql            # Add referential integrity
```

### Undo Migrations (Optional)
```
U<version>__<description>.sql
```

Used to undo changes if needed (requires Flyway Teams edition).

## Running Migrations

### With Docker Compose (Recommended)

Migrations run automatically when starting the containers:

```bash
docker-compose up
```

The PostgreSQL service will:
1. Build the custom Docker image with Flyway
2. Initialize the database
3. Run all pending migrations in order
4. Report execution status

### With Flyway CLI (for local development)

Install Flyway CLI:

```bash
# macOS
brew install flyway

# Linux
curl -fL https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/9.22.3/flyway-commandline-9.22.3-linux-x64.tar.gz | tar xvz
# Add flyway to PATH

# Windows
choco install flyway-commandline
```

Run migrations:

```bash
flyway -url=jdbc:postgresql://localhost:5432/workshop_db \
  -user=workshop_user \
  -password=workshop_pass \
  -locations=filesystem:./database/migrations \
  migrate
```

Check migration status:

```bash
flyway -url=jdbc:postgresql://localhost:5432/workshop_db \
  -user=workshop_user \
  -password=workshop_pass \
  -locations=filesystem:./database/migrations \
  info
```

Validate migrations:

```bash
flyway -url=jdbc:postgresql://localhost:5432/workshop_db \
  -user=workshop_user \
  -password=workshop_pass \
  -locations=filesystem:./database/migrations \
  validate
```

## Schema Versioning Tracking

Flyway automatically creates a `flyway_schema_history` table that tracks:

```sql
SELECT * FROM flyway_schema_history;
```

Columns:
- `installed_rank`: Order of execution
- `version`: Migration version
- `description`: Migration description
- `type`: Migration type (SQL, JDBC, etc.)
- `script`: Migration filename
- `checksum`: File integrity hash
- `installed_by`: Database user who ran migration
- `installed_on`: Timestamp of execution
- `execution_time`: Duration in milliseconds
- `success`: Whether migration succeeded
