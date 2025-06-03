SELECT *
FROM world_life_expectancy;

-- Removing Duplicates:

DELETE FROM world_life_expectancy
WHERE Row_ID IN (
	SELECT Row_id
	FROM 
		(SELECT Row_ID,
		CONCAT(Country, Year),
		ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year) )AS Row_num
		FROM world_life_expectancy) AS Row_table
	WHERE Row_num > 1)
;

-- Populating Blank spaces in column "Status" with developing/ developed depending upon the similar data from the same country, different year.

SELECT *
FROM world_life_expectancy
WHERE status = "";

UPDATE world_life_expectancy t1
	JOIN world_life_expectancy t2 USING (Country)
SET t1.Status = "Developed"
	WHERE t1.Status = ""
    AND t2.Status <> ""
    AND t2.Status = "Developed"
    ;
    
-- POPULATING LIFE EXPECTENCY COLUMN BY USING AVERAGE.


SELECT Country, Year, `Life expectancy`
FROM worldlifeexpectancy_backup
WHERE `Life expectancy` = ""
;

-- The Query below is to check if the operation of doing averages with 3 tables are correct or not before updating, Here Main three things to be confused in this query is why 3 Tables, why use AND operator and whats the purpose:


-- The Purpose of the query is to find the average of a column value `Life expectancy` by using previous and next year value. 
-- To make this happen, we use 3 tables, on the AND in the first JOIN, we put -1 to put the next year value in the same row as the missing value in first table, we do the same with third column to put previous year expectancy value in the same row as the missing value in the first table.
-- Now we can use both these 2 tables to find the average to place inside the first table missing column, for that we use WHERE to only affect the rows with "blank".
 
SELECT t1.Country, t1.Year, t1.`Life expectancy`, 
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND(( t2.`Life expectancy`+ t3.`Life expectancy`)/ 2 ,1) AS Life_Expectance
FROM world_life_expectancy t1
	JOIN world_life_expectancy t2 
		ON t1.Country = t2.Country
		AND t1.YEAR = t2.YEAR - 1
    JOIN world_life_expectancy t3
		ON t1.Country = t3.Country
		AND t1.YEAR = t3.YEAR + 1
WHERE t1.`Life expectancy` = ""
;

-- Now we do the same for UPDATE statement, to replace the values in the original table.

UPDATE world_life_expectancy t1
	JOIN world_life_expectancy t2
		ON t1.Country = t2.Country 
        AND t1.YEAR = t2.YEAR - 1
	JOIN world_life_expectancy t3
		ON t1.Country = t3.Country
        AND t1.YEAR = t3.YEAR + 1
	SET t1.`Life expectancy` = ROUND(( t2.`Life expectancy`+ t3.`Life expectancy`)/ 2 ,1)
    WHERE t1.`Life expectancy` = ""
    ;


-- EXPLORATORY DATA ANALYSIS (EDA)


SELECT *
FROM world_life_expectancy ;

   #1: TO FIND THE LIFE SPAN INCREASED WITH 15 YEARS FOR EACH COUNTRIES, TO FIND THE COUNTRY WITH THE BIGGEST JUMP.

SELECT Country,
MIN(`Life expectancy`) AS Minimum_Life_Expectancy,
MAX(`Life expectancy`) AS Maximum_Life_Expectancy,
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) AS Life_Increase_By_15Years
FROM world_life_expectancy
GROUP BY Country
HAVING Minimum_Life_Expectancy <> 0
AND Maximum_Life_Expectancy <> 0
ORDER BY Life_Increase_By_15Years DESC
;

-- Finding the Average Life Expectency

SELECT Year, ROUND(AVG(`Life expectancy`),2)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year
;

-- Finding if there are any correlation between GDP and Life expectency.
 
SELECT `Life expectancy`, GDP
FROM world_life_expectancy;

SELECT Country, ROUND(AVG(`Life expectancy`),2) AS Life_Span,ROUND(AVG(GDP),2) AS GDP_AVG
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Span >0
AND GDP_AVG >0
ORDER BY GDP_AVG DESC
;
 
 -- Writing  query to show which country has high life expectency using GDP in CASE statement.

-- In the query below, if GDP is greater than 1500 it adds 1 to the sum of rows else 0, and returns the sum of rows and for AVG it returns the average of GDP's rows which were greater than 1500, same for Low.
-- The reason for replacing ZERO with NULL is because in terms of sum it doesn't affect the sum, but for average, when 0 gets averaged it reduces the original value.

SELECT 
	SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) AS High_GDP_Count,
   ROUND(AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END),2)  AS High_Life_Expectency_Count,
    SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) AS Low_GDP_Count,
   ROUND(AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END),2) AS Low_Life_Expectency_Count
FROM world_life_expectancy;

 
 -- To find the Life Expectency based on status of both developed and developing countries to compare them.

 SELECT Status, ROUND(AVG(`Life expectancy`),2) AS Life_Expectency
FROM world_life_expectancy
GROUP BY Status
ORDER BY Status;
 
 -- Now the above code is skewed a lot, because it has less values in developed and more in developing, lets check how many:
 
SELECT Status, COUNT(DISTINCT Country) AS Count_Status, ROUND(AVG(`Life expectancy`),2) AS AVG_Life_Expectency
FROM world_life_expectancy
GROUP BY Status;

-- Now we can do a little check for BMI with Countries.

SELECT Country, BMI
FROM world_life_expectancy;

SELECT Country, ROUND(AVG(`Life expectancy`),2) AS AVG_Life_Expectency, ROUND(AVG(BMI),2) AS AVG_BMI
FROM world_life_expectancy
GROUP BY Country
HAVING AVG_Life_Expectency > 0
AND AVG_BMI > 0
ORDER BY AVG_Life_Expectency DESC ;

-- Now lets check for Adult Mortality using rolling total

SELECT Country,
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy ;


SELECT *
FROM world_life_expectancy;
