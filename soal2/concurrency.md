# Analisis Concurrency (Race Condition) pada Sistem Persediaan

**Nama:** Anisa Listiyani  
**NIM:** 12030124120060

## 1. Skenario Masalah

Bayangkan terdapat dua kasir (Kasir A dan Kasir B) yang memproses
penjualan untuk **item yang sama** pada **detik yang bersamaan**.
Stok item tersebut hanya tersisa **1 unit**.

### Tanpa Proteksi (Race Condition)
