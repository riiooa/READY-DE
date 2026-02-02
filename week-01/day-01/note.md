# Sales Database Project (PostgreSQL)

Proyek ini mendemonstrasikan pengelolaan database penjualan mulai dari perancangan skema, analisis data bisnis, hingga optimasi query menggunakan PostgreSQL di lingkungan Docker.

## 🛠 Tech Stack
- **Database:** PostgreSQL 15
- **Platform:** Docker Desktop, WSL 2 (Ubuntu)
- **Tool:** DBeaver

## 🚀 Cara Menjalankan
1. Jalankan container PostgreSQL:
   ```bash
   docker run --name de-sql -e POSTGRES_USER=user -e POSTGRES_PASSWORD=1234 -e POSTGRES_DB=sales -p 5431:5432 -d postgres:15