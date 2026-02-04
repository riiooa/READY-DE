Sales & HR Analytics Project (PostgreSQL)
Proyek ini mendemonstrasikan pengelolaan database end-to-end, mulai dari perancangan skema dan optimasi query hingga analisis Business Intelligence tingkat lanjut menggunakan PostgreSQL.

🛠 Tech Stack
Database: PostgreSQL 15

Environment: Docker Desktop, WSL 2 (Ubuntu)

Tool: DBeaver

🚀 Cara Menjalankan
Jalankan container PostgreSQL melalui terminal:

Bash
docker run --name de-sql -e POSTGRES_USER=user -e POSTGRES_PASSWORD=1234 -e POSTGRES_DB=sales -p 5431:5432 -d postgres:15
📈 Kurikulum & Materi Teknis
Proyek ini dibagi menjadi beberapa modul yang mencakup fundamental hingga teknik Advanced Data Engineering:

1. Database Schema & Optimization
Schema Design: Perancangan tabel products, orders, departments, dan employees dengan relasi kunci asing (Foreign Keys).

Indexing Strategy: Implementasi B-Tree Index dan Composite Index untuk mempercepat performa query pada jutaan data.

Performance Profiling: Menggunakan EXPLAIN ANALYZE untuk membedah Query Plan dan mengoptimalkan kecepatan eksekusi.

2. Advanced Analytics (Window Functions)
Ranking & Distribution: Segmentasi performa menggunakan RANK(), DENSE_RANK(), dan NTILE().

Time-Series Analysis: Menghitung Month-over-Month (MoM) Growth dengan LAG() dan Moving Average untuk prediksi tren.

Rolling Calculations: Penggunaan Window Frames (ROWS BETWEEN) untuk perhitungan akumulasi pendapatan bulanan.

3. Business Intelligence Logic
Recursive CTE: Membangun struktur organisasi hierarkis (reporting lines) dari data yang bersifat flat.

Customer Lifetime Value (CLV): Segmentasi pelanggan (Platinum, Gold, Silver) berdasarkan perilaku belanja dan loyalitas.

Gap Analysis: Teknik audit untuk mendeteksi data yang hilang atau terloncat dalam urutan transaksi.

4. Algorithmic SQL (LeetCode Style)
Penyelesaian 10 tantangan logika SQL yang sering muncul dalam interview teknis Data Engineer, seperti:

Penentuan Gaji Tertinggi ke-N.

Deteksi angka berturut-turut (Consecutive Numbers).

Logika pertukaran data (Exchange Seats).

Kalkulasi tingkat pembatalan (Cancellation Rate) pada sistem transportasi online.

🛠️ Struktur File
Setiap file .sql diatur berdasarkan tingkat kesulitan dan urutan eksekusi:

01_schema_and_indexing.sql: Setup database dan optimasi.

02_basic_to_intermediate_queries.sql: Agregasi dan join dasar.

03_advanced_analytics_window_functions.sql: Analisis statistik lanjutan.

04_hierarchical_and_segmentation.sql: Logika BI kompleks.

05_leetcode_sql_challenges.sql: Latihan problem solving.