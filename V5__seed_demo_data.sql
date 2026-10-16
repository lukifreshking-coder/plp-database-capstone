-- V5: Insert demonstration data for the Library Management System

INSERT INTO tenants (tenant_name)
VALUES
    ('Central Library'),
    ('Community Library');

INSERT INTO authors (author_name)
VALUES
    ('Chinua Achebe'),
    ('Paulo Coelho'),
    ('Robert C. Martin');

INSERT INTO books
    (tenant_id, title, isbn, published_year, available_copies)
VALUES
    (1, 'Things Fall Apart', '9780385474542', 1958, 4),
    (1, 'The Alchemist', '9780061122415', 1988, 3),
    (2, 'Clean Code', '9780132350884', 2008, 2);

INSERT INTO book_authors (book_id, author_id)
VALUES
    (1, 1),
    (2, 2),
    (3, 3);

INSERT INTO members (tenant_id, full_name, email)
VALUES
    (1, 'Amina Hassan', 'amina@example.com'),
    (1, 'Brian Otieno', 'brian@example.com'),
    (2, 'Fatuma Ali', 'fatuma@example.com');

INSERT INTO loans
    (tenant_id, book_id, member_id, loan_date, due_date)
VALUES
    (1, 1, 1, CURRENT_DATE - 3, CURRENT_DATE + 11),
    (1, 2, 2, CURRENT_DATE - 2, CURRENT_DATE + 12),
    (2, 3, 3, CURRENT_DATE - 1, CURRENT_DATE + 13);