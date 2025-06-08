
	#Automation:

		-- We add a new table with extra column named 'Timestamp', this is used to know on what time stamp the automation worked on or updated, this is for future reference. In the query below in the end, we added a new table named `TimeStamp`

DELIMITER $$
DROP PROCEDURE IF EXISTS copy_and_clean_data;
CREATE PROCEDURE copy_and_clean_data()
BEGIN
	-- Creating a table:
CREATE TABLE IF NOT EXISTS`us_household_income_clean` (
  `row_id` int DEFAULT NULL,
  `id` int DEFAULT NULL,
  `State_Code` int DEFAULT NULL,
  `State_Name` text,
  `State_ab` text,
  `County` text,
  `City` text,
  `Place` text,
  `Type` text,
  `Primary` text,
  `Zip_Code` int DEFAULT NULL,
  `Area_Code` int DEFAULT NULL,
  `ALand` int DEFAULT NULL,
  `AWater` int DEFAULT NULL,
  `Lat` double DEFAULT NULL,
  `Lon` double DEFAULT NULL,
  `TimeStamp` TIMESTAMP DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	-- Copy data into a table:
    
		INSERT INTO us_household_income_clean
		SELECT*, CURRENT_TIMESTAMP
		FROM automated_cleaning_staging;

        
	-- Data Cleaning
	
    -- Remove Duplicates
DELETE FROM us_household_income_clean 
WHERE row_id IN (
	SELECT row_id
	FROM (
		SELECT row_id, id,
		ROW_NUMBER() OVER (PARTITION BY id, `TimeStamp` ORDER BY id, `TimeStamp`) AS row_num
		FROM us_household_income_clean) duplicates
	WHERE 
	row_num > 1
);

-- Fixing some data quality issues by fixing typos and general standardization

UPDATE us_household_income_clean
SET State_Name = 'Georgia'
WHERE State_Name = 'georia';

UPDATE us_household_income_clean
SET County = UPPER(County);

UPDATE us_household_income_clean
SET City = UPPER(City);

UPDATE us_household_income_clean
SET Place = UPPER(Place);

UPDATE us_household_income_clean
SET State_Name = UPPER(State_Name);

UPDATE us_household_income_clean
SET `Type` = 'CDP'
WHERE `Type` = 'CPD';

UPDATE us_household_income_clean
SET `Type` = 'Borough'
WHERE `Type` = 'Boroughs';

    
END $$
DELIMITER ;

CALL copy_and_clean_data();

		-- Verifying if the code ran perfectly:
        
DELETE FROM us_household_income_clean 
WHERE row_id IN (
	SELECT row_id
	FROM (
		SELECT row_id, id,
		ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) AS row_num
		FROM us_household_income_clean) duplicates
	WHERE 
	row_num > 1
);

SELECT COUNT(row_id)
FROM us_household_income_clean;

SELECT State_Name, COUNT(State_Name)
FROM us_household_income_clean
GROUP BY State_Name;

		-- Creating EVENT:
        
DROP EVENT IF EXISTS run_data_cleaning;
CREATE EVENT run_data_cleaning
	ON SCHEDULE EVERY 30 DAY
    DO CALL copy_and_clean_data();

SELECT DISTINCT timestamp
FROM us_household_income_clean;

		-- Note for above, every 2 minutes it takes values from the table automated_cleaning_staging and puts it above the current values and clean the data and it will have the timestamp of every 2 minutes, now in the delete statement inside the procedure, it is partitioned by id and deleted if the row_num is greater than 2, now when the second cleaning hits, the delete statement looks for row_num > 1 for id, and there are 2 id numbers, 1 which is the first cleaned and 1 which is the next cleaned, each one has different timestamp, but it deletes one of them, over time, it overlaps each other and the table will get emptied, to fix this, we partition by `Timestamp` Column as well, meaning it only deletes if there is a duplicate which has same values for both id and TimeStamp.
        
		-- You cannot create a trigger with a call for procedure which has a CREATE table method used. it returns error.
        
SELECT *
FROM us_household_income_clean;


					-- END OF Automated Data Cleaning Project.

