# Hands-On Lab: Diagnosing Slow Queries and Adding a Connection Pool

## Objectives

- Generate a large dataset in PostgreSQL.
- Diagnose a slow SQL query using `EXPLAIN ANALYZE`.
- Add an index and compare query execution plans.
- Observe PostgreSQL transaction isolation behavior.
- Configure PgBouncer using transaction pooling.

## Results

### Baseline Query
Execution time before the index:

**275.343 ms**

### Query After Index
Execution time after adding `idx_pending_recent`:

**2569.011 ms**

The index was used through a Bitmap Index Scan, but the query became slower for this dataset and query plan.

### Transaction Isolation

Under PostgreSQL's default **READ COMMITTED** isolation level:

- Session 1 initially read `57.90`.
- Session 2 updated the same order to `9999.00` and committed.
- Session 1 then read `9999.00`.

This demonstrates that READ COMMITTED allows a later statement in the same transaction to see data committed by another transaction.

### PgBouncer

PgBouncer was installed and configured with transaction pooling:

- Pool mode: `transaction`
- Maximum client connections: `1000`
- Default pool size: `20`
- Port: `6432`