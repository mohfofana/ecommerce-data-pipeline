"""Export the dbt marts to Parquet so other projects can consume them
without running the pipeline (see delivery-delay-prediction and
customer-segmentation)."""
from pathlib import Path

import duckdb

MARTS = [
    "fct_orders",
    "dim_customers",
    "dim_sellers",
    "mart_delivery_performance",
    "mart_customer_rfm",
]

def main() -> None:
    out = Path(__file__).resolve().parents[1] / "exports"
    out.mkdir(exist_ok=True)
    con = duckdb.connect("olist.duckdb", read_only=True)
    for name in MARTS:
        path = out / f"{name}.parquet"
        con.execute(f"copy marts.{name} to '{path}' (format parquet, compression zstd)")
        rows = con.execute(f"select count(*) from marts.{name}").fetchall()[0][0]
        print(f"{name:<28} {rows:>8} rows -> {path.relative_to(out.parent)}")

if __name__ == "__main__":
    main()
