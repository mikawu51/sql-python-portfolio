# SQL & Python Portfolio

This repository showcases my SQL and Python data analysis projects.

## 🎯 Objective
Analyze customer purchase behavior using SQL and Python,
focusing on funnel conversion, cohort retention, and LTV.

## 🗂 Project Structure
- `01_sql/` : Data cleaning, funnel, cohort analysis (SQL)
- `02_python/` : Pandas analysis & visualization
- `03_data/sample/` : Public sample data
- `04_outputs/` : Exported tables and figures

## 🔧 Skills Demonstrated
- SQL (CTE, Window Functions, Funnel, Cohort)
- Python (Pandas, NumPy)
- Business Metrics Interpretation

## 📌 Key Insights

### 📊 Purchase Funnel (Value-based)
This project applies a value-based purchase funnel to understand how customers evolve from first-time buyers into high-value customers, using transactional data only (no clickstream required).

Instead of focusing on page-level behaviors (e.g. view → cart → checkout), this funnel models customer maturity and long-term value progression, which is commonly used in e-commerce, subscription, and financial analytics.

**Funnel Definition (Customer-level):**

1. **Active Customers**
Customers with at least one valid transaction.
This defines the true customer base and excludes non-converting or invalid records.

2. **Repeat Customers**
Customers with two or more distinct invoices.
This stage represents repeat purchase behavior and early customer retention.

3. **Multi-Category Customers**
Customers who purchased from two or more different product categories.
This indicates broader usage scenarios, cross-category demand, and higher customer engagement.

4. **High-Value Customers**
Customers whose total net sales fall within the top 20% of spenders.
These customers typically contribute a disproportionate share of total revenue and are key targets for CRM and retention strategies.

**Business Value:**

- The funnel quantifies customer drop-off between each maturity stage.

- It highlights where customers fail to transition from one-time buyers to loyal, high-value customers. 

- The results provide a foundation for downstream analysis such as cohort retention, LTV modeling, and targeted customer segmentation.