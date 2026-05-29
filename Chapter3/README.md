# Chapter 3 – In-Database Machine Learning with OML4SQL

This chapter introduces Oracle Machine Learning for SQL (OML4SQL), demonstrating how to build and use a classification model entirely inside the database without moving data to an external framework.

## Environment

Tested on **Oracle Database 23ai Free** running locally on Docker.
Setup guide: https://www.oracle.com/database/free/get-started/

## Scripts

| # | File | Run as | Purpose |
|---|------|--------|---------|
| 1 | `01_create_user.sql` | SYSDBA | Creates the `ORA_AI_ENG` schema and grants all required privileges |
| 2 | `02_customers_setup.sql` | ORA_AI_ENG | Creates and populates the `CUSTOMERS` training table |
| 3 | `03_oml4sql_classification.sql` | ORA_AI_ENG | Feature engineering, view creation, and SVM classification model |

## Execution order

```sql
-- Step 1: connect as SYSDBA to FREEPDB1
sqlplus sys/<password>@localhost:1521/FREEPDB1 as sysdba
@01_create_user.sql

-- Step 2: connect as ORA_AI_ENG
sqlplus ora_ai_eng/password123@localhost:1521/FREEPDB1
@02_customers_setup.sql
@03_oml4sql_classification.sql
```

## Notes

- The default password in `01_create_user.sql` is `password123`. Change it for any shared environment.
- `CUSTOMERS` rows 1001–1010 are used for model training (via `CUSTOMERS_V`); rows 1011–1015 are available for inference.
- `ADD_MONTHS(SYSDATE, -N)` is used for account open dates so data stays current relative to execution time.
