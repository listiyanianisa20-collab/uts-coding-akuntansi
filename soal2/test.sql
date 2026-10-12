-- ============================================
-- SOAL 2: Test Skenario Trigger Persediaan
-- UTS Coding Akuntansi - Anisa Listiyani
-- NIM: 12030124120060
-- ============================================

-- ==========================================
-- RESET DATA (untuk testing dari kondisi bersih)
-- ==========================================
TRUNCATE inventory_transactions RESTART IDENTITY;
UPDATE inventory_items SET stock_qty = 10 WHERE item_id = 'ITM001';
UPDATE inventory_items SET stock_qty = 50 WHERE item_id = 'ITM002';
UPDATE inventory_items SET stock_qty = 20 WHERE item_id = 'ITM003';

-- ==========================================
-- TEST A: Cek stok awal (expected: 10, 50, 20)
-- ==========================================
SELECT item_id, item_name, stock_qty FROM inventory_items ORDER BY item_id;

-- ==========================================
-- TEST B: PURCHASE 5 unit (expected: stok jadi 15)
-- ==========================================
INSERT INTO inventory_transactions (item_id, trx_type, qty)
VALUES ('ITM001', 'PURCHASE', 5);
SELECT item_id, stock_qty FROM inventory_items WHERE item_id = 'ITM001';

-- ==========================================
-- TEST C: SALE 3 unit (expected: stok jadi 12)
-- ==========================================
INSERT INTO inventory_transactions (item_id, trx_type, qty)
VALUES ('ITM001', 'SALE', 3);
SELECT item_id, stock_qty FROM inventory_items WHERE item_id = 'ITM001';

-- ==========================================
-- TEST D: SALE 1000 unit — HARUS ERROR (anti-negative)
-- ==========================================
INSERT INTO inventory_transactions (item_id, trx_type, qty)
VALUES ('ITM001', 'SALE', 1000);
-- EXPECTED: ERROR P0001: Anti-negative inventory: stok ITM001 hanya 12,
--           tidak cukup untuk jual 1000

-- ==========================================
-- TEST E: Cek stok setelah error (expected: masih 12)
-- ==========================================
SELECT item_id, stock_qty FROM inventory_items WHERE item_id = 'ITM001';

-- ==========================================
-- TEST F: Log transaksi (expected: 2 baris sukses saja)
-- ==========================================
SELECT trx_id, item_id, trx_type, qty, trx_date
FROM inventory_transactions
ORDER BY trx_id;

-- ==========================================
-- TEST G: SALE 100 unit ITM002 — HARUS ERROR (stok hanya 50)
-- ==========================================
INSERT INTO inventory_transactions (item_id, trx_type, qty)
VALUES ('ITM002', 'SALE', 100);
-- EXPECTED: ERROR P0001: Anti-negative inventory: stok ITM002 hanya 50,
--           tidak cukup untuk jual 100

-- ==========================================
-- TEST H: SALE 20 unit ITM003 — HARUS SUKSES (stok pas habis jadi 0)
-- ==========================================
INSERT INTO inventory_transactions (item_id, trx_type, qty)
VALUES ('ITM003', 'SALE', 20);
SELECT item_id, stock_qty FROM inventory_items WHERE item_id = 'ITM003';

-- ==========================================
-- VERIFIKASI FINAL
-- ==========================================
-- Log transaksi final (expected: 3 baris sukses)
SELECT trx_id, item_id, trx_type, qty, trx_date
FROM inventory_transactions
ORDER BY trx_id;

-- Stok akhir (expected: ITM001=12, ITM002=50, ITM003=0)
SELECT item_id, item_name, stock_qty FROM inventory_items ORDER BY item_id;