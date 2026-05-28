# NovaMart Analytics — End-to-End Data Warehouse & Dashboard

## 📊 Project Overview
A complete end-to-end data analytics project built for a fictional FMCG company called NovaMart. 
The project covers the full data pipeline — from raw data generation to a professional 
interactive Power BI dashboard — using SQL Server Medallion Architecture.

## 🏗️ Architecture
![Medallion Architecture](https://i.imgur.com/placeholder.png)

Bronze Layer → Silver Layer → Gold Layer → Power BI

## 🛠️ Tools & Technologies
- **Python** — Data generation (Faker, Pandas, NumPy)
- **SQL Server** — Data warehouse and ETL
- **Power BI** — Interactive dashboard
- **GitHub** — Version control

## 📁 Project Structure
NovaMart-Analytics/
├── data/
│   ├── generate_data.py
│   ├── customers.csv
│   ├── products.csv
│   └── transactions.csv
├── sql/
│   ├── bronze_load.sql
│   ├── silver_load.sql
│   ├── gold_views.sql
│   └── data_quality.sql
├── dashboard/
│   └── NovaMart.pbix
└── README.md

## 🔄 Data Pipeline

### Bronze Layer
- Raw data loaded from CSV files using BULK INSERT
- Stored procedure with error handling and load time logging
- Truncate and reload pattern for idempotency

### Silver Layer
- Data cleaning and standardization
- Null handling and text trimming
- Added calculated columns (profit margin %)
- Referential integrity maintained

### Gold Layer
- 5 business-ready views optimized for reporting
- Pre-joined tables eliminating complex Power BI queries
- Aggregated summaries for fast dashboard performance

## 📈 Dashboard Pages

### Page 1 — Executive Overview
- Total Revenue, Profit, Transactions, Customers KPIs
- Monthly Revenue Trend
- Revenue by Region
- Revenue by Category

### Page 2 — Product Performance
- Top 10 Products by Revenue
- Revenue and Profit Margin by Category
- Overall Target Achievement Gauge

### Page 3 — Customer Analysis
- Top 10 Customers by Spend
- Customers by Region and Segment
- Average Order Value and Orders Per Customer

## 🚀 How to Run This Project
1. Clone the repository
2. Run generate_data.py to create the CSV files
3. Execute SQL files in order: bronze → silver → gold
4. Open NovaMart.pbix in Power BI Desktop
5. Update the SQL Server connection to your local server

## 📬 Contact
**Mohamed Osama** — Data Analyst
Available for freelance work on Fiverr and Mostaql
