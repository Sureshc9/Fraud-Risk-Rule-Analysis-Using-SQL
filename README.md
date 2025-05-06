# Fraud-Risk-Rule-Analysis-Using-SQL:
A complete SQL-based framework for analyzing fraud trends, rule performance, and creating dynamic procedures to evaluate fraud patterns from transactional data.

# Project Summary:

This repository contains SQL scripts and procedures that help monitor and analyze fraudulent transaction patterns using rule-based logic and model scores. By leveraging window functions, CTEs, and stored procedures, it supports dynamic fraud detection, ranking rules by performance, and comparing trends over time.

# Dataset Overview:
  •	Database: RISKREAD
	•	Primary Table: TRANS_PERF
  <img width="433" alt="Screenshot 2025-05-05 at 9 56 14 PM" src="https://github.com/user-attachments/assets/ab588d9a-8bfb-42f9-a49f-182898a90412" />

# Schema Setup:

  CREATE DATABASE IF NOT EXISTS riskread;
  USE riskread;
  DESCRIBE trans_perf;
  SELECT * FROM trans_perf LIMIT 5;


#  Weekly Fraud Trend Analysis

  This module helps track weekly transaction volumes and fraud trends.

    Features:
	   
     •	Aggregates by week_start
	    
     •	Computes weekly fraud rate
	    
     •	Calculates week-over-week delta


     WITH week_summary AS (...),
       week_with_rates AS (...),
       week_with_changes AS (...)
     SELECT * FROM week_with_changes;
  
  <img width="559" alt="Screenshot 2025-05-05 at 10 01 26 PM" src="https://github.com/user-attachments/assets/8e379368-c4f5-4a5c-a7c8-1a66ea9f5677" />

  <img width="1005" alt="Screenshot 2025-05-05 at 10 02 34 PM" src="https://github.com/user-attachments/assets/664a9733-7868-44f6-b664-43a213d4588d" />


# Rule-Based Fraud Analysis & Ranking:

  > This block analyzes fraud by rule, showing how effective each rule is at identifying fraudulent transactions.

  # Metrics:
  <img width="472" alt="Screenshot 2025-05-05 at 10 04 42 PM" src="https://github.com/user-attachments/assets/ac93d117-2722-42eb-9c74-2aff1a61c759" />

    WITH base_stats AS (...),
       with_totals AS (...),
       with_metrics AS (...),
       ranked AS (...)
    SELECT * FROM ranked;
    
  <img width="701" alt="Screenshot 2025-05-05 at 10 05 32 PM" src="https://github.com/user-attachments/assets/18df1c42-c356-4bf6-9550-dac6d2732683" />

  

  <img width="1082" alt="Screenshot 2025-05-05 at 10 06 20 PM" src="https://github.com/user-attachments/assets/c61aa839-68f1-4094-8c48-3e1436b54097" />

  # Dynamic Rule Evaluation by Score – Stored Procedure:

  This stored procedure dynamically filters by a model score and returns the top N fraud rules based on effectiveness.

# Procedure: get_top_rules_by_score(score FLOAT, top_n INT)

    CALL get_top_rules_by_score(0.90, 5);

  > Internals:
	
   •	Filters rows by a given score
	
   •	Aggregates stats per RULE
	
   •	Normalizes across dataset
	
   •	Returns a ranked list of top fraud-catching rules


  # Output Example:
  
  <img width="536" alt="Screenshot 2025-05-05 at 10 09 42 PM" src="https://github.com/user-attachments/assets/b892a927-c478-4079-a025-1a3b27a25193" />

  # Technologies Used:


  <img width="427" alt="Screenshot 2025-05-05 at 10 10 41 PM" src="https://github.com/user-attachments/assets/d8ac77ca-f89b-4fef-abd3-a718feac9fb0" />


  # Use Cases:
	  
   •	Detecting underperforming fraud rules
	
   •	Optimizing rule strategy by fraud capture %
	
   •	Weekly fraud trend monitoring
	  
   •	Dynamic fraud threshold analysis using model score
    
