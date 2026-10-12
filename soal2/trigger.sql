-- ============================================
-- SOAL 2.1: Trigger Otomatisasi Mutasi Stok
-- UTS Coding Akuntansi - Anisa Listiyani
-- NIM: 12030124120060
-- ============================================

CREATE OR REPLACE FUNCTION trg_update_stock_and_journal()
RETURNS TRIGGER AS $$
DECLARE
    v_current_stock INT;
BEGIN
    -- =========================================
    -- Ambil stok saat ini DENGAN LOCK baris
    -- (mencegah race condition / overselling)
    -- =========================================
    SELECT stock_qty INTO v_current_stock
    FROM inventory_items
    WHERE item_id = NEW.item_id
    FOR UPDATE;

    -- Kalau item tidak ditemukan
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Item % tidak ditemukan di inventory_items', NEW.item_id;
    END IF;

    -- =========================================
    -- Logika berdasarkan tipe transaksi
    -- =========================================

    IF NEW.trx_type = 'PURCHASE' THEN
        -- Pembelian: stok bertambah
        UPDATE inventory_items
        SET stock_qty = stock_qty + NEW.qty
        WHERE item_id = NEW.item_id;

    ELSIF NEW.trx_type = 'SALE' THEN
        -- Penjualan: cek dulu stok cukup atau tidak
        IF (v_current_stock - NEW.qty) < 0 THEN
            RAISE EXCEPTION
                'Anti-negative inventory: stok % hanya %, tidak cukup untuk jual %',
                NEW.item_id, v_current_stock, NEW.qty;
        END IF;

        UPDATE inventory_items
        SET stock_qty = stock_qty - NEW.qty
        WHERE item_id = NEW.item_id;

    ELSIF NEW.trx_type = 'ADJUSTMENT' THEN
        -- Adjustment: stok berkurang sesuai qty
        IF (v_current_stock - NEW.qty) < 0 THEN
            RAISE EXCEPTION
                'Adjustment menyebabkan stok negatif: stok % hanya %, adjustment %',
                NEW.item_id, v_current_stock, NEW.qty;
        END IF;

        UPDATE inventory_items
        SET stock_qty = stock_qty - NEW.qty
        WHERE item_id = NEW.item_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Pasang trigger ke tabel inventory_transactions
DROP TRIGGER IF EXISTS trigger_update_stock ON inventory_transactions;

CREATE TRIGGER trigger_update_stock
AFTER INSERT ON inventory_transactions
FOR EACH ROW
EXECUTE FUNCTION trg_update_stock_and_journal();