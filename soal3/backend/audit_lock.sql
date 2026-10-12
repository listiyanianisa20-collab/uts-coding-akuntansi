-- ============================================
-- SOAL 3.2: Mekanisme Audit Trail & Immutability
-- UTS Coding Akuntansi - Anisa Listiyani
-- NIM: 12030124120060
-- ============================================

-- =============================================
-- 1. Fungsi trigger untuk mencegah UPDATE/DELETE
--    pada jurnal yang berstatus POSTED
-- =============================================
CREATE OR REPLACE FUNCTION prevent_posted_modification()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status_posting = 'POSTED' AND TG_OP IN ('UPDATE', 'DELETE') THEN
        RAISE EXCEPTION
            'Jurnal POSTED tidak dapat diubah/dihapus. '
            'Gunakan reversing entry (jurnal pembalik). '
            'Header ID: %', OLD.id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Pasang trigger di journal_headers
DROP TRIGGER IF EXISTS trg_immutable_headers ON journal_headers;
CREATE TRIGGER trg_immutable_headers
BEFORE UPDATE OR DELETE ON journal_headers
FOR EACH ROW
EXECUTE FUNCTION prevent_posted_modification();

-- Pasang trigger di journal_lines (immutability juga berlaku di line)
DROP TRIGGER IF EXISTS trg_immutable_lines ON journal_lines;
CREATE TRIGGER trg_immutable_lines
BEFORE UPDATE OR DELETE ON journal_lines
FOR EACH ROW
EXECUTE FUNCTION prevent_posted_modification();

-- =============================================
-- 2. Fungsi untuk generate hash checksum
--    (untuk verifikasi integritas data)
-- =============================================
CREATE OR REPLACE FUNCTION generate_journal_hash(
    p_header_id INT
) RETURNS TEXT AS $$
DECLARE
    v_payload TEXT;
    v_hash    TEXT;
BEGIN
    -- Gabungkan semua data jurnal menjadi 1 string
    SELECT 
        h.id::TEXT || '|' || 
        h.trx_date::TEXT || '|' ||
        h.ref_number || '|' ||
        COALESCE(h.description, '') || '|' ||
        COALESCE(h.created_by, '') || '|' ||
        COALESCE(
            STRING_AGG(
                l.account_id::TEXT || ':' || 
                l.debit::TEXT || ':' || 
                l.credit::TEXT, 
                ','
                ORDER BY l.id
            ),
            ''
        )
    INTO v_payload
    FROM journal_headers h
    LEFT JOIN journal_lines l ON l.header_id = h.id
    WHERE h.id = p_header_id
    GROUP BY h.id, h.trx_date, h.ref_number, h.description, h.created_by;

    -- Hash SHA-256
    v_hash := encode(digest(v_payload, 'sha256'), 'hex');
    
    RETURN v_hash;
END;
$$ LANGUAGE plpgsql;