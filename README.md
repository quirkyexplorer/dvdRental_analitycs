# dvdRental_analitycs
sakila project for school
# 📘 README — Sakila 2007 Payments Project (PostgreSQL + pgAdmin4)

This project uses the **Sakila sample database** adapted for **PostgreSQL**.

It includes:

- A detailed 2007 payments table  
- A summary table showing top 5 categories for Q1  
- A custom `get_month()` function  
- A trigger + trigger function to auto-refresh the summary  
- A stored procedure `refreshing_tables()` to rebuild everything  

This README explains how to install Sakila for PostgreSQL, load it in **pgAdmin4**, and run all SQL files.

---

# 🧰 Requirements

- PostgreSQL 14+  
- pgAdmin4  
- Sakila (PostgreSQL version)

# 📦 1. Install Sakila for PostgreSQL

## Step 1 — Download Sakila PostgreSQL Scripts

Download these from the **official PostgreSQL port**:

🔗 https://github.com/jOOQ/sakila/tree/main/postgres-sql

Download:

1. `postgres-sakila-schema.sql`  
2. `postgres-sakila-insert-data.sql`

---

## Step 2 — Create the Sakila Database

In pgAdmin4:

1. Right‐click **Databases** → **Create → Database**
2. Name it: sakila or run 
Or run:

```sql
CREATE DATABASE sakila;


## ✅ Step 3 — Import the Schema

1. Right-click the **sakila** database  
2. Click **Query Tool**  
3. Open the file:  
   **`postgres-sakila-schema.sql`**  
4. Paste its contents into the Query Tool  
5. Click **Execute ▶** (or press **F5**)

This step creates all tables, relationships, and constraints of the Sakila database.

---

## ✅ Step 4 — Import the Data

1. Open a **new Query Tool** window  
2. Open the file:  
   **`postgres-sakila-insert-data.sql`**  
3. Paste its contents into the Query Tool  
4. Click **Execute ▶** (or press **F5**)

This step inserts all sample data into the database.

---

### After Running Both Files, You Should See the Base Tables:

- `actor`  
- `film`  
- `category`  
- `rental`  
- `payment`  
- `inventory`  
- `film_actor`  
- `film_category`  
- `store`  
- `customer`  
- and more…

Your Sakila database is now fully installed and ready for use.

---  
Run the queries inside the sql file

