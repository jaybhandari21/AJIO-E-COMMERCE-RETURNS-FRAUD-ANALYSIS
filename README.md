# AJIO-E-COMMERCE-RETURNS-FRAUD-ANALYSIS
Project Overview
This project involves an in-depth SQL-based analysis of a simulated e-commerce dataset, mimicking the structure and operations of a large online retailer like Ajio. The primary goals are to establish key operational metrics, perform customer segmentation, and, crucially, identify potential fraud risks related to returns and customer behavior.

The analysis is performed using MySQL/SQL, leveraging Joins, Window Functions (like RANK() and ROW_NUMBER()), CTEs (Common Table Expressions), and aggregate functions to extract actionable insights from multiple relational tables.

💾 Database Schema
The analysis is built upon a relational database with the following key tables:

Table Name	Description	Key Columns
customer	Customer demographic information.	C_ID
products	Product catalog details.	P_ID
delivery	Delivery partner details and performance metrics.	DP_ID
orders	Core transaction data (Quantity, Discount, Dates).	Or_ID, C_ID, P_ID, DP_ID
ratings	Product and delivery service ratings.	Or_ID
returns	Details of returned items (Reason, Refund status).	Or_ID
transaction	Payment and reward details for each order.	Or_ID
🔑 Key Analysis Areas & Insights
The SQL script is structured into Basic, Intermediate, and Advanced queries to cover a full spectrum of business needs:

📊 Basic Operational Metrics
Order Volume by State: Identified the top states driving e-commerce volume.

Transaction Mode: Determined the most frequent payment methods (e.g., UPI, COD, Card).

Product Popularity: Tracked the best-selling product categories by quantity sold.

Customer Demographics: Segmented the customer base by age group for targeted marketing.

💰 Intermediate Business Performance
Net Sales Value: Calculated the total revenue after discounts for the top product categories.

Company Ratings: Assessed the average product rating for companies with a minimum number of reviews to filter for statistically significant performance.

Delivery Partner Performance: Ranked delivery partners based on total orders handled and average service ratings.

🚨 Advanced & Fraud Detection (Core Focus)
This section contains the most critical, strategic queries aimed at identifying inefficiencies and financial risks:

High-Value Returned Orders: Flagged the top 5 highest-grossing orders that were later approved for a refund, identifying high-risk financial transactions for manual review.

Identifying Top Serial Returners (Fraud Risk): Used CTEs and Window Functions to calculate a Customer Return Rate (Total Approved Returns / Total Orders). Customers with a high order count (e.g., ≥5) and an excessive return rate (e.g., ≥40%) are flagged as potential abusers or serial returners, indicating a high fraud risk.

Inefficiency Flag: Determined the Most Frequent Return Reason per Company to pinpoint specific quality or logistics issues at the supplier level.

Customer Segmentation: Identified the Top Spender in Each State using RANK() and PARTITION BY to facilitate VIP customer programs and hyper-localized marketing efforts.

🛠️ Technologies Used
Language: SQL (MySQL dialect)

Concepts: Joins (INNER, LEFT), Aggregate Functions (SUM, AVG, COUNT), Window Functions (RANK, ROW_NUMBER), Common Table Expressions (WITH), Conditional Logic (CASE statements).
