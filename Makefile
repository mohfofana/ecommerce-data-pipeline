.PHONY: install build test export all clean

install:
	pip install -r requirements.txt

build:          ## seeds + models + tests
	dbt build --profiles-dir .

test:
	dbt test --profiles-dir .

export:         ## marts -> exports/*.parquet
	python scripts/export_marts.py

docs:
	dbt docs generate --profiles-dir . && dbt docs serve --profiles-dir .

all: build export

clean:
	dbt clean --profiles-dir . && rm -f olist.duckdb
