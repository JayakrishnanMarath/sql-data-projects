
-- US House Hold Income Project :

SELECT * 
FROM ushouseholdincome;
SELECT * 
FROM us_household_income_statistics;

ALTER TABLE us_household_income_statistics RENAME COLUMN `ï»¿id` TO `id`;

# Data Cleaning:

-- The query below is to check how many rows SQL didnt import by comparing both tables and there are substantial amount of rows which wasn't imported in the primary table.
 
SELECT COUNT(id)
FROM ushouseholdincome;
SELECT COUNT(id)
FROM us_household_income_statistics;

-- Finding duplicates and removing them:

SELECT id, COUNT(id)
FROM ushouseholdincome
GROUP BY id
HAVING COUNT(id) > 1
;

-- We did find a few duplicates from the field "id" and we will remove them.

DELETE FROM ushouseholdincome
WHERE row_id IN(
	SELECT row_id
		FROM (SELECT row_id, id,
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY row_id ASC) AS Row_num
		FROM ushouseholdincome) AS Duplicates_table
	WHERE Row_num > 1)
;

-- We check the same for table which contain the statistic, but it doesn't have any duplicates.

SELECT id, COUNT(id)
FROM us_household_income_statistics
GROUP BY id
HAVING COUNT(id) > 1
;


-- We are checking for names with duplicates or not standardized

SELECT State_Name, COUNT(State_Name)
FROM ushouseholdincome
GROUP BY State_Name
;

-- From the code below we have one main issue which is Georgia and georia which have been mis spelled, we need to fix that, with another issue being Alabama with another row named alabama in small letters, but when doing group by we are not having that issue, so it won't be much of an issue.

-- Fixing Georgia name:

UPDATE ushouseholdincome
SET State_Name = 'Georgia'
WHERE State_Name = 'georia'
;

UPDATE ushouseholdincome
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama'
;

-- There is a value missing in the column "Place", we can fix that as well by comparing its current values.

SELECT *
FROM ushouseholdincome
WHERE Place = ""
;

 UPDATE ushouseholdincome
SET Place = "Autaugaville"
WHERE Place = ""
;

SELECT * 
FROM ushouseholdincome
WHERE City = "Vinemont"
ORDER BY City;

-- Now we check for any missing values in Type column:

-- From the below query we find 2 issues, (CDP and CPD), (Borough and Boroughs), by looking at the value, we can see which one is the original one, we find by comparing the COUNT(Type), one with 2 and another with 988.

-- For the CDP/CPD we dont have much information to backup the fact that it is a redundant file, so we don't change that.

-- We can update it.
SELECT Type, COUNT(Type)
FROM ushouseholdincome
GROUP BY Type
;

UPDATE ushouseholdincome
SET Type = "Borough"
WHERE Type = 'Boroughs'
;

-- Now we check for any missing values in AWater column:

SELECT ALand, Awater
FROM ushouseholdincome
WHERE AWater = "0" OR AWater = "" OR AWater = NULL
;

SELECT DISTINCT Awater
FROM ushouseholdincome
WHERE AWater = "0" OR AWater = "" OR AWater = NULL
;

-- We are good with AWater, it doesn't have any distinct value in the condition above, we need to check for ALand as well..

SELECT ALand, Awater
FROM ushouseholdincome
WHERE ALand = "0" OR ALand = "" OR ALand = NULL
;

SELECT DISTINCT ALand
FROM ushouseholdincome
WHERE ALand = "0" OR ALand = "" OR ALand = NULL
;

-- We are good with "ALand" as well, run the query below for confirmation.

SELECT ALand, Awater
FROM ushouseholdincome
WHERE (ALand = "0" OR ALand = "" OR ALand = NULL)
AND (AWater = "0" OR AWater = "" OR AWater = NULL)
;

 # EXPLORATORY DATA ANALYSIS :
 
 -- To find the top 10 state which has the most land and water
 
 SELECT State_Name, ALand, AWater
 FROM ushouseholdincome
 ;
 
SELECT State_Name, SUM(ALand)AS Total_Land, SUM(AWater) AS Total_Water
FROM ushouseholdincome
GROUP BY State_Name
ORDER BY 2 DESC
LIMIT 10
;
 
SELECT State_Name, SUM(ALand)AS Total_Land, SUM(AWater) AS Total_Water
FROM ushouseholdincome
GROUP BY State_Name
ORDER BY 3 DESC
LIMIT 10
;

-- Now we connect both tables to do some operations and correlations


SELECT *
FROM ushouseholdincome usinc
	JOIN us_household_income_statistics usstat
		USING(id)
WHERE MEAN <> 0;

-- We will calculate the average of mean incomes and the average of median incomes across regions


-- ORDERED BY HIGHEST AVERAGE OF MEAN INCOME OF DIFFERENT STATES

SELECT usinc.State_Name, 
ROUND(AVG(Mean),2) AS Average_Mean_Income , 
ROUND(AVG(Median),2) AS Average_Median_Income
FROM ushouseholdincome usinc
	JOIN us_household_income_statistics usstat
		USING(id)
WHERE Mean <> 0
GROUP BY usinc.State_Name
ORDER BY 2 DESC
LIMIT 10
;

-- ORDERED BY HIGHEST AVERAGE OF MEDIAN INCOME OF DIFFERENT STATES

SELECT usinc.State_Name, 
ROUND(AVG(Mean),2) AS Average_Mean_Income , 
ROUND(AVG(Median),2) AS Average_Median_Income
FROM ushouseholdincome usinc
	JOIN us_household_income_statistics usstat
		USING(id)
WHERE Mean <> 0
GROUP BY usinc.State_Name
ORDER BY 3 DESC
LIMIT 10
;

-- We will do the same for "Type" column:

-- HIGH AVERAGE MEAN OF EACH "TYPE"  :

SELECT Type, COUNT(Type),
ROUND(AVG(Mean),2) AS Average_Mean_Income , 
ROUND(AVG(Median),2) AS Average_Median_Income
FROM ushouseholdincome usinc
	JOIN us_household_income_statistics usstat
		USING(id)
WHERE Mean <> 0
GROUP BY Type
HAVING COUNT(Type) > 100
ORDER BY 3 DESC
LIMIT 20
;

-- HIGH AVERAGE MEDIAN OF EACH "TYPE":

SELECT Type, COUNT(Type),
ROUND(AVG(Mean),2) AS Average_Mean_Income , 
ROUND(AVG(Median),2) AS Average_Median_Income
FROM ushouseholdincome usinc
	JOIN us_household_income_statistics usstat
		USING(id)
WHERE Mean <> 0
GROUP BY Type
HAVING COUNT(Type) > 100
ORDER BY 4 DESC
LIMIT 20
;

-- TO FIND THE HIGHEST AVERAGE AND MEDIAN INCOME IN CITY COLUMN:

SELECT usinc.State_Name, city,
ROUND(AVG(Mean),1) AS Average_Mean_Income, 
ROUND(AVG(Median),1) AS Average_Median_Income
FROM ushouseholdincome usinc
	JOIN us_household_income_statistics usstat
		USING(id)
WHERE Mean <> 0
GROUP BY usinc.State_Name, city
ORDER BY 3 DESC
LIMIT 10
;

----- END OF THE PROJECT


SELECT * 
FROM ushouseholdincome;
SELECT * 
FROM us_household_income_statistics;