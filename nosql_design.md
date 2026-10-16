# NoSQL Design: Redis Caching for the Library Management System

## 1. Purpose

The Library Management System uses PostgreSQL as its primary relational database. Redis is proposed as an in-memory cache to reduce repeated database queries and improve response times for frequently accessed book information.

Redis will be an additional component, not a replacement for PostgreSQL.

## 2. Data to Cache

The system can cache book details that are frequently requested, including:

- Book ID
- Book title
- ISBN
- Published year
- Number of available copies

## 3. Cache Key Design

Example Redis key:

`library:tenant:1:book:1`

This key identifies book 1 belonging to tenant 1.

Example cached value:

```json
{
  "book_id": 1,
  "title": "Things Fall Apart",
  "isbn": "9780385474542",
  "published_year": 1958,
  "available_copies": 4
}
```

The tenant ID is included in the key to help prevent cache entries from being mixed across libraries.

## 4. Cache-Aside Strategy

The application will use the cache-aside pattern:

1. The application requests a book.
2. It checks Redis for the corresponding cache key.
3. If the data exists, Redis returns the cached result (cache hit).
4. If the data is missing, the application queries PostgreSQL (cache miss).
5. The application stores the retrieved result in Redis with a time-to-live (TTL).
6. The application returns the result to the requester.

## 5. Cache Expiration and Invalidation

Cached book information will have a proposed TTL of five minutes.

When a book's details or available copy count changes, the application should invalidate or update the corresponding Redis key after the PostgreSQL transaction succeeds.

For sensitive operations such as borrowing or returning books, PostgreSQL remains the source of truth. The application must not rely on cached availability to authorize a loan.

## 6. Tenant Isolation and Security

- Include the tenant ID in every tenant-specific cache key.
- Verify the user's authorization before returning cached data.
- Never assume that a cache key alone provides authorization.
- Avoid storing passwords, credentials, or unnecessary personal information in Redis.
- Restrict Redis network access and require authentication and encryption where appropriate.
- Handle cache failures by falling back to PostgreSQL when safe to do so.

## 7. Benefits

- Faster responses for frequently requested book details.
- Fewer repeated read queries against PostgreSQL.
- Better performance under repeated read traffic.
- A clear separation between persistent storage and temporary cached data.

## 8. Limitations and Risks

- Cached information can become stale.
- Cache invalidation must be implemented carefully.
- Redis requires additional configuration, monitoring, and security.
- Cache misses still require PostgreSQL queries.
- Borrowing and returning books require reliable database transactions to prevent incorrect availability counts.

## 9. Conclusion

PostgreSQL remains the authoritative database for library records, loans, and tenant security. Redis can complement PostgreSQL by caching frequently requested book details, provided the application implements tenant-aware keys, authorization checks, expiration, and cache invalidation.