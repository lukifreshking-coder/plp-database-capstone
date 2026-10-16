-- V3: Automatically record changes to books and members

CREATE OR REPLACE FUNCTION log_library_change()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    affected_tenant_id BIGINT;
    affected_record_id BIGINT;
BEGIN
    IF TG_TABLE_NAME = 'books' THEN
        IF TG_OP = 'DELETE' THEN
            affected_tenant_id := OLD.tenant_id;
            affected_record_id := OLD.book_id;
        ELSE
            affected_tenant_id := NEW.tenant_id;
            affected_record_id := NEW.book_id;
        END IF;
    ELSIF TG_TABLE_NAME = 'members' THEN
        IF TG_OP = 'DELETE' THEN
            affected_tenant_id := OLD.tenant_id;
            affected_record_id := OLD.member_id;
        ELSE
            affected_tenant_id := NEW.tenant_id;
            affected_record_id := NEW.member_id;
        END IF;
    END IF;

    INSERT INTO audit_log (tenant_id, table_name, action, record_id)
    VALUES (affected_tenant_id, TG_TABLE_NAME, TG_OP, affected_record_id);

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER books_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON books
FOR EACH ROW EXECUTE FUNCTION log_library_change();

CREATE TRIGGER members_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON members
FOR EACH ROW EXECUTE FUNCTION log_library_change();