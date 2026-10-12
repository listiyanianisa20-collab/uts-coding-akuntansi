# Mekanisme Jejak Audit (Audit Trail) & Immutability

**Nama:** Anisa Listiyani  
**NIM:** 12030124120060

---

## 1. Latar Belakang

Auditor internal meminta agar setiap jurnal yang sudah berstatus
POSTED tidak dapat diubah maupun dihapus. Koreksi hanya boleh
dilakukan melalui jurnal pembalik (reversing entry / storno).
Selain itu, sistem harus menyimpan jejak lengkap tentang siapa
yang membuat jurnal, kapan dibuat, dan menjamin integritas
datanya.

---

## 2. Immutability Jurnal POSTED

### 2.1 Implementasi

Immutability ditegakkan di level database melalui BEFORE UPDATE
OR DELETE trigger pada tabel journal_headers dan journal_lines:

- Fungsi: prevent_posted_modification()
- Logika: Jika OLD.status_posting = 'POSTED' dan operasi
  adalah UPDATE atau DELETE, maka RAISE EXCEPTION dan transaksi
  dibatalkan.

### 2.2 Alur Kerja

1. User membuat jurnal (status: DRAFT) -> Bisa diedit bebas
2. User posting jurnal (status: POSTED) -> Tidak bisa diedit/dihapus
3. Kalau ada kesalahan: Buat jurnal pembalik (reversing entry)
   dengan debit/kredit terbalik, referensi ke jurnal asli

### 2.3 Mengapa Bukan Update Direct?

Kalau jurnal POSTED boleh diedit langsung:
- Jejak audit hilang: auditor tidak tahu nilai asli sebelum diubah
- Fraud risk: user bisa manipulasi laporan dengan edit diam-diam
- Tidak sesuai standar: SAK/PSAK mensyaratkan immutability
  untuk buku besar yang sudah diposting

Dengan reversing entry:
- Jurnal asli tetap ada di sistem
- Jurnal pembalik tercatat sebagai transaksi baru
- Auditor bisa lihat kronologi lengkap

---

## 3. Field Audit Trail

Setiap jurnal di journal_headers memiliki field audit:

| Field | Tipe | Fungsi |
|-------|------|--------|
| created_by | VARCHAR(50) | Username/ID pembuat jurnal |
| created_at | TIMESTAMP | Waktu pembuatan (otomatis) |
| status_posting | VARCHAR(10) | DRAFT / POSTED / VOID |
| hash_checksum | TEXT | Hash SHA-256 untuk verifikasi integritas |

---

## 4. Hash Checksum untuk Verifikasi Integritas

### 4.1 Fungsi generate_journal_hash(header_id)

Fungsi ini menggabungkan semua data jurnal menjadi satu string
payload, lalu menghitung hash SHA-256-nya.

Payload terdiri dari:
- ID header
- Tanggal transaksi
- Nomor referensi
- Deskripsi
- Created_by
- String gabungan semua baris: account_id:debit:credit per baris

Output: String hex 64 karakter (SHA-256).

### 4.2 Kegunaan

Hash checksum berguna untuk:

1. Deteksi manipulasi: kalau ada yang mengubah data di
   database secara langsung (bypass trigger), hash akan berubah.
2. Verifikasi berkala: auditor bisa re-generate hash dan
   bandingkan dengan nilai yang tersimpan.
3. Audit forensik: bukti matematis bahwa data tidak dimodifikasi.

### 4.3 Contoh Penggunaan

Simpan hash saat jurnal diposting:

    UPDATE journal_headers 
    SET hash_checksum = generate_journal_hash(id)
    WHERE id = 1 AND status_posting = 'POSTED';

Verifikasi berkala:

    SELECT id, ref_number, hash_checksum,
           generate_journal_hash(id) AS hash_terkini
    FROM journal_headers
    WHERE status_posting = 'POSTED';

---

## 5. Reversing Entry (Jurnal Pembalik)

### 5.1 Konsep

Reversing entry adalah jurnal baru yang membalik efek jurnal
asli. Misal jurnal asli:

| Akun | Debit | Kredit |
|------|-------|--------|
| Beban Gaji | 5.000.000 | - |
| Kas | - | 5.000.000 |

Kalau ternyata salah dan sudah POSTED, buat reversing entry:

| Akun | Debit | Kredit |
|------|-------|--------|
| Kas | 5.000.000 | - |
| Beban Gaji | - | 5.000.000 |

Deskripsi: "Reversing entry untuk VKK-001 (salah input)"

### 5.2 Fungsi Backend (Contoh FastAPI)

    @app.post("/journal/{header_id}/reverse")
    async def reverse_journal(header_id: int, reason: str):
        # 1. Ambil jurnal asli
        original = await db.fetch_one(
            "SELECT * FROM journal_headers WHERE id = :id",
            {"id": header_id}
        )
        
        if original['status_posting'] != 'POSTED':
            raise HTTPException(400, "Hanya POSTED yang bisa di-reverse")
        
        # 2. Buat header baru (jurnal pembalik)
        new_header = await db.fetch_one(
            """INSERT INTO journal_headers 
               (trx_date, ref_number, description, status_posting, created_by)
               VALUES (:date, :ref, :desc, 'DRAFT', :user)
               RETURNING id""",
            {
                "date": date.today(),
                "ref": f"REV-{original['ref_number']}",
                "desc": f"Reversing entry untuk {original['ref_number']}",
                "user": current_user
            }
        )
        
        # 3. Copy lines dengan debit/kredit ditukar
        original_lines = await db.fetch_all(
            "SELECT * FROM journal_lines WHERE header_id = :id",
            {"id": header_id}
        )
        
        for line in original_lines:
            await db.execute(
                """INSERT INTO journal_lines 
                   (header_id, account_id, debit, credit)
                   VALUES (:h, :a, :d, :c)""",
                {
                    "h": new_header['id'],
                    "a": line['account_id'],
                    "d": line['credit'],  # swapped
                    "c": line['debit']    # swapped
                }
            )
        
        # 4. Tandai jurnal asli sebagai VOID
        await db.execute(
            "UPDATE journal_headers SET status_posting = 'VOID' WHERE id = :id",
            {"id": header_id}
        )
        
        return {"reversing_header_id": new_header['id']}

---

## 6. Test Immutability yang Dilakukan

| No | Skenario | Expected | Actual |
|----|----------|----------|--------|
| 1 | UPDATE jurnal DRAFT | Berhasil | Berhasil |
| 2 | UPDATE jurnal POSTED | ERROR | ERROR muncul |
| 3 | DELETE jurnal POSTED | ERROR | ERROR muncul |
| 4 | Generate hash SHA-256 | 64 char hex | 64 char hex |

Screenshot test 2, 3, dan 4 tersimpan sebagai lampiran laporan.

---

## 7. Kesimpulan

Mekanisme audit trail yang diterapkan:

| Aspek | Implementasi |
|-------|--------------|
| Immutability | Trigger prevent_posted_modification() di DB |
| Audit user | Field created_by dan created_at |
| Integritas | Hash SHA-256 via generate_journal_hash() |
| Koreksi | Reversing entry, bukan edit langsung |
| Status flow | DRAFT -> POSTED -> VOID (jika di-reverse) |

Dengan kombinasi ini, sistem memenuhi prinsip:

- Auditability: semua perubahan terlacak
- Integrity: data tidak bisa dimanipulasi diam-diam
- Compliance: sesuai standar akuntansi & audit internal