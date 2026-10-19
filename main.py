from pathlib import Path

import kagglehub
import pandas as pd
import pgserver
import sqlparse
from sqlalchemy import create_engine, make_url, text

BASE_DIR = Path(__file__).parent
SQL_DIR = BASE_DIR / "sql"
PG_DATA_DIR = BASE_DIR / ".pg_data"

engine = None


def display(df: pd.DataFrame):
    print(df.to_string())


def read_sql(filename: str) -> str:
    return (SQL_DIR / filename).read_text(encoding="utf-8")


def header(title: str):
    print(f"\n=== {title} ===")


def run_sql(sql: str):
    with engine.begin() as conn:
        for statement in sqlparse.split(sql):
            statement = statement.strip()
            if not statement:
                continue
            result = conn.execute(text(statement))
            if result.returns_rows:
                display(pd.DataFrame(result.fetchall(), columns=result.keys()))
            else:
                print(f"OK: {result.rowcount} rows")


def query_df(sql: str) -> pd.DataFrame:
    with engine.connect() as conn:
        return pd.read_sql_query(text(sql), conn)


def show_result(sql: str, max_rows: int = 20) -> pd.DataFrame:
    df = query_df(sql)
    display(df.head(max_rows))
    print(
        f"Повернуто рядків: {len(df)}"
        + (f" (показано {min(len(df), max_rows)})" if len(df) > max_rows else "")
    )
    return df


def task1_setup():
    header("Завдання 1. Setup і typed-схема Olist")
    dataset_dir = Path(kagglehub.dataset_download("olistbr/brazilian-ecommerce"))
    print("Каталог Olist:", dataset_dir)

    files = {
        "olist_customers_raw": "olist_customers_dataset.csv",
        "olist_orders_raw": "olist_orders_dataset.csv",
        "olist_order_items_raw": "olist_order_items_dataset.csv",
        "olist_products_raw": "olist_products_dataset.csv",
        "olist_sellers_raw": "olist_sellers_dataset.csv",
        "olist_order_reviews_raw": "olist_order_reviews_dataset.csv",
    }

    csv_paths = {}
    for table_name, filename in files.items():
        matches = sorted(dataset_dir.rglob(filename))
        if not matches:
            raise FileNotFoundError(
                f"У завантаженому Olist немає {filename} (каталог {dataset_dir})"
            )
        csv_paths[table_name] = matches[0]
        print(
            f"{table_name:26s} {csv_paths[table_name].stat().st_size / 1024**2:6.2f} MiB"
        )

    raw_row_counts = {}
    for table_name, path in csv_paths.items():
        df = pd.read_csv(path)
        df.to_sql(
            table_name, engine, if_exists="replace", index=False, chunksize=10_000
        )
        raw_row_counts[table_name] = len(df)
        print(f"{table_name}: {len(df):,} рядків × {df.shape[1]} колонок")
        del df

    header("Typed-схема (01_schema.sql)")
    run_sql(read_sql("01_schema.sql"))
    header("Завантаження raw -> typed (02_load_typed.sql)")
    run_sql(read_sql("02_load_typed.sql"))

    header("Перевірка кількості рядків (03_row_counts_check.sql)")
    counts = query_df(read_sql("03_row_counts_check.sql"))
    assert (counts["delta"] == 0).all(), (
        "Raw і typed містять різну кількість рядків — перевірте завантаження!"
    )
    display(counts)


def task2_dml():
    header("Завдання 2.1. INSERT ... RETURNING (04, 05)")
    run_sql(read_sql("04_seller_alerts_schema.sql"))
    run_sql(read_sql("05_seller_alerts_insert.sql"))
    print("Той самий запис другий раз:")
    run_sql(read_sql("05_seller_alerts_insert.sql"))

    header("Завдання 2.2. INSERT ... ON CONFLICT DO UPDATE (06, 07)")
    run_sql(read_sql("06_seller_score_schema.sql"))
    run_sql(read_sql("07_seller_score_upsert.sql"))

    header("Завдання 2.3. UPDATE ... FROM (08_orders_is_late.sql)")
    run_sql(read_sql("08_orders_is_late.sql"))

    header("Завдання 2.4. DELETE ... RETURNING (09_seller_alerts_delete.sql)")
    run_sql(read_sql("09_seller_alerts_delete.sql"))


def task3_customer_segments():
    header("Завдання 3. customer_segments (10–13)")
    run_sql(read_sql("10_customer_dim.sql"))
    run_sql(read_sql("11_customer_segments_schema.sql"))
    run_sql(read_sql("12_customer_segments_upsert.sql"))
    run_sql(read_sql("13_customer_segments_report.sql"))


def task4_joins():
    header("Завдання 4.1. INNER JOIN (14_join_inner.sql)")
    show_result(read_sql("14_join_inner.sql"))

    header("Завдання 4.2. LEFT JOIN + COALESCE (15_join_left.sql)")
    show_result(read_sql("15_join_left.sql"))

    header("Завдання 4.3. FULL OUTER JOIN (16_join_full.sql)")
    join_full = show_result(read_sql("16_join_full.sql"), max_rows=30)
    vc = join_full["state_presence"].value_counts()
    print(vc.to_string())

    header("Завдання 4.4. SELF JOIN (17_join_self.sql)")
    show_result(read_sql("17_join_self.sql"))

    header("Завдання 4.5. Anti-join (18_join_anti.sql)")
    join_anti = show_result(read_sql("18_join_anti.sql"))
    anti_count = query_df(read_sql("18_join_anti_count.sql")).iloc[0][
        "n_orders_without_reviews"
    ]
    print(
        f"Всього замовлень без відгуку — {anti_count:,}; вище показані перші {len(join_anti)} за датою."
    )


def task5_aggregates():
    header("Завдання 5.1. Категорії з виторгом понад 10000 (19)")
    show_result(read_sql("19_agg_category_revenue.sql"))

    header("Завдання 5.2. AOV за штатом покупця (20)")
    show_result(read_sql("20_agg_state_aov.sql"))

    header("Завдання 5.3. STRING_AGG для повторних клієнтів (21)")
    show_result(read_sql("21_agg_repeat_customers.sql"))


def task6_set_ops_and_quality():
    header("Завдання 6.1. INTERSECT (22_set_intersect_states.sql)")
    show_result(read_sql("22_set_intersect_states.sql"), max_rows=30)

    header("Завдання 6.2. ROW_NUMBER() (23_window_latest_orders.sql)")
    show_result(read_sql("23_window_latest_orders.sql"))

    header("Завдання 6.3. Перевірки якості даних (24)")
    data_quality = query_df(read_sql("24_data_quality.sql"))
    display(data_quality)
    status_distribution = query_df(read_sql("24_status_distribution.sql"))
    display(status_distribution)
    dq = data_quality.iloc[0]
    print("Висновок data-quality:")
    print(
        f"- Замовлень без review: {dq['orders_without_reviews']:,}; review без тексту: {dq['reviews_without_text']:,}."
    )
    print(
        f"- Товарів без категорії: {dq['products_without_category']:,}; надлишкових повторів review_id: {dq['repeated_review_id_excess']:,}."
    )
    print(
        f"- Замовлень із кількома продавцями: {dq['multi_seller_orders']:,}; без позицій: {dq['orders_without_items']:,}."
    )


def main():
    global engine
    pg = pgserver.get_server(PG_DATA_DIR)
    # SQLAlchemy 2.1+ defaults to psycopg 3, the project uses psycopg2
    url = make_url(pg.get_uri()).set(drivername="postgresql+psycopg2")
    engine = create_engine(url)
    try:
        with engine.connect() as conn:
            print("PostgreSQL:", conn.execute(text("SELECT version()")).scalar_one())
        task1_setup()
        task2_dml()
        task3_customer_segments()
        task4_joins()
        task5_aggregates()
        task6_set_ops_and_quality()
    finally:
        engine.dispose()
        pg.cleanup()


if __name__ == "__main__":
    main()
