use project;
-- overall 1-5 questions 

CREATE OR REPLACE VIEW vw_fact_sales_final AS
SELECT
    f.*,

    /* Product lookup */
    p.EnglishProductName,

    /* Customer lookup */
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerFullName,

    /* Convert OrderDate (TEXT → DATE) */
    STR_TO_DATE(f.OrderDate, '%m/%d/%Y') AS OrderDate_Converted,

    /* Date attributes */
    YEAR(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) AS Year,
    MONTH(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) AS MonthNo,
    MONTHNAME(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) AS MonthFullName,
    CONCAT('Q', QUARTER(STR_TO_DATE(f.OrderDate, '%m/%d/%Y'))) AS Quarter,
    DATE_FORMAT(STR_TO_DATE(f.OrderDate, '%m/%d/%Y'), '%Y-%m') AS YearMonth,
    DAYOFWEEK(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) AS WeekDayNo,
    DAYNAME(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) AS WeekDayName,

    /* Financial Month */
    CASE
        WHEN MONTH(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) >= 4
            THEN MONTH(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) - 3
        ELSE MONTH(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) + 9
    END AS FinancialMonth,

    /* Financial Quarter */
    CASE
        WHEN MONTH(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) BETWEEN 4 AND 6 THEN 'FQ1'
        WHEN MONTH(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) BETWEEN 7 AND 9 THEN 'FQ2'
        WHEN MONTH(STR_TO_DATE(f.OrderDate, '%m/%d/%Y')) BETWEEN 10 AND 12 THEN 'FQ3'
        ELSE 'FQ4'
    END AS FinancialQuarter,

    /* Sales Amount */
    (f.UnitPrice * f.OrderQuantity)
      - ((f.UnitPrice * f.OrderQuantity) * f.UnitPriceDiscountPct)
      AS SalesAmount_Calc,

    /* Production Cost */
    (f.ProductStandardCost * f.OrderQuantity) AS ProductionCost,

    /* Profit */
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
     ) f
LEFT JOIN dimproduct_merged p
    ON f.ProductKey = p.ProductKey
LEFT JOIN dimcustomer c
    ON f.CustomerKey = c.CustomerKey;
    
SELECT * FROM vw_fact_sales_final;

-- Question 6
SELECT
    Year,
    MonthFullName,
    CONCAT(ROUND(SUM(SalesAmount) / 1000000, 2), ' M') AS TotalSales
FROM vw_fact_sales_final
GROUP BY Year, MonthNo, MonthFullName
ORDER BY Year, MonthNo;

-- Question 7
SELECT
    Year,
    CONCAT(ROUND(SUM(SalesAmount) / 1000000, 2), ' M') AS TotalSales
FROM vw_fact_sales_final
GROUP BY Year
ORDER BY Year;

-- Question 8
SELECT
    Quarter,
    CONCAT(ROUND(SUM(SalesAmount) / 1000000, 2), ' M') AS TotalSales
FROM vw_fact_sales_final
GROUP BY Quarter
ORDER BY Quarter;

-- Question 9 
SELECT
    YearMonth,
    CONCAT(ROUND(SUM(SalesAmount) / 1000000, 2), ' M') AS TotalSales,
    CONCAT(ROUND(SUM(ProductionCost) / 1000000, 2), ' M') AS TotalProductionCost
FROM vw_fact_sales_final
GROUP BY YearMonth
ORDER BY MIN(OrderDate);

-- Question 10 
SELECT
    s.EnglishProductName,
    CONCAT(ROUND(SUM(SalesAmount) / 1000000, 2), ' M') AS TotalSales
FROM vw_fact_sales_final s
GROUP BY s.EnglishProductName
ORDER BY TotalSales DESC
LIMIT 10;


SELECT
    t.SalesTerritoryRegion AS Region,
    CONCAT(ROUND(SUM(SalesAmount) / 1000000, 2), ' M') AS TotalSales
FROM vw_fact_sales_final s
JOIN dimsalesterritory t
    ON s.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY Region
ORDER BY TotalSales DESC;

SELECT
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    CONCAT(ROUND(SUM(SalesAmount) / 1000, 2), ' K') AS TotalSales
FROM vw_fact_sales_final s
JOIN dimcustomer c
    ON s.CustomerKey = c.CustomerKey
GROUP BY CustomerName
ORDER BY TotalSales DESC
LIMIT 10;

-- KPI 
SELECT CONCAT(ROUND(SUM(SalesAmount) / 1000000, 2), ' M') AS TotalSales
FROM vw_fact_sales_final;

SELECT CONCAT(ROUND(SUM(Profit) / 1000000, 2), 'M') AS TotalProfit_M
FROM vw_fact_sales_final;

SELECT
    CONCAT(
        ROUND(
            (SUM(Profit) / SUM(SalesAmount)) * 100, 2
        ),
        '%'
    ) AS ProfitMargin_Percent
FROM vw_fact_sales_final;




