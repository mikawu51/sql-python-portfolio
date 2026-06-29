/* ============================================================================
 * File      : 01_cleaning_view.sql
 * Purpose   : Create an analysis-ready sales view from raw transactional data.
 *
 * Overview  :
 *   This script standardizes raw sales data and applies business rules
 *   to produce a clean dataset for downstream analytics, including
 *   Funnel Analysis, Cohort Analysis, LTV, and RFM segmentation.
 *
 * Data Rules:
 *   1. Valid sales are defined as records where:
 *        - Quantity  > 0
 *        - UnitPrice > 0
 *      Records not meeting these criteria (e.g. returns or invalid pricing)
 *      are excluded from revenue-based analysis.
 *
 *   2. Customer-level analyses (Cohort, RFM) rely on CustomerID.
 *      Records with missing CustomerID are retained in this view but
 *      should be excluded at query time when customer granularity is required.
 *
 * Transformations:
 *   - Standardize datetime fields and derive daily/monthly partitions.
 *   - Cast numeric fields to appropriate data types.
 *   - Calculate net sales amount (excluding shipping) and total amount
 *     (including shipping) for flexible KPI usage.
 *
 * Downstream Usage:
 *   - Funnel conversion analysis
 *   - Cohort retention analysis
 *   - Customer lifetime value (LTV)
 *   - RFM segmentation (via Python)
 *
 * Notes:
 *   - This view represents the single source of truth for sales analytics.
 *   - Any changes to business logic should be reflected here and documented.
 * ============================================================================
 */

CREATE OR REPLACE VIEW sales_clean AS
WITH base AS (
    SELECT
        -- keep raw identifiers as strings (safer)
        CAST(InvoiceNo AS VARCHAR)            AS invoice_no,
        CAST(StockCode AS VARCHAR)            AS stock_code,
        CAST(Description AS VARCHAR)          AS description,

        -- parse datetime (DuckDB can parse many formats automatically)
        CAST(InvoiceDate AS TIMESTAMP)        AS invoice_ts,
        DATE_TRUNC('day', CAST(InvoiceDate AS TIMESTAMP)) AS invoice_date,
        DATE_TRUNC('month', CAST(InvoiceDate AS TIMESTAMP)) AS invoice_month,

        -- numerics
        CAST(Quantity AS INTEGER)             AS quantity,
        CAST(UnitPrice AS DOUBLE)             AS unit_price,
        CAST(Discount AS DOUBLE)              AS discount,
        CAST(ShippingCost AS DOUBLE)          AS shipping_cost,

        -- customer & dimensions
        NULLIF(CAST(CustomerID AS VARCHAR), '') AS customer_id,
        CAST(Country AS VARCHAR)              AS country,
        CAST(Category AS VARCHAR)             AS category,
        CAST(SalesChannel AS VARCHAR)         AS sales_channel,
        CAST(PaymentMethod AS VARCHAR)        AS payment_method,
        CAST(ReturnStatus AS VARCHAR)         AS return_status,
        CAST(ShipmentProvider AS VARCHAR)     AS shipment_provider,
        CAST(WarehouseLocation AS VARCHAR)    AS warehouse_location,
        CAST(OrderPriority AS VARCHAR)        AS order_priority
    FROM raw_sales
),
filtered AS (
    SELECT
        *,
        -- revenue before shipping (common practice)
        (quantity * unit_price * (1 - COALESCE(discount, 0))) AS net_sales_amount,

        -- total amount including shipping (optional KPI)
        (quantity * unit_price * (1 - COALESCE(discount, 0)) + COALESCE(shipping_cost, 0)) AS total_amount
    FROM base
    WHERE
        quantity > 0
        AND unit_price > 0
)
SELECT *
FROM filtered;