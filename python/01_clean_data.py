import duckdb
from pathlib import Path
import time

SQL_DIR = Path("01_sql")

def run_sql(con, filename: str) -> None:
    sql = (SQL_DIR / filename).read_text(encoding="utf-8")
    con.execute(sql)

def q(con, sql: str):
    cur = con.execute(sql)
    cols = [d[0] for d in cur.description]
    rows = cur.fetchall()
    return cols, rows

def print_result(title: str, cols, rows, max_rows: int = 20) -> None:
    print(f"📊 {title}")
    print(" | ".join(cols))
    for r in rows[:max_rows]:
        print(" | ".join("" if v is None else str(v) for v in r))
    if len(rows) > max_rows:
        print(f"... ({len(rows)} rows total)")
    print()

def step(msg: str):
    print(f"▶ {msg} ...")
    return time.time()

def done(t0: float):
    dt = time.time() - t0
    print(f"   ✅ done ({dt:.2f}s)\n")

def main():
    con = duckdb.connect("portfolio.duckdb")

    t0 = step("Load raw CSV view (00_load_raw.sql)")
    run_sql(con, "00_load_raw.sql")
    done(t0)

    t0 = step("Create cleaned view (01_cleaning_view.sql)")
    run_sql(con, "01_cleaning_view.sql")
    done(t0)

    t0 = step("Query sanity checks (counts / invalid / missing customer / top countries)")
    cols, rows = q(con, """
        SELECT 'raw_sales' AS table_name, COUNT(*) AS row_cnt FROM raw_sales
        UNION ALL
        SELECT 'sales_clean' AS table_name, COUNT(*) AS row_cnt FROM sales_clean
    """)
    print_result("Raw vs Clean row counts", cols, rows)

    cols, rows = q(con, """
        SELECT
            SUM(CASE WHEN quantity <= 0 THEN 1 ELSE 0 END) AS bad_qty_cnt,
            SUM(CASE WHEN unit_price <= 0 THEN 1 ELSE 0 END) AS bad_price_cnt
        FROM sales_clean
    """)
    print_result("Check invalid quantity / price in sales_clean", cols, rows)

    cols, rows = q(con, """
        SELECT
            COUNT(*) AS clean_rows,
            SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_rows
        FROM sales_clean
    """)
    print_result("Missing customer_id count", cols, rows)

    cols, rows = q(con, """
        SELECT
            country,
            ROUND(SUM(net_sales_amount), 2) AS net_sales
        FROM sales_clean
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 5
    """)
    print_result("Top 5 countries by net sales", cols, rows)
    done(t0)

    funnel_path = SQL_DIR / "03_funnel.sql"
    if not funnel_path.exists():
        raise FileNotFoundError(f"Missing SQL file: {funnel_path}")

    t0 = step("Run funnel query (03_funnel.sql)")
    cols, rows = q(con, funnel_path.read_text(encoding="utf-8"))
    print_result("Funnel result", cols, rows)
    done(t0)

    print("🎉 Pipeline executed successfully!")

if __name__ == "__main__":
    main()
