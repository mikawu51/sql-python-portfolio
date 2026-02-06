/* ============================================================================
 * File      : 00_load_raw.sql
 * Purpose   : Register raw CSV data as a base view for downstream processing.
 *
 * Overview  :
 *   This script loads the raw online sales CSV file and exposes it as
 *   a view named `raw_sales`. All downstream SQL logic should reference
 *   this view instead of directly accessing the CSV file.
 *
 * Notes:
 *   - This layer contains no business logic or filtering.
 *   - Any changes to data source (file path, database, etc.)
 *     should be handled here.
 * ============================================================================
 */

CREATE OR REPLACE VIEW raw_sales AS
SELECT *
FROM read_csv_auto(
  '03_data/sample/online_sales_dataset.csv',
  header = true
);

