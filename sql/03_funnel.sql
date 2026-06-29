/* ============================================================================
 * File      : 03_funnel.sql
 * Purpose   : Build a purchase-based funnel from cleaned sales data.
 *
 * Funnel Definition (Customer-based):
 *   Step 1 - Active Customer       : customer has >= 1 valid invoice
 *   Step 2 - Repeat Customer       : customer has >= 2 distinct invoices
 *   Step 3 - Multi-Category Buyer  : customer bought >= 2 distinct categories
 *   Step 4 - High-Value Customer   : customer total net sales is in top 20%
 *
 * Notes:
 *   - This funnel is designed for transactional datasets (no clickstream).
 *   - CustomerID is required; records with missing CustomerID are excluded.
 * ============================================================================
 */

WITH cust_agg AS (
    SELECT
        customer_id,
        COUNT(DISTINCT invoice_no) AS invoice_cnt,
        COUNT(DISTINCT category)    AS category_cnt,
        SUM(net_sales_amount)       AS total_net_sales
    FROM sales_clean
    WHERE customer_id IS NOT NULL
    GROUP BY 1
),
cust_scored AS (
    SELECT
        *,
        -- NTILE(5) => 5 buckets; 5 = top 20%
        NTILE(5) OVER (ORDER BY total_net_sales) AS spend_quintile
    FROM cust_agg
),
funnel AS (
    SELECT
        COUNT(*) AS step1_active_customers,
        SUM(CASE WHEN invoice_cnt >= 2 THEN 1 ELSE 0 END) AS step2_repeat_customers,
        SUM(CASE WHEN invoice_cnt >= 2 AND category_cnt >= 2 THEN 1 ELSE 0 END) AS step3_multi_category_customers,
        SUM(CASE WHEN invoice_cnt >= 2 AND category_cnt >= 2 AND spend_quintile = 5 THEN 1 ELSE 0 END) AS step4_high_value_customers
    FROM cust_scored
)
SELECT
    step1_active_customers,
    step2_repeat_customers,
    step3_multi_category_customers,
    step4_high_value_customers,
    ROUND(step2_repeat_customers * 1.0 / NULLIF(step1_active_customers, 0), 4) AS conv_1_to_2,
    ROUND(step3_multi_category_customers * 1.0 / NULLIF(step2_repeat_customers, 0), 4) AS conv_2_to_3,
    ROUND(step4_high_value_customers * 1.0 / NULLIF(step3_multi_category_customers, 0), 4) AS conv_3_to_4
FROM funnel;
