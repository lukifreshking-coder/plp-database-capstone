# Library Management System — Requirements

## Project Purpose
The Library Management System manages books, authors, members, and borrowing records. It helps library staff organize information and identify overdue books.

## Functional Requirements
1. Register libraries and members.
2. Store books, ISBN numbers, categories, and publication years.
3. Record authors and their books.
4. Record book loans, due dates, and return dates.
5. Identify active and overdue loans.
6. Record changes to important database records.
7. Restrict access to each library's private data.

## Non-Functional Requirements
- Use primary keys and foreign keys to maintain data integrity.
- Use indexes to improve query performance where appropriate.
- Apply database access controls and row-level security.
- Use versioned Flyway migrations.
- Create backups and test restoring them.
- Use Redis to cache frequently accessed book information.

## Main Users
- Library staff
- Library managers
- Database administrators

## Technologies
PostgreSQL will store relational data. Flyway will manage database migrations. Redis will provide an optional cache for frequently accessed catalog information.

## Security and Recovery
The system will use restricted database roles, audit logging, parameterized queries, row-level security, and tested backups.

## Project Scope
The project covers database design, schema migrations, caching, query optimization, security, backup, and presentation. A full website is outside the initial scope.