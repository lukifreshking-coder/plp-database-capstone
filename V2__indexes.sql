-- V2: Add indexes for common library queries

-- Find books belonging to a tenant
CREATE INDEX idx_books_tenant_title
    ON books (tenant_id, title);

-- Find members belonging to a tenant
CREATE INDEX idx_members_tenant_name
    ON members (tenant_id, full_name);

-- Find loans by tenant and due date
CREATE INDEX idx_loans_tenant_due_date
    ON loans (tenant_id, due_date);

-- Find loans for a particular member
CREATE INDEX idx_loans_member
    ON loans (member_id);

-- Find loans for a particular book
CREATE INDEX idx_loans_book
    ON loans (book_id);

-- Find audit history for a tenant, newest first
CREATE INDEX idx_audit_tenant_changed_at
    ON audit_log (tenant_id, changed_at DESC);