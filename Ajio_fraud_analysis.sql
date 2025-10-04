CREATE DATABASE Ajio_ECommerce_Project;
USE Ajio_ECommerce_Project;

CREATE TABLE customer (
    C_ID INT PRIMARY KEY,
    C_Name VARCHAR(100),
    Age INT,
    Gender VARCHAR(10),
    City VARCHAR(50),
    State VARCHAR(50),
    Email VARCHAR(100)
);

CREATE TABLE products (
    P_ID INT PRIMARY KEY,
    P_Name VARCHAR(255),
    Category VARCHAR(100),
    Company_Name VARCHAR(100),
    Price DECIMAL(10, 2));
    
    CREATE TABLE delivery (
    DP_ID INT PRIMARY KEY,
    DP_name VARCHAR(100),
    DP_Ratings DECIMAL(2, 1),
    Percent_Cut DECIMAL(5, 2)
);

CREATE TABLE orders (
    Or_ID INT PRIMARY KEY,
    C_ID INT,
    P_ID INT,
    DP_ID INT,
    Qty INT,
    Discount DECIMAL(5, 2),
    Coupon VARCHAR(50),
    Delivery_date DATE);
    
    CREATE TABLE ratings (
    R_ID INT PRIMARY KEY AUTO_INCREMENT, 
    Or_ID INT,
    Prod_Rating DECIMAL(2, 1),
    Delivery_Service_Rating DECIMAL(2, 1)
);

CREATE TABLE returns (
    RT_ID INT PRIMARY KEY,
    Or_ID INT,
    Reason VARCHAR(255),
    RT_Date DATE,
    Return_Refund VARCHAR(50)
   
);

CREATE TABLE transaction (
    Tr_ID INT PRIMARY KEY,
    Or_ID INT,
    Transaction_Mode VARCHAR(50),
    Reward VARCHAR(10)
);
select * from CUSTOMER;
select * from orders;

# 1 - Total Order Volume by State
SELECT c.State, COUNT(o.Or_ID) AS Total_Order_Count
FROM orders o JOIN customer c ON o.C_ID = c.C_ID
GROUP BY c.State
ORDER BY Total_Order_Count DESC
LIMIT 10;

#2: Top 3 Most Frequent Transaction Modes

SELECT Transaction_Mode, COUNT(Tr_ID) AS Transaction_Count
FROM transaction GROUP BY Transaction_Mode ORDER BY Transaction_Count DESC
LIMIT 3;

#3: Most Popular Product Categories by Quantity Sold
SELECT p.Category, SUM(o.Qty) AS Total_Quantity_Sold
FROM orders o JOIN products p ON o.P_ID = p.P_ID
GROUP BY p.Category ORDER BY Total_Quantity_Sold DESC
LIMIT 5;

-- 4: Customer Distribution by Age Group 
SELECT
    CASE
        WHEN Age BETWEEN 18 AND 25 THEN '18-25 (Young Adult)'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35 (Mid-Career)'
        WHEN Age BETWEEN 36 AND 50 THEN '36-50 (Established)'
        ELSE '51+ (Senior)'
    END AS Age_Group,
    COUNT(C_ID) AS Customer_Count
FROM customer GROUP BY Age_Group
ORDER BY Customer_Count DESC;

-- 5: Top 5 Return Reasons by Count
SELECT Reason, COUNT(RT_ID) AS Return_Count
FROM returns GROUP BY Reason ORDER BY
Return_Count DESC LIMIT 5;

-- INTERMIDIATE PROBLEM SOLUTION--  

-- 6: Net Sales Value by TOP 10  Product Category    

SELECT p.Category,
    -- Net Sales = SUM(Price * Qty * (1 - Discount/100))
CAST(SUM(p.Price * o.Qty * (1 - o.Discount / 100.0)) AS DECIMAL(10, 2)) AS Total_Net_Sales_Value
FROM orders o JOIN products p ON o.P_ID = p.P_ID
GROUP BY p.Category
ORDER BY Total_Net_Sales_Value DESC LIMIT 10;    
    
-- 7: Average Product Rating per Company

SELECT
    p.Company_Name,
    COUNT(r.Prod_Rating) AS Total_Reviews,
    CAST(AVG(r.Prod_Rating) AS DECIMAL(10, 2)) AS Avg_Product_Rating
FROM ratings r
JOIN orders o ON r.Or_ID = o.Or_ID
JOIN products p ON o.P_ID = p.P_ID
GROUP BY p.Company_Name
HAVING COUNT(r.Prod_Rating) >= 5
ORDER BY
    Avg_Product_Rating DESC;
    
    
-- 8: Delivery Partner Performance and Rating   

SELECT
    d.DP_name,
    COUNT(o.Or_ID) AS Total_Orders_Handled,
    CAST(AVG(r.Delivery_Service_Rating) AS DECIMAL(10, 2)) AS Avg_Delivery_Rating
FROM orders o JOIN ratings r ON o.Or_ID = r.Or_ID JOIN delivery d ON o.DP_ID = d.DP_ID
GROUP BY d.DP_name ORDER BY Avg_Delivery_Rating DESC, Total_Orders_Handled DESC; 
    
    
--  9:High-Value Returned Orders (Fraud Risk Flag)
SELECT
    o.Or_ID,
    c.C_Name,
    p.Category,
    p.Price * o.Qty AS Gross_Revenue,
    r.Reason AS Return_Reason
FROM orders o
JOIN products p ON o.P_ID = p.P_ID
JOIN customer c ON o.C_ID = c.C_ID
JOIN returns r ON o.Or_ID = r.Or_ID
WHERE r.Return_Refund = 'Approved'
ORDER BY Gross_Revenue DESC
LIMIT 5;

-- 10: Discount Effectiveness by Order Quantity

SELECT o.Discount, COUNT(o.Or_ID) AS Orders_Count,
CAST(AVG(o.Qty) AS DECIMAL(10, 2)) AS Avg_Quantity_Per_Order
FROM orders o
GROUP BY o.Discount
HAVING COUNT(o.Or_ID) > 10
ORDER BY o.Discount DESC;


-- ADVANCED QUERIES (Fraud Detection and Strategic Insight)

-- 11: Identifying Top Serial Returners (Customer Abuse/Fraud)    

WITH Customer_Return_Metrics AS (
    SELECT
        c.C_Name,
        COUNT(DISTINCT o.Or_ID) AS Total_Orders,
        COUNT(DISTINCT r.RT_ID) AS Total_Approved_Returns,
        CAST(COUNT(DISTINCT r.RT_ID) * 100.0 / COUNT(DISTINCT o.Or_ID) AS DECIMAL(10, 2)) AS Customer_Return_Rate
    FROM
        customer c
    JOIN
        orders o ON c.C_ID = o.C_ID
    LEFT JOIN
        returns r ON o.Or_ID = r.Or_ID AND r.Return_Refund = 'Approved'
    GROUP BY
        c.C_Name
)
SELECT C_Name, Total_Orders,Total_Approved_Returns,Customer_Return_Rate
FROM Customer_Return_Metrics
WHERE Total_Orders >= 5 AND Customer_Return_Rate >= 40 
ORDER BY Customer_Return_Rate DESC
LIMIT 10;    

-- 12: Most Frequent Return Reason per Company (Inefficiency Flag)
WITH Company_Return_Ranking AS (
    SELECT p.Company_Name, r.Reason, COUNT(r.RT_ID) AS Return_Count,
    ROW_NUMBER() OVER(PARTITION BY p.Company_Name ORDER BY COUNT(r.RT_ID) DESC) AS Rank_Reason
    FROM returns r
    JOIN orders o ON r.Or_ID = o.Or_ID
    JOIN products p ON o.P_ID = p.P_ID
    WHERE r.Reason IS NOT NULL
    GROUP BY p.Company_Name, r.Reason
)
SELECT Company_Name, Reason AS Top_Return_Reason, Return_Count
FROM Company_Return_Ranking
WHERE Rank_Reason = 1
ORDER BY Company_Name DESC LIMIT 5 ;

-- 13: Top Spender in Each State (Customer Segmentation)
WITH Customer_State_Ranking AS (
    SELECT
        c.C_Name,c.State, SUM(o.Qty) AS Total_Quantity_Purchased,
        RANK() OVER(PARTITION BY c.State ORDER BY SUM(o.Qty) DESC) AS Rank_In_State
    FROM customer c
    JOIN orders o ON c.C_ID = o.C_ID
    GROUP BY c.C_Name, c.State
)
SELECT State, C_Name AS Top_Customer_Name, Total_Quantity_Purchased
FROM Customer_State_Ranking
WHERE Rank_In_State = 1
ORDER BY Total_Quantity_Purchased DESC LIMIT 5;