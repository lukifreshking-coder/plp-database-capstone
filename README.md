# Library Management System — Database Capstone

## Project Overview

This project implements the database foundation for a multi-tenant Library Management System using PostgreSQL and Flyway.

It supports libraries, books, authors, members, loans, audit logging, tenant-level row security, database indexes, and sample data.

## Technologies

- PostgreSQL 18
- Flyway Community Edition 13
- SQL
- PowerShell
- Redis caching design (documented proposal)

## Features

- Relational tables with primary keys and foreign keys
- Constraints to protect data integrity
- Indexes for common book, member, loan, and audit queries
- Audit triggers for changes to books and members
- Row-Level Security policies for tenant-specific data
- Version-controlled SQL migrations
- Sample data for demonstration and testing
- Custom-format PostgreSQL backups
- Backup restoration test in a separate database
- Query execution analysis with `EXPLAIN ANALYZE`
- Proposed Redis cache-aside design

## Project Structure

```text
library-capstone/
├── backups/
├── docs/
│   ├── requirements.md
│   ├── er_diagram.mmd
│   ├── nosql_design.md
│   └── query_optimization.md
├── migrations/
│   ├── V1__core_tables.sql
│   ├── V2__indexes.sql
│   ├── V3__audit_triggers.sql
│   ├── V4__row_level_security.sql
│   └── V5__seed_demo_data.sql
├── scripts/
│   ├── backup.ps1
│   └── restore_test.ps1
└── README.md
```

## Database Setup

1. Install PostgreSQL and Flyway.
2. Create a database named `library_capstone`.
3. Configure Flyway's connection URL, username, and password using environment variables.
4. Run the migrations from the project root:

```powershell
flyway -locations="filesystem:migrations" info
flyway -locations="filesystem:migrations" migrate
```

Do not commit database passwords or other secrets to version control.

## Security

The project enables Row-Level Security for books, members, loans, and audit logs. Tenant access was tested using a restricted PostgreSQL role and the `app.tenant_id` session setting.

For production use, tenant identity must be established by trusted application code. The application role must not be a superuser, table owner with unrestricted access, or a role with `BYPASSRLS`.

## Backup and Restore Testing

Create a database backup from PowerShell:

```powershell
.\scripts\backup.ps1
```

Test restoring the latest backup into a separate database:

```powershell
.\scripts\restore_test.ps1
```

The restore test uses `library_capstone_restore_test`, not the original database.

## Query Optimization

The report in `docs/query_optimization.md` documents actual `EXPLAIN ANALYZE` results for two book searches. Both queries used the `idx_books_tenant_title` index on the sample dataset.

## NoSQL Design

The proposed Redis design is documented in `docs/nosql_design.md`. PostgreSQL remains the authoritative database; Redis is proposed for caching frequently accessed book details.

## Current Scope and Limitations

This project focuses on the database layer and supporting documentation. The Redis component is a design proposal, not an implemented or tested Redis deployment. Performance measurements are from a small demonstration dataset and are not a production benchmark.

## Author

Database Capstone Project — Library Management System
