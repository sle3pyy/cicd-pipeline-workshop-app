# Flyway Database Migration Setup

## Overview

Flyway is an open-source database migration tool that manages versioned SQL scripts. It ensures database schema consistency across environments and maintains a complete audit trail of all schema changes.

## Flyway Configuration

### Core Requirements
1. **Versioned migration files**: `database/migrations/V<version>__<description>.sql`
2. **Optional undo migrations**: `database/migrations/U<version>__<description>.sql` (Teams edition only)
3. **Schema history table**: `flyway_schema_history` (auto-created) - tracks executed migrations

### Migration Naming Convention

```
V<version>__<description>.sql
```

- `V` = Versioned migration prefix (required)
- `<version>` = Timestamp format (e.g., `20260408.1600`) or numeric versioning
- `__` = Double underscore separator (required)
- `<description>` = Description with underscores replacing spaces

## Current Migrations Status

### ✅ Schema Creation Migrations

| Version | File | Description | Status |
|---------|------|-------------|--------|
| V20260408.1600 | `Create_TB_members.sql` | Create members table with indexes | ✅ Implemented |
| V20260408.1602 | `Create_TB_events.sql` | Create events table with indexes | ✅ Implemented |
| V20260408.1604 | `Create_TB_event_registration.sql` | Create event_registrations junction table | ✅ Implemented |

### ✅ Data Seeding Migrations

| Version | File | Description | Status |
|---------|------|-------------|--------|
| V202060408.1610 | `Insert_TB_members.sql` | Seed sample member data | ✅ Implemented |
| V202060408.1612 | `Insert_TB_events.sql` | Seed sample event data | ✅ Implemented |
| V202060408.1614 | `Insert_TB_event_registrations.sql` | Seed sample registrations | ✅ Implemented |

## Creating New Migrations

When adding new features or schema changes:

```bash
# 1. Create new migration file with timestamp
V<YYYYMMDD>.<HHMM>__<description>.sql

# 2. Add SQL statements for the change
CREATE TABLE || ALTER TABLE || INSERT || etc.

# 3. Test locally
docker-compose down -v
docker-compose up

# 4. Verify execution
docker-compose logs postgres | grep -i flyway
```
