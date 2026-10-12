-- ============================================
-- SOAL 1.2: DDL Skema General Ledger
-- UTS Coding Akuntansi - Anisa Listiyani
-- NIM: 12030124120060
-- ============================================

-- Tabel 1: Chart of Accounts
CREATE TABLE chart_of_accounts (
    account_id      SERIAL PRIMARY KEY,
    account_code    VARCHAR(20)  NOT NULL UNIQUE,
    account_name    VARCHAR(100) NOT NULL,
    normal_balance  VARCHAR(6)   NOT NULL
                    CHECK (normal_balance IN ('DEBIT', 'CREDIT')),
    report_class    VARCHAR(30)  NOT NULL
                    CHECK (report_class IN ('ASET', 'LIABILITAS', 'EKUITAS',
                                            'PENDAPATAN', 'BEBAN'))
);

-- Tabel 2: Journal Headers
CREATE TABLE journal_headers (
    id              SERIAL PRIMARY KEY,
    trx_date        DATE         NOT NULL,
    ref_number      VARCHAR(50)  NOT NULL UNIQUE,
    description     TEXT,
    status_posting  VARCHAR(10)  NOT NULL DEFAULT 'DRAFT'
                    CHECK (status_posting IN ('DRAFT', 'POSTED', 'VOID')),
    created_at      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    created_by      VARCHAR(50)
);

-- Tabel 3: Journal Lines
CREATE TABLE journal_lines (
    id          SERIAL PRIMARY KEY,
    header_id   INT           NOT NULL,
    account_id  INT           NOT NULL,
    debit       NUMERIC(15,2) NOT NULL DEFAULT 0,
    credit      NUMERIC(15,2) NOT NULL DEFAULT 0,

    CONSTRAINT fk_line_header
        FOREIGN KEY (header_id) REFERENCES journal_headers(id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_line_account
        FOREIGN KEY (account_id) REFERENCES chart_of_accounts(account_id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_debit_nonneg  CHECK (debit  >= 0),
    CONSTRAINT chk_credit_nonneg CHECK (credit >= 0),
    CONSTRAINT chk_not_both_zero CHECK (NOT (debit = 0 AND credit = 0)),
    CONSTRAINT chk_one_side_only CHECK (
        (debit > 0 AND credit = 0) OR
        (credit > 0 AND debit = 0)
    )
);