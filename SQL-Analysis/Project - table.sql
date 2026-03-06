-- Question 1-5
use project;

CREATE TABLE fact_sales_final AS
SELECT
    f.*,

    /* Product lookup */
    p.EnglishProductName,

    /* Customer lookup */
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerFullName,

    /* Convert OrderDate */
    CASE
        WHEN f.OrderDate LIKE '%/%/%'
            THEN STR_TO_DATE(f.OrderDate, '%m/%d/%Y')
        WHEN LENGTH(f.OrderDate) = 8
            THEN STR_TO_DATE(f.OrderDate, '%Y%m%d')
        ELSE STR_TO_DATE(f.OrderDate, '%Y-%m-%d')
    END AS OrderDate_Converted,

    /* Date attributes */
    YEAR(
        CASE
            WHEN f.OrderDate LIKE '%/%/%'
                THEN STR_TO_DATE(f.OrderDate, '%m/%d/%Y')
            WHEN LENGTH(f.OrderDate) = 8
                THEN STR_TO_DATE(f.OrderDate, '%Y%m%d')
            ELSE STR_TO_DATE(f.OrderDate, '%Y-%m-%d')
        END
    ) AS Year,

    MONTH(
        CASE
            WHEN f.OrderDate LIKE '%/%/%'
                THEN STR_TO_DATE(f.OrderDate, '%m/%d/%Y')
            WHEN LENGTH(f.OrderDate) = 8
                THEN STR_TO_DATE(f.OrderDate, '%Y%m%d')
            ELSE STR_TO_DATE(f.OrderDate, '%Y-%m-%d')
        END
    ) AS MonthNo,

    MONTHNAME(
        CASE
            WHEN f.OrderDate LIKE '%/%/%'
                THEN STR_TO_DATE(f.OrderDate, '%m/%d/%Y')
            WHEN LENGTH(f.OrderDate) = 8
                THEN STR_TO_DATE(f.OrderDate, '%Y%m%d')
            ELSE STR_TO_DATE(f.OrderDate, '%Y-%m-%d')
        END
    ) AS MonthFullName,

    CONCAT(
        'Q',
        QUARTER(
            CASE
                WHEN f.OrderDate LIKE '%/%/%'
                    THEN STR_TO_DATE(f.OrderDate, '%m/%d/%Y')
                WHEN LENGTH(f.OrderDate) = 8
                    THEN STR_TO_DATE(f.OrderDate, '%Y%m%d')
                ELSE STR_TO_DATE(f.OrderDate, '%Y-%m-%d')
            END
        )
    ) AS Quarter,

    DATE_FORMAT(
        CASE
            WHEN f.OrderDate LIKE '%/%/%'
                THEN STR_TO_DATE(f.OrderDate, '%m/%d/%Y')
            WHEN LENGTH(f.OrderDate) = 8
                THEN STR_TO_DATE(f.OrderDate, '%Y%m%d')
            ELSE STR_TO_DATE(f.OrderDate, '%Y-%m-%d')
        END,
        '%Y-%m'
    ) AS YearMonth,

    DAYOFWEEK(
        CASE
            WHEN f.OrderDate LIKE '%/%/%'
                THEN STR_TO_DATE(f.OrderDate, '%m/%d/%Y')
            WHEN LENGTH(f.OrderDate) = 8
                THEN STR_TO_DATE(f.OrderDate, '%Y%m%d')
            ELSE STR_TO_DATE(f.OrderDate, '%Y-%m-%d')
        END
    ) AS WeekDayNo,

    DAYNAME(
        CASE
            WHEN f.OrderDate LIKE '%/%/%'
                THEN STR_TO_DATE(f.OrderDate, '%m/%d/%Y')
            WHEN LENGTH(f.OrderDate) = 8
                THEN STR_TO_DATE(f.OrderDate, '%Y%m%d')
            ELSE STR_TO_DATE(f.OrderDate, '%Y-%m-%d')
        END
    ) AS WeekDayName,

    /* Financial Month */
    CASE
        WHEN MONTH(
            CASE
                WHEN f.OrderDate LIKE '%/%/%'
                    THEN STR_TO_DATE(f.OrderDate, '%m/%d/%Y')
                WHEN LENGTH(f.OrderDate) = 8
                    THEN STR_TO_DATE(f.OrderDate, '%Y%m%d')
                ELSE STR_TO_DATE(f.OrderDate, '%Y-%m-%d')
            END
        ) >= 4
        THEN MONTH(
            CASE
                WHEN f.OrderDate LIKE '%/%/%'
                    THEN STR_TO_DATE(f.OrderDate, '%m/%d/%Y')
                WHEN LENGTH(f.OrderDate) = 8
                    THEN STR_TO_DATE(f.OrderDate, '%Y%m%d')
                ELSE STR_TO_DATE(f.OrderDate, '%Y-%m-%d')
            END
        ) - 3
        ELSE MONTH(
            CASE
                WHEN f.OrderDate LIKE '%/%/%'
                    THEN STR_TO_DATE(f.OrderDate, '%m/%d/%Y')
                WHEN LENGTH(f.OrderDate) = 8
                    THEN STR_TO_DATE(f.OrderDate, '%Y%m%d')
                ELSE STR_TO_DATE(f.OrderDate, '%Y-%m-%d')
            END
        ) + 9
    END AS FinancialMonth,

    /* Financial Quarter */
      CASE
        WHEN MONTH(
            CASE
                WHEN f.OrderDate LIKE '%/%/%'
                    THEN STR_TO_DATE(f.OrderDate, '%m/%d/%Y')
                ELSE CAST(f.OrderDate AS DATE)
            END
        ) BETWEEN 4 AND 6 THEN 'FQ1'
        WHEN MONTH(
            CASE
                WHEN f.OrderDate LIKE '%/%/%'
                    THEN STR_TO_DATE(f.OrderDate, '%m/%d/%Y')
                ELSE CAST(f.OrderDate AS DATE)
            END
        ) BETWEEN 7 AND 9 THEN 'FQ2'
        WHEN MONTH(
            CASE
                WHEN f.OrderDate LIKE '%/%/%'
                    THEN STR_TO_DATE(f.OrderDate, '%m/%d/%Y')
                ELSE CAST(f.OrderDate AS DATE)
            END
        ) BETWEEN 10 AND 12 THEN 'FQ3'
        ELSE 'FQ4'
    END AS FinancialQuarter,

    /* Sales */
    (f.UnitPrice * f.OrderQuantity)
      - ((f.UnitPrice * f.OrderQuantity) * f.UnitPriceDiscountPct)
      AS Sales,

    /* Production Cost */
    (f.ProductStandardCost * f.OrderQuantity) AS ProductionCost,

    /* Profit */
    (
        (f.UnitPrice * f.OrderQuantity)
        - ((f.UnitPrice * f.OrderQuantity) * f.UnitPriceDiscountPct)
    )
    - (f.ProductStandardCost * f.OrderQuantity) AS Profit

FROM (
        SELECT * FROM fact_internet_sales
        UNION ALL
        SELECT * FROM fact_internet_sales_new
     ) f
LEFT JOIN dimproduct_merged p ON f.ProductKey = p.ProductKey
LEFT JOIN dimcustomer c ON f.CustomerKey = c.CustomerKey;

select * from fact_sales_final;

-- Question 6
DROP TABLE IF EXISTS sales_monthly;

CREATE TABLE sales_monthly AS
SELECT
    Year,
    MonthNo,
    MonthFullName,
    concat(ROUND(SUM(SalesAmount) / 1000000, 2),"M") AS TotalSales
FROM fact_sales_final
GROUP BY Year, MonthNo, MonthFullName;

select * from sales_monthly;

-- Question 7
DROP TABLE IF EXISTS sales_yearly;

CREATE TABLE sales_yearly AS
SELECT
    Year,
    concat(ROUND(SUM(SalesAmount) / 1000000, 2),"M") AS TotalSales
FROM fact_sales_final
GROUP BY Year;
select * from sales_yearly;

-- Question 8 
DROP TABLE IF EXISTS sales_quarterly;

CREATE TABLE sales_quarterly AS
SELECT
    Quarter,
    concat(ROUND(SUM(SalesAmount) / 1000000, 2),"M") AS TotalSales
FROM fact_sales_final
GROUP BY Quarter;

select * from sales_quarterly;

-- Question 9 
DROP TABLE IF EXISTS sales_cost_yearmonth;

CREATE TABLE sales_cost_yearmonth AS
SELECT
    YearMonth,
    Concat(ROUND(SUM(SalesAmount) / 1000000, 2),"M") AS TotalSales,
    Concat(ROUND(SUM(ProductionCost) / 1000000, 2),"M") AS TotalProductionCost
FROM fact_sales_final
GROUP BY YearMonth;

select * from sales_cost_yearmonth;

-- Question 10 - 1
DROP TABLE IF EXISTS top_products;

CREATE TABLE top_products AS
SELECT
    EnglishProductName,
    Concat(ROUND(SUM(SalesAmount) / 1000000, 2),"M") AS TotalSales_M
FROM fact_sales_final
GROUP BY EnglishProductName
ORDER BY TotalSales_M DESC
LIMIT 10;

select * from top_products;

-- 2
DROP TABLE IF EXISTS region_performance;

CREATE TABLE region_performance AS
SELECT
    t.SalesTerritoryRegion AS Region,
    Concat(ROUND(SUM(s.SalesAmount) / 1000000, 2),"M") AS TotalSales
FROM fact_sales_final s
JOIN dimsalesterritory t
    ON s.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY Region;

select * from region_performance ;

-- 3 
DROP TABLE IF EXISTS top_customers;

CREATE TABLE top_customers AS
SELECT
    CustomerFullName,
    Concat(ROUND(SUM(SalesAmount) / 1000, 2),"K") AS TotalSales
FROM fact_sales_final
GROUP BY CustomerFullName
ORDER BY TotalSales DESC
LIMIT 10;

select * from top_customers;

-- KPI -1 
DROP TABLE IF EXISTS kpi_total_sales;

CREATE TABLE kpi_total_sales AS
SELECT
    CONCAT(ROUND(SUM(SalesAmount) / 1000000, 2), ' M') AS TotalSales
FROM fact_sales_final;

select * from kpi_total_sales ;

-- KPI -2 
DROP TABLE IF EXISTS kpi_total_profit;

CREATE TABLE kpi_total_profit AS
SELECT
     CONCAT(ROUND(SUM(Profit) / 1000000, 2), ' M') AS TotalProfit
FROM fact_sales_final;

select * from kpi_total_profit ;

-- KPI -3 
DROP TABLE IF EXISTS kpi_profit_margin;

CREATE TABLE kpi_profit_margin AS
SELECT
    CONCAT(ROUND((SUM(Profit) / SUM(SalesAmount)) * 100, 2), '%') AS ProfitMargin_Percent
FROM fact_sales_final;

select * from kpi_profit_margin ;





