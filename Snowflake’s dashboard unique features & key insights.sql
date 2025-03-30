--1 Perform Data Integration

SELECT 
    Crop, 
    Crop_Year, 
    Season, 
    State, 
    SUM(Production) AS Total_Production, 
    AVG(Yield) AS Avg_Yield
FROM CROP_YIELD
GROUP BY Crop, Crop_Year, Season, State;

--2 Find Top 5 Crops with the Highest Yield
SELECT Crop, AVG(Yield) AS Avg_Yield
FROM CROP_YIELD
GROUP BY Crop
ORDER BY Avg_Yield DESC
LIMIT 5;

--3. Production Trends Over the Years

SELECT Crop_Year, SUM(Production) AS Total_Production
FROM CROP_YIELD
GROUP BY Crop_Year
ORDER BY Crop_Year;

--4. State-wise Crop Production
SELECT State, Crop, SUM(Production) AS Total_Production
FROM CROP_YIELD
GROUP BY State, Crop
ORDER BY Total_Production DESC;

-- 5. Seasonal Analysis of Crop Yield
SELECT Season, AVG(Yield) AS Avg_Yield
FROM CROP_YIELD
GROUP BY Season
ORDER BY Avg_Yield DESC;

--6 Showcase Snowflake’s Unique Features
--1. Time Travel (Recover Deleted or Modified Data)

SELECT * 
FROM CROP_YIELD AT(TIMESTAMP => DATEADD(HOUR, -1, CURRENT_TIMESTAMP));

--7
-- 2. Query Optimization (Using Clustering & Caching)

ALTER TABLE CROP_YIELD 
CLUSTER BY (Crop_Year, State);

--8
--3. Auto-Scaling for Performance
--Snowflake’s multi-cluster warehouse scales automatically:

-- Auto suspend after 5 min
ALTER WAREHOUSE COMPUTE_WH SET AUTO_SUSPEND = 300;
-- Auto resume when needed
ALTER WAREHOUSE COMPUTE_WH SET AUTO_RESUME = TRUE;  

--9
CONTRY_ECONOMYSHOW TABLES LIKE 'CROP_YIELD';

ALTER TABLE CROP_YIELD ADD COLUMN Crop_Date DATE;
COMMIT;  
UPDATE CROP_YIELD SET Crop_Date = TO_DATE(Crop_Year || '-01-01', 'YYYY-MM-DD');

--SELECT Crop_Date, SUM(Production) AS Total_Production
FROM CROP_YIELD
GROUP BY Crop_Date
ORDER BY Crop_Date;

--Perform Time Series Aggregation
SELECT 
    Crop_Date,
    SUM(Production) AS Total_Production,
    LAG(SUM(Production)) OVER (ORDER BY Crop_Date) AS Prev_Year_Production,
    (SUM(Production) - LAG(SUM(Production)) OVER (ORDER BY Crop_Date)) / NULLIF(LAG(SUM(Production)) OVER (ORDER BY Crop_Date), 0) * 100 AS YoY_Growth_Percentage
FROM CROP_YIELD
GROUP BY Crop_Date
ORDER BY Crop_Date;





