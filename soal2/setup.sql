-- ============================================
-- SOAL 2: Setup Tabel Persediaan
-- UTS Coding Akuntansi - Anisa Listiyani
-- NIM: 12030124120060
-- ============================================

-- Tabel 1: Master item persediaan
CREATE TABLE inventory_items (
    item_id     VARCHAR(10) PRIMARY KEY,
    item_name   VARCHAR(100) NOT NULL,
    stock_qty   INT NOT NULL DEFAULT 0,
    unit_cost   NUMERIC(15,2) NOT NULL,

    -- Constraint: stok & harga tidak boleh negatif
    CONSTRAINT chk_stock_nonneg CHECK (stock_qty >= 0),
    CONSTRAINT chk_cost_nonneg  CHECK (unit_cost >= 0)
);

-- Tabel 2: Transaksi persediaan
CREATE TABLE inventory_transactions (
    trx_id      SERIAL PRIMARY KEY,
    item_id     VARCHAR(10) NOT NULL,
    trx_type    VARCHAR(10) NOT NULL
                CHECK (trx_type IN ('PURCHASE', 'SALE', 'ADJUSTMENT')),
    qty         INT NOT NULL,
    trx_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- FK ke inventory_items
    CONSTRAINT fk_trx_item
        FOREIGN KEY (item_id) REFERENCES inventory_items(item_id)
        ON DELETE RESTRICT,

    -- Qty harus > 0
    CONSTRAINT chk_qty_positive CHECK (qty > 0)
);

-- Seed data awal (3 item untuk testing)
INSERT INTO inventory_items (item_id, item_name, stock_qty, unit_cost) VALUES
    ('ITM001', 'Laptop Asus ROG',   10, 15000000),
    ('ITM002', 'Mouse Logitech',    50, 150000),
    ('ITM003', 'Keyboard Mekanik',  20, 800000);