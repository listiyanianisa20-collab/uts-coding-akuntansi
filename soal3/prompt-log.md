# Dokumentasi Prompt AI — Gemini Canvas

**Nama:** Anisa Listiyani  
**NIM:** 12030124120060  
**Tool:** Gemini Canvas (https://gemini.google.com)  
**Tanggal:** [isi tanggal hari ini, misal: 19 Oktober 2026]

---

## 1. Tujuan

Menggunakan Gemini Canvas untuk meng-generate kode purwarupa formulir
**Voucher Kas Keluar** berbasis web (HTML + Tailwind CSS + vanilla
JavaScript) yang memiliki fitur:

1. Input header jurnal (tanggal, nomor referensi, deskripsi)
2. Tabel baris jurnal dinamis (tambah/hapus baris)
3. Dropdown akun untuk tiap baris
4. Validasi satu sisi (kalau debit diisi, kredit disable, dan sebaliknya)
5. Live balance indicator (Total Debit vs Total Kredit)
6. Tombol Submit yang hanya aktif saat form balance & lengkap
7. Styling modern dengan Tailwind CSS

---

## 2. Prompt yang Digunakan

> Buatkan formulir entri jurnal akuntansi "Voucher Kas Keluar"
> menggunakan HTML + Tailwind CSS + JavaScript murni (vanilla JS).
> Hasilkan dalam SATU file HTML lengkap yang bisa langsung dibuka
> di browser tanpa setup apapun.
>
> Fitur wajib:
> 1. Bagian HEADER form:
>    - Input "Tanggal Transaksi" (type=date)
>    - Input "Nomor Referensi" (text, wajib diisi, misal: VKK-001)
>    - Input "Deskripsi" (textarea, opsional)
>
> 2. Bagian DETAIL JURNAL:
>    - Tabel dengan kolom: Akun, Debit, Kredit, dan tombol Hapus
>    - Tombol "+ Tambah Baris" untuk menambah baris baru
>    - Setiap baris punya dropdown akun (contoh: Kas, Beban Gaji,
>      Beban Listrik, Beban Sewa, Beban Transport)
>    - Input debit dan input kredit (type=number)
>    - Setiap baris hanya boleh salah satu terisi: kalau debit diisi,
>      kredit otomatis dikosongkan & disable, dan sebaliknya
>
> 3. Bagian LIVE BALANCE INDICATOR:
>    - Tampilkan "Total Debit: Rp xxx"
>    - Tampilkan "Total Kredit: Rp xxx"
>    - Tampilkan "Selisih: Rp xxx"
>    - Kalau Total Debit = Total Kredit (dan > 0): tampilan HIJAU
>      dengan tulisan "BALANCE"
>    - Kalau tidak balance: tampilan MERAH dengan tulisan "TIDAK BALANCE"
>    - Format angka otomatis dengan pemisah ribuan (titik)
>
> 4. Bagian SUBMIT:
>    - Tombol "Submit" hanya aktif (enabled) kalau:
>      * Nomor referensi tidak kosong
>      * Minimal ada 1 baris jurnal
>      * Total Debit = Total Kredit, dan > 0
>    - Kalau tombol diklik, tampilkan alert berisi JSON data form
>
> 5. Styling:
>    - Gunakan Tailwind CSS via CDN
>    - Desain modern, warna netral (abu-abu/biru), rapi & profesional
>    - Responsive untuk layar desktop
>    - Header form dengan judul "VOUCHER KAS KELUAR" dan subjudul
>      "PT Diponegoro Logistik Utama"
>
> Buat sekaligus dalam satu file HTML. Sertakan komentar singkat di
> setiap bagian kode.

---

## 3. Hasil Output Gemini Canvas

Gemini menghasilkan **satu file HTML lengkap** dengan struktur:

### 3.1 Bagian `<head>`
- Meta charset UTF-8, viewport
- Import Tailwind CSS via CDN (`https://cdn.tailwindcss.com`)
- Import Google Fonts "Inter"
- Custom style: `font-family: 'Inter'`

### 3.2 Bagian `<body>`
- **Container utama**: `max-w-4xl`, background putih, shadow, rounded
- **Header form**: gradient biru-indigo, judul "VOUCHER KAS KELUAR",
  subjudul "PT Diponegoro Logistik Utama"
- **Section input header**: field tanggal, nomor referensi, deskripsi
- **Section detail jurnal**: tabel dengan kolom Akun, Debit, Kredit, Aksi
- **Section balance indicator**: 3 kartu menampilkan Total Debit,
  Total Kredit, Selisih + status BALANCE/TIDAK BALANCE
- **Section footer**: tombol Reset dan Submit

### 3.3 Bagian `<script>`
Fungsi JavaScript yang di-generate:
- `addRow()` — menambah baris jurnal baru ke tabel
- `removeRow(button)` — menghapus baris
- `formatRupiah(angka)` — format angka dengan pemisah ribuan
- `updateTotals()` — hitung total debit/kredit secara live
- `updateBalanceIndicator()` — ubah warna & teks indikator
- `validateForm()` — aktif/nonaktifkan tombol Submit
- `handleSideInput()` — pastikan hanya satu sisi (debit/kredit) terisi
- `submitForm()` — tampilkan JSON data form via alert

---

## 4. Verifikasi Manual

Setelah kode digenerate, dilakukan pengujian manual di browser:

| No | Fitur | Status |
|----|-------|--------|
| 1 | Tombol "+ Tambah Baris" menambah baris baru | ✅ |
| 2 | Tombol Hapus menghapus baris | ✅ |
| 3 | Input debit otomatis mengosongkan & disable kredit | ✅ |
| 4 | Total Debit/Kredit update live saat input berubah | ✅ |
| 5 | Indikator berubah hijau saat balance | ✅ |
| 6 | Indikator berubah merah saat tidak balance | ✅ |
| 7 | Tombol Submit disabled saat belum balance | ✅ |
| 8 | Tombol Submit enabled saat balance & referensi terisi | ✅ |
| 9 | Format rupiah dengan pemisah titik (5.000.000) | ✅ |
| 10 | Tombol Submit menampilkan JSON saat diklik | ✅ |

---

## 5. Screenshot Hasil

*(Sisipkan screenshot di laporan PDF)*

- **Gambar**: Form dalam kondisi BALANCE (indikator hijau)
- **Gambar**: Form dalam kondisi TIDAK BALANCE (indikator merah)

---

## 6. Catatan Iterasi

*(Isi kalau ada prompt tambahan ke Gemini)*

Contoh:
- Iterasi 1: minta tambah tombol Reset
- Iterasi 2: minta ubah warna header jadi biru-indigo

---

## 7. Kesimpulan

Gemini Canvas berhasil menghasilkan kode HTML form Voucher Kas Keluar
sesuai spesifikasi prompt. Seluruh fitur wajib (live balance indicator,
validasi satu sisi, tombol Submit kondisional) berjalan dengan baik
tanpa perlu banyak iterasi. Kode dapat langsung dijalankan di browser
tanpa setup tambahan karena menggunakan CDN Tailwind CSS.