# Analisis Audit Trail & Normalisasi 3NF

**Nama:** Anisa Listiyani  
**NIM:** 12030124120060

## 1. Mengapa Pemisahan Header-Line Lebih Andal (Audit Trail)

Model tabel tunggal (flat journal table) mencampur metadata transaksi
(tanggal, nomor bukti, deskripsi) dengan detail baris (akun, debit, kredit)
dalam satu tabel. Akibatnya:

### 1.1 Redundansi Metadata
Nomor bukti dan tanggal diulang di setiap baris. Jika ada kesalahan
penulisan tanggal, harus update banyak baris → rawan inkonsistensi.

### 1.2 Audit Trail Kabur
Tidak jelas mana yang berubah: apakah header transaksinya, atau baris
debit/kreditnya. Sulit melacak "siapa mengubah apa, kapan".

### 1.3 Sulit Menegakkan Status Posting
Status POSTED hanya boleh dikunci di level header. Kalau flat, setiap
baris harus punya status sendiri → boros & rawan beda status.

Dengan model header-line:
- Metadata disimpan **sekali** di header.
- Perubahan header (misal posting) tercatat terpisah dari perubahan line.
- Auditor bisa fokus ke header untuk melihat kronologi transaksi.
- Reversing entry (jurnal pembalik) dibuat sebagai header baru yang
  mereferensikan header asli → jejak audit utuh.

## 2. Mengapa Model Header-Line Memenuhi 3NF

### 2.1 First Normal Form (1NF)
Semua kolom atomik — tidak ada array/list dalam satu kolom. Setiap baris
unik dengan Primary Key. Terpenuhi.

### 2.2 Second Normal Form (2NF)
Tidak ada partial dependency — setiap kolom non-key bergantung penuh
pada Primary Key. Di `journal_lines`, kolom `debit` dan `credit`
bergantung penuh pada `id` (PK), bukan pada sebagian PK. Terpenuhi.

### 2.3 Third Normal Form (3NF)
Tidak ada transitive dependency — kolom non-key tidak bergantung pada
kolom non-key lain.

Pada model flat:
- `ref_number` → `trx_date` (transitive) karena nomor bukti menentukan tanggal.
- `account_id` → `account_name` (transitive) karena akun menentukan namanya.

Pada model header-line:
- `ref_number` dan `trx_date` hanya ada di `journal_headers`.
- `account_name` hanya ada di `chart_of_accounts`.
- `journal_lines` hanya menyimpan FK (`header_id`, `account_id`) + nilai
  (`debit`, `credit`) → tidak ada transitive dependency. Terpenuhi.

## 3. Kesimpulan

Pemisahan header-line:
1. Memenuhi 3NF → bebas anomali insert/update/delete.
2. Menyediakan fondasi audit trail yang kuat.
3. Memudahkan penegakan constraint (status posting di header, integritas
   nilai di line, FK antar tabel).