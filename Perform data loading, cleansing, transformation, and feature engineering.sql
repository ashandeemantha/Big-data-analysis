--Data Cleansing

--**Identify Missing Values
SELECT *
FROM "crop_data"
WHERE Crop IS NULL OR Crop_Year IS NULL OR Season IS NULL 
   OR State IS NULL OR Area IS NULL OR Production IS NULL 
   OR Annual_Rainfall IS NULL OR Fertilizer IS NULL OR Pesticide IS NULL 
   OR Yield IS NULL;

--**Handle Missing Values
--*Fill numerical missing values with the column median
UPDATE "crop_data"
SET Annual_Rainfall = (SELECT MEDIAN(Annual_Rainfall) FROM "crop_data")
WHERE Annual_Rainfall IS NULL;

--**Remove Duplicates

--*Identify the Structure of Duplicates
SELECT Crop, Crop_Year, Season, State, Area, Production, Yield, COUNT(*) AS count_duplicates
FROM "crop_data"
GROUP BY Crop, Crop_Year, Season, State, Area, Production, Yield
HAVING COUNT(*) > 1
ORDER BY count_duplicates DESC;

--*Find Hidden Differences
--Check for Extra Spaces or Case Sensitivity
SELECT DISTINCT Crop, TRIM(Crop) AS Trimmed_Crop
FROM "crop_data"
WHERE Crop <> TRIM(Crop);

--Check for Exact Differences
SELECT Crop, Crop_Year, Season, State, Area, Production, Yield, COUNT(*)
FROM "crop_data"
GROUP BY Crop, Crop_Year, Season, State, Area, Production, Yield
HAVING COUNT(*) > 1;

--*Delete Duplicates
DELETE FROM "crop_data"
WHERE (Crop, Crop_Year, Season, State, Area, Production, Yield) IN (
    SELECT Crop, Crop_Year, Season, State, Area, Production, Yield
    FROM (
        SELECT *, 
               ROW_NUMBER() OVER (
                   PARTITION BY TRIM(UPPER(Crop)), Crop_Year, Season, State, Area, Production, Yield 
                   ORDER BY Yield ASC NULLS LAST
               ) AS row_num
        FROM "crop_data"
    ) sub
    WHERE row_num > 1
);

--Verify That Duplicates Are Removed
SELECT Crop, Crop_Year, Season, State, Area, Production, Yield, COUNT(*)
FROM "crop_data"
GROUP BY Crop, Crop_Year, Season, State, Area, Production, Yield
HAVING COUNT(*) > 1;


/*
--**Transformations
--**Data Transformation
ALTER TABLE "crop_data"
MODIFY Crop_Year INT;
*/

/*
--**Normalization
--Update Table to Store Normalized Values, add a New Column for Normalized Yield
ALTER TABLE "crop_data" ADD COLUMN normalized_yield FLOAT;

-- Normalize the 'Yield' Column (Min-Max Scaling)
--Find Min and Max of Yield
SELECT MIN(Yield) AS min_yield, MAX(Yield) AS max_yield FROM "crop_data";

-- Normalize Yield Using Min-Max Scaling
SELECT *,
       (Yield - MIN(Yield) OVER()) / 
       (MAX(Yield) OVER() - MIN(Yield) OVER()) AS normalized_yield
FROM "crop_data";

--Update the Table with Min-Max Scaled Values
UPDATE "crop_data"
SET normalized_yield = 
    (Yield - (SELECT MIN(Yield) FROM "crop_data")) / 
    ((SELECT MAX(Yield) FROM "crop_data") - (SELECT MIN(Yield) FROM "crop_data"));

--Verify the Normalization
SELECT Yield, normalized_yield FROM "crop_data" ORDER BY normalized_yield;
*/


--** Create a New Table for Corn Data, corn_data with the same structure as crop_data
CREATE TABLE corn_data AS 
SELECT * 
FROM "crop_data"
WHERE CROP = 'Maize';

INSERT INTO corn_data 
SELECT * FROM "crop_data"
WHERE CROP = 'Maize';


//*
--**Feature Engineering

--*Create a New Feature: Yield per Acre, Area_in_acres

ALTER TABLE corn_data ADD COLUMN Area_in_acres NUMBER;
ALTER TABLE corn_data ADD COLUMN Yield_per_acre NUMBER;
DESC TABLE corn_data;

UPDATE corn_data
SET Area_in_acres = "AREA" * 2.47105;
UPDATE corn_data 
SET Yield_per_acre = PRODUCTION / NULLIF(Area_in_acres, 0);

SELECT * FROM "crop_data"
WHERE CROP ILIKE 'Maize';