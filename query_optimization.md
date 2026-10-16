# Query Optimization Report

## 1. Objective

The purpose of this test is to inspect PostgreSQL query execution plans and evaluate the use of an existing database index in the Library Management System.

## 2. Existing Index

Migration V2 creates the following index:

```sql
CREATE INDEX idx_books_tenant_title
ON books (tenant_id, title);
```

This composite index supports queries that search for books using a tenant ID and title.

## 3. Test 1: Exact Title Search

### SQL Query

```sql
EXPLAIN ANALYZE
SELECT book_id, title, available_copies
FROM books
WHERE tenant_id = 1
  AND title = 'The Alchemist';
```

### Observed Result

- Scan method: Index Scan
- Index used: `idx_books_tenant_title`
- Rows returned: 1
- Execution time: 0.209 ms
- Shared buffer hits: 5

### Interpretation

PostgreSQL used the composite index to locate the book matching tenant 1 and the exact title. The query returned one row.

## 4. Test 2: Title Prefix Search

### SQL Query

```sql
EXPLAIN ANALYZE
SELECT book_id, title
FROM books
WHERE tenant_id = 1
  AND title LIKE 'The%';
```

### Observed Result

- Scan method: Index Scan
- Index used: `idx_books_tenant_title`
- Rows returned: 1
- Rows removed by filter: 1
- Execution time: 0.043 ms
- Shared buffer hits: 2

### Interpretation

PostgreSQL used the index to find rows for tenant 1, then applied the title prefix filter. One row was removed by the filter. The execution plan shows that the tenant condition was used as the index condition, while the prefix condition was evaluated as a filter.

## 5. Comparison and Limitations

The exact-match query completed in 0.209 ms, while the prefix-search query completed in 0.043 ms during these individual runs.

These times are observations from a very small demonstration dataset. They do not prove that one query is generally faster than the other because query complexity, caching, planning overhead, and system load can affect measurements.

Both plans used the existing composite index. A sequential scan might be more efficient for a very small table, and PostgreSQL chooses plans based on its estimates and available statistics.

## 6. Recommendations

- Keep the composite index for common tenant-and-title searches.
- Use `EXPLAIN ANALYZE` to evaluate actual query execution plans.
- Test with a larger representative dataset before drawing conclusions about performance.
- Avoid creating unnecessary indexes because indexes consume storage and can increase the cost of inserts, updates, and deletes.
- Repeat measurements under consistent conditions when comparing alternative query designs.

## 7. Conclusion

Both tested queries used `idx_books_tenant_title`. The measured execution times were 0.209 ms for the exact-match query and 0.043 ms for the prefix-search query. These results confirm index usage for the tested data, but larger-scale tests are needed to evaluate real-world performance benefits.