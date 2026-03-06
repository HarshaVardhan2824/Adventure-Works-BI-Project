create database project;

USE project;


select * from dimcustomer;
select * from dimdate;
select * from dimproduct_merged;
select * from dimsalesterritory;
select * from fact_internet_sales;
select * from fact_internet_sales_append;
select * from fact_internet_sales_new;

-- QUESTION 1
SELECT * FROM fact_internet_sales
UNION ALL
SELECT * FROM fact_internet_sales_new;

-- QUESTION 2
SELECT 
    f.* , p.EnglishProductName 
FROM  (
        SELECT * FROM fact_internet_sales
        UNION ALL
        SELECT * FROM fact_internet_sales_new
     ) as f
left JOIN dimproduct_merged as p
ON f.ProductKey = p.ProductKey;

-- QUESTION 3
select f.* , 
       CONCAT(c.FirstName, ' ', c.LastName) AS CustomerFullName
FROM  (
        SELECT * FROM fact_internet_sales
        UNION ALL
        SELECT * FROM fact_internet_sales_new
     ) as f
left JOIN dimcustomer as c 
on f.CustomerKey = c.CustomerKey;

-- QUESTION 4
SELECT
    f.*,

    -- convert TEXT → DATE 
    STR_TO_DATE(f.OrderDate, '%m/%d/%Y') AS OrderDate_Converted,

    -- Year 
    YEAR(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) AS Year,

    -- Month number 
    MONTH(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) AS MonthNo,

    -- Month full name 
    MONTHNAME(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) AS MonthFullName,

    -- Quarter 
    CONCAT('Q', QUARTER(STR_TO_DATE(f.OrderDate, '%m/%d/%Y'))) AS Quarter,

    -- Year-Month 
    DATE_FORMAT(STR_TO_DATE(f.OrderDate, '%m/%d/%Y'), '%Y-%b') AS YearMonth,

    -- Weekday number 
    DAYOFWEEK(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) AS WeekDayNo,

    -- Weekday name 
    DAYNAME(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) AS WeekDayName,

    -- Financial Month (April = 1) 
    CASE
        WHEN MONTH(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) >= 4
            THEN MONTH(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) - 3
        ELSE MONTH(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) + 9
    END AS FinancialMonth,

    -- Financial Quarter 
    CASE
        WHEN MONTH(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) BETWEEN 4 AND 6 THEN 'FQ1'
        WHEN MONTH(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) BETWEEN 7 AND 9 THEN 'FQ2'
        WHEN MONTH(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) BETWEEN 10 AND 12 THEN 'FQ3'
        ELSE 'FQ4'
    END AS FinancialQuarter

FROM (
        SELECT * FROM fact_internet_sales
        UNION ALL
        SELECT * FROM fact_internet_sales_new
     ) f;
     
 -- Question 5    
SELECT
    f.*,

    -- Sales Amount 
    (f.UnitPrice * f.OrderQuantity) 
      - ((f.UnitPrice * f.OrderQuantity) * f.UnitPriceDiscountPct) 
      AS SalesAmount_Calc,

    -- Production Cost 
    (f.ProductStandardCost * f.OrderQuantity) 
      AS ProductionCost,

    -- Profit 
    (
        (f.UnitPrice * f.OrderQuantity)
        - ((f.UnitPrice * f.OrderQuantity) * f.UnitPriceDiscountPct)
    )
    -
    (f.ProductStandardCost * f.OrderQuantity)
    AS Profit

FROM (
        SELECT * FROM fact_internet_sales
        UNION ALL
        SELECT * FROM fact_internet_sales_new
     ) f;
     
-- Question 6
SELECT
    Year,
    MonthFullName,
     CONCAT(ROUND(SUM(SalesAmount) / 1000000, 2), ' M') AS TotalSales
FROM fact_internet_sales_append
GROUP BY Year, MonthNo, MonthFullName
ORDER BY Year, MonthNo;

-- Question 7
SELECT
    Year,
    CONCAT(ROUND(SUM(SalesAmount) / 1000000, 2), ' M') AS TotalSales
FROM fact_internet_sales_append
GROUP BY Year
ORDER BY Year;

-- Question 8
SELECT
    Quarter,
    CONCAT(ROUND(SUM(SalesAmount) / 1000000, 2), ' M') AS TotalSales
FROM fact_internet_sales_append
GROUP BY Quarter
ORDER BY Quarter;

-- Question 9 
SELECT
    YearMonth,
   CONCAT(ROUND(SUM(SalesAmount) / 1000000, 2), ' M') AS TotalSales,
   CONCAT(ROUND(SUM(ProductionCost) / 1000000, 2), ' M') AS TotalProductionCost
FROM fact_internet_sales_append
GROUP BY YearMonth
ORDER BY MIN(OrderDate);

-- Question 10 
SELECT
    s.`Product Name`,
    CONCAT(ROUND(SUM(SalesAmount) / 1000000, 2), ' M') AS TotalSales
FROM fact_internet_sales_append s
GROUP BY s.`Product Name`
ORDER BY TotalSales DESC
LIMIT 10;

SELECT
    t.SalesTerritoryRegion AS Region,
    CONCAT(ROUND(SUM(SalesAmount) / 1000000, 2), ' M') AS TotalSales
FROM fact_internet_sales_append s
JOIN dimsalesterritory t
    ON s.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY Region
ORDER BY TotalSales DESC;

SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    CONCAT(ROUND(SUM(SalesAmount) / 1000, 2), ' K') AS TotalSales
FROM fact_internet_sales_append s
JOIN dimcustomer c
    ON s.CustomerKey = c.CustomerKey
GROUP BY CustomerName
ORDER BY TotalSales DESC
LIMIT 10;

-- KPI 
SELECT CONCAT(ROUND(SUM(SalesAmount) / 1000000, 2), ' M') AS TotalSales
FROM fact_internet_sales_append;

SELECT  CONCAT(ROUND(SUM(Profit) / 1000000, 2), 'M') AS TotalProfit_M
FROM fact_internet_sales_append;

SELECT
   CONCAT( ROUND(
        (SUM(Profit) / SUM(SalesAmount)) * 100, 2
    ), '%') AS ProfitMargin_Percent
FROM fact_internet_sales_append;








   