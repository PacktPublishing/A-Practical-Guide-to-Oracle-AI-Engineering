# Chapter 4 – Advanced OML4SQL: Random Forest and Partitioned Models

This chapter builds on the OML4SQL foundation from Chapter 3, introducing the Random Forest algorithm and Oracle's partitioned model capability, which trains one sub-model per distinct value of a partition column.

## Environment

Tested on **Oracle Database 23ai Free** running locally on Docker.
Setup guide: https://www.oracle.com/database/free/get-started/

## Prerequisites

Chapter 3 scripts must be executed first (`ORA_AI_ENG` user, `CUSTOMERS` table, and `CUSTOMERS_V` view).

## Scripts

| # | File | Run as | Purpose |
|---|------|--------|---------|
| 1 | `01_random_forest_churn.sql` | ORA_AI_ENG | Trains a Random Forest churn model, runs scored predictions, and demonstrates partitioned models |

## Execution

```sql
sqlplus ora_ai_eng/password123@localhost:1521/FREEPDB1
@01_random_forest_churn.sql
```

## Notes

- `churn_model` predicts `BUY_TRAVEL_INSURANCE`: class `0` = churned (did not buy), class `1` = likely buyer.
- `churn_model_part` partitions training by `MARITAL_STATUS`, producing one sub-model per value (MARRIED, SINGLE, DIVORCED, WIDOWED).
- The partitioned prediction query uses `INTERVAL '5' MINUTE` relative to the most recent `account_open_date` in the dataset to illustrate real-time scoring on recently opened accounts.
