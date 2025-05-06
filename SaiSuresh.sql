CREATE DATABASE IF NOT EXISTS riskread;
USE riskread;

DESCRIBE trans_perf;
SELECT * FROM trans_perf LIMIT 5;

WITH week_summary AS (
    SELECT 
        STR_TO_DATE(DATE_FORMAT(TRANSACTION_DATE, '%x-%v-1'), '%x-%v-%w') AS week_start,
        COUNT(*) AS total_transfers,
        SUM(CASE WHEN TARGET = 1 THEN 1 ELSE 0 END) AS fraud_count
    FROM RISKREAD.TRANS_PERF
    GROUP BY week_start
),
week_with_rates AS (
    SELECT *,
        ROUND(100.0 * fraud_count / total_transfers, 2) AS fraud_rate
    FROM week_summary
),
week_with_changes AS (
    SELECT 
        week_start,
        total_transfers,
        fraud_count,
        fraud_rate,
        fraud_count - LAG(fraud_count) OVER (ORDER BY week_start) AS fraud_count_change,
        ROUND(fraud_rate - LAG(fraud_rate) OVER (ORDER BY week_start), 2) AS fraud_rate_change
    FROM week_with_rates
)
SELECT * FROM week_with_changes;

WITH base_stats AS (
    SELECT 
        RULE,
        COUNT(*) AS tsfer_rule,
        SUM(CASE WHEN TARGET = 1 THEN 1 ELSE 0 END) AS tsfers_fraud_rule
    FROM RISKREAD.TRANS_PERF
    GROUP BY RULE
),
with_totals AS (
    SELECT 
        (SELECT SUM(tsfer_rule) FROM base_stats) AS total_transfers,
        (SELECT SUM(tsfers_fraud_rule) FROM base_stats) AS total_frauds
),
with_metrics AS (
    SELECT 
        bs.RULE,
        bs.tsfer_rule,
        bs.tsfers_fraud_rule,
        ROUND(100.0 * bs.tsfers_fraud_rule / bs.tsfer_rule, 2) AS rule_fr_rate,
        ROUND(100.0 * bs.tsfer_rule / wt.total_transfers, 2) AS rule_as_pct_in_score,
        ROUND(100.0 * bs.tsfers_fraud_rule / wt.total_frauds, 2) AS pct_fraud_captured
    FROM base_stats bs
    CROSS JOIN with_totals wt
),
ranked AS (
    SELECT *,
        RANK() OVER (ORDER BY rule_fr_rate DESC) AS rank_by_fr_rate,
        RANK() OVER (ORDER BY pct_fraud_captured DESC) AS rank_by_fraud_volume
    FROM with_metrics
)
SELECT * FROM ranked;
›

DELIMITER //

CREATE PROCEDURE get_top_rules_by_score(IN p_score FLOAT, IN p_top_n INT)
BEGIN
    -- Step 1: Filter by score into a temporary table
    CREATE TEMPORARY TABLE IF NOT EXISTS filtered AS
    SELECT * 
    FROM RISKREAD.TRANS_PERF
    WHERE SCORE = p_score;

    -- Step 2: Compute stats per rule
    CREATE TEMPORARY TABLE IF NOT EXISTS rule_stats AS
    SELECT 
        RULE,
        COUNT(*) AS tsfer_rule,
        SUM(CASE WHEN TARGET = 1 THEN 1 ELSE 0 END) AS tsfers_fraud_rule
    FROM filtered
    GROUP BY RULE;

    -- Step 3: Get total fraud for normalization
    SELECT 
        SUM(tsfer_rule) INTO @total_transfers,
        SUM(tsfers_fraud_rule) INTO @total_frauds
    FROM rule_stats;

    -- Step 4: Return final result
    SELECT 
        rs.RULE,
        rs.tsfer_rule,
        rs.tsfers_fraud_rule,
        ROUND(100.0 * rs.tsfers_fraud_rule / rs.tsfer_rule, 2) AS rule_fr_rate,
        ROUND(100.0 * rs.tsfers_fraud_rule / NULLIF(@total_frauds, 0), 2) AS pct_fraud_captured
    FROM rule_stats rs
    ORDER BY rule_fr_rate DESC
    LIMIT p_top_n;

    -- Optional: Drop temporary tables if needed
    DROP TEMPORARY TABLE IF EXISTS filtered;
    DROP TEMPORARY TABLE IF EXISTS rule_stats;
END //

DELIMITER ;