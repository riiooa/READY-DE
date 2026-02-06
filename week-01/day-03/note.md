
# 📅 Day 03 — Data Warehousing & SQL ETL  

Pada hari ketiga, fokus bergeser ke **Data Engineering**, dengan membangun fondasi **Data Warehouse** menggunakan **Star Schema** serta mengotomatisasi pemindahan data melalui jalur **ETL manual**.

## 🚀 Tugas & Pencapaian  

### 🧩 Environment Setup  
- Manajemen dependensi menggunakan **Python Virtual Environment (venv)** untuk isolasi project.

### 📐 Data Modeling  
Merancang **Star Schema** yang terdiri dari:  
- 1 tabel fakta:  
  - `fact_sales`  
- 4 tabel dimensi:  
  - `dim_time`  
  - `dim_product`  
  - `dim_store`  
  - `dim_customer`  

### 🔄 ETL Pipeline (Extract → Load → Transform)

**Extract**  
- Penyiapan dataset retail berskala besar dalam format **CSV**.

**Load**  
- Migrasi data dari sistem lokal ke Docker menggunakan perintah:
```sql
COPY ...

Transform

Pembersihan data (Data Cleaning) pada kolom yang kotor

Konversi tipe data (Type Casting) menggunakan SQL.

🛡️ Data Integrity Handling

Menangani string kosong dan format tanggal tidak konsisten menggunakan:

NULLIF(...)
CAST(...)
🛠️ Tech Stack

Database: PostgreSQL 15 (Docker Container)

Tools: DBeaver, WSL 2 (Ubuntu), Python 3

Language: SQL (PostgreSQL Dialect)

📂 Struktur File
data/
01_star_schema_ddl.sql
02_load_data_to_postgres.sql