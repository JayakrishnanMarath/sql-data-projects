-- Importing this amount of data through table data import wizard takes a lot of time, so we create a table and then load the data from SQL folder.

CREATE TABLE user_games (
    User_ID INT,
    Games_Played INT,
    Datetime VARCHAR(50)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/user_games.csv'
INTO TABLE user_games
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; -- To ignore the header ofcourse.

SELECT *
FROM user_games;

SELECT COUNT(User_ID) -- To verify that all the data is imported
FROM user_games;

-- We import the other 2 tables as well, the same way.

CREATE TABLE amount_deposited (
    User_ID INT,
    Datetime VARCHAR(50),
    Amount_Deposited INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/amount_deposited.csv'
INTO TABLE amount_deposited
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

SELECT *
FROM amount_deposited;

SELECT COUNT(User_ID)
FROM amount_deposited;

		 -- Two tables are imported properly, now we need to import the final one as well.

CREATE TABLE amount_withdrawn (
    User_ID INT,
    Datetime VARCHAR(50),
    Amount_Withdrawn INT
);         

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/amount_withdrawn.csv'
INTO TABLE amount_withdrawn
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;          

SELECT *
FROM amount_withdrawn;

SELECT COUNT(User_ID)
FROM amount_withdrawn;

  -- All of the dates were imported as VARCHAR, we need to convert them to Date time format, to use them.
  
ALTER TABLE amount_deposited 
ADD COLUMN datetime_converted DATETIME;

UPDATE amount_deposited
SET datetime_converted = STR_TO_DATE(Datetime, '%d-%m-%Y %H:%i');

SELECT *
FROM amount_deposited;

ALTER TABLE amount_deposited 
DROP COLUMN Datetime;
ALTER TABLE amount_deposited 
CHANGE COLUMN datetime_converted `Datetime` DATETIME;

SELECT *
FROM amount_deposited;

-- We do this for other 2 tables:

ALTER TABLE amount_withdrawn 
ADD COLUMN datetime_converted DATETIME;

UPDATE amount_withdrawn
SET datetime_converted = STR_TO_DATE(Datetime, '%d-%m-%Y %H:%i');

ALTER TABLE amount_withdrawn 
DROP COLUMN `Datetime`;
ALTER TABLE amount_withdrawn 
CHANGE COLUMN datetime_converted `Datetime` DATETIME;

SELECT * 
FROM amount_withdrawn;

	-- Final Table

ALTER TABLE user_games
ADD COLUMN Datetime_cleaned DATETIME;

UPDATE user_games
SET Datetime_cleaned = STR_TO_DATE(Datetime, '%d-%m-%Y %H:%i');

ALTER TABLE user_games 
DROP COLUMN `Datetime`;
ALTER TABLE user_games 
CHANGE COLUMN Datetime_cleaned `Datetime` DATETIME;

SELECT COUNT(DISTINCT User_ID)
FROM user_games;

SELECT DISTINCT YEAR(`datetime`) 
FROM amount_deposited;  -- To verify all the dates where converted.

-- Now the importing is complete and the data is already cleaned, lets do some EDA.


	-- Q1: Find Playerwise Loyalty points earned by Players in the following slots- A: 2nd October Slot S1, B: 16th October Slot S2, C: 18th October Slot S1, D: 26th October Slot S2


WITH Q1_S1 AS (
SELECT g.User_ID, 
ROUND(SUM((0.01 * IFNULL(d.Amount_Deposited, 0)) +(0.005 * IFNULL(w.Amount_Withdrawn, 0)) +
(0.001 * GREATEST(IFNULL(d.Amount_Deposited, 0) - IFNULL(w.Amount_Withdrawn, 0), 0)) +(0.2 * IFNULL(g.Games_Played, 0))), 2) AS  OCT_2ND_S1
FROM user_games g
LEFT JOIN amount_deposited d 
	ON g.User_ID = d.User_ID AND g.Datetime = d.Datetime
LEFT JOIN amount_withdrawn w 
	ON g.User_ID = w.User_ID AND g.Datetime = w.Datetime
WHERE MONTH(g.Datetime) = 10 
AND DAY(g.Datetime)= 2 
AND TIME(g.Datetime) BETWEEN '00:00:00' AND '11:59:59'
GROUP BY g.User_ID
),
Q2_S2 AS (
SELECT g.User_ID, 
ROUND(SUM((0.01 * IFNULL(d.Amount_Deposited, 0)) +(0.005 * IFNULL(w.Amount_Withdrawn, 0)) +
(0.001 * GREATEST(IFNULL(d.Amount_Deposited, 0) - IFNULL(w.Amount_Withdrawn, 0), 0)) +(0.2 * IFNULL(g.Games_Played, 0))), 2) AS  OCT_16th_S2
FROM user_games g
LEFT JOIN amount_deposited d 
	ON g.User_ID = d.User_ID AND g.Datetime = d.Datetime
LEFT JOIN amount_withdrawn w 
	ON g.User_ID = w.User_ID AND g.Datetime = w.Datetime
WHERE MONTH(g.Datetime) = 10 
AND DAY(g.Datetime)= 16 
AND TIME(g.Datetime) BETWEEN '12:00:00' AND '23:59:59'
GROUP BY g.User_ID
),
Q3_S1 AS (
SELECT g.User_ID, 
ROUND(SUM((0.01 * IFNULL(d.Amount_Deposited, 0)) +(0.005 * IFNULL(w.Amount_Withdrawn, 0)) +
(0.001 * GREATEST(IFNULL(d.Amount_Deposited, 0) - IFNULL(w.Amount_Withdrawn, 0), 0)) +(0.2 * IFNULL(g.Games_Played, 0))), 2) AS  OCT_18th_S1
FROM user_games g
LEFT JOIN amount_deposited d 
	ON g.User_ID = d.User_ID AND g.Datetime = d.Datetime
LEFT JOIN amount_withdrawn w 
	ON g.User_ID = w.User_ID AND g.Datetime = w.Datetime
WHERE MONTH(g.Datetime) = 10 
AND DAY(g.Datetime)= 18 
AND TIME(g.Datetime) BETWEEN '00:00:00' AND '11:59:59'
GROUP BY g.User_ID
),
Q4_S2 AS (
SELECT g.User_ID, 
ROUND(SUM((0.01 * IFNULL(d.Amount_Deposited, 0)) +(0.005 * IFNULL(w.Amount_Withdrawn, 0)) +
(0.001 * GREATEST(IFNULL(d.Amount_Deposited, 0) - IFNULL(w.Amount_Withdrawn, 0), 0)) +(0.2 * IFNULL(g.Games_Played, 0))), 2) AS  OCT_26th_S2
FROM user_games g
LEFT JOIN amount_deposited d 
	ON g.User_ID = d.User_ID AND g.Datetime = d.Datetime
LEFT JOIN amount_withdrawn w 
	ON g.User_ID = w.User_ID AND g.Datetime = w.Datetime
WHERE MONTH(g.Datetime) = 10 
AND DAY(g.Datetime)= 26 
AND TIME(g.Datetime) BETWEEN '12:00:00' AND '23:59:59'
GROUP BY g.User_ID
)
SELECT COALESCE(q1.User_ID, q2.User_ID, q3.User_ID, q4.User_ID) AS User_ID,
COALESCE(q1.OCT_2ND_S1,0)	AS Loyalty_Point_OCT2_S1,
COALESCE(q2.OCT_16th_S2,0)	AS Loyalty_Point_OCT16_S2,
COALESCE(q3.OCT_18th_S1,0)	AS Loyalty_Point_OCT18_S1,
COALESCE(q4.OCT_26th_S2,0)	AS Loyalty_Point_OCT26_S2
FROM Q1_S1 q1
LEFT JOIN Q2_S2 q2 
	ON q1.User_ID = q2.User_ID
LEFT JOIN Q3_S1 q3 
	ON q1.User_ID = q3.User_ID
LEFT JOIN Q4_S2 q4 
	ON q1.User_ID = q4.User_ID
ORDER BY User_ID
;


	-- Q2: Calculate overall "loyalty points" earned and rank players on the basis of loyalty points in the month of "October", In case of "tie", number of "games played" should be taken as the next criteria for ranking.
 
WITH user_loyalty AS (
SELECT g.User_ID,
ROUND(SUM((0.01 * IFNULL(d.Amount_Deposited, 0)) +(0.005 * IFNULL(w.Amount_Withdrawn, 0)) 
+ (0.001 * GREATEST(IFNULL(d.Amount_Deposited, 0) - IFNULL(w.Amount_Withdrawn, 0), 0)) 
+(0.2 * IFNULL(g.Games_Played, 0))), 2) AS Loyalty_Points,  -- Given Formula
SUM(g.Games_Played) AS Total_Games
FROM user_games g
LEFT JOIN amount_deposited d 
	ON g.User_ID = d.User_ID AND g.Datetime = d.Datetime
LEFT JOIN amount_withdrawn w 
	ON g.User_ID = w.User_ID AND g.Datetime = w.Datetime
WHERE MONTH(g.Datetime) = "10"
GROUP BY g.User_ID
),
ranked_users AS (
SELECT *,
ROW_NUMBER() OVER (ORDER BY Loyalty_Points DESC, Total_Games DESC) AS rnk
FROM user_loyalty
)
SELECT User_ID, Loyalty_Points
FROM ranked_users
ORDER BY rnk;

	-- Q3: What is the average deposit amount?

SELECT ROUND(AVG(Amount_Deposited),2) AS Average_Deposit_Amount
FROM amount_deposited
ORDER BY Average_Deposit_Amount DESC;

	-- Q4: What is the average deposit amount per user in a month?

SELECT User_ID, MONTH( `Datetime`) AS Month, ROUND(AVG(Amount_Deposited),2) AS Average_Deposit_Amount
FROM amount_deposited
WHERE MONTH(`Datetime`) = "10"
GROUP BY User_ID, `Datetime`
ORDER BY Average_Deposit_Amount DESC;

	-- Q5: What is the average number of games played per user?

SELECT User_ID, ROUND(AVG(Games_Played),2) AS Average_Games_Played
FROM user_games
GROUP BY User_ID
ORDER BY Average_Games_Played DESC;

	-- Q6: After calculating the loyalty points for the whole month find out which 50 players are at the top of the leaderboard, Should they base it on the amount of loyalty points? Should it be based on number of games? Or something else?, your choice:
    
SELECT g.User_ID,
ROUND(SUM((0.01 * IFNULL(d.Amount_Deposited, 0)) +(0.005 * IFNULL(w.Amount_Withdrawn, 0)) 
+ (0.001 * GREATEST(IFNULL(d.Amount_Deposited, 0) - IFNULL(w.Amount_Withdrawn, 0), 0)) 
+(0.2 * IFNULL(g.Games_Played, 0))), 2) AS Loyalty_Points  -- Given Formula
FROM user_games g
LEFT JOIN amount_deposited d 
	ON g.User_ID = d.User_ID AND g.Datetime = d.Datetime
LEFT JOIN amount_withdrawn w 
	ON g.User_ID = w.User_ID AND g.Datetime = w.Datetime
WHERE MONTH(g.Datetime) = "10"
GROUP BY g.User_ID
ORDER BY Loyalty_Points DESC
LIMIT 50;

#Hypothesis:

		-- The Loyalty Points is derived by calculating the withdrawn amount, deposited amount and games played, dividing the bonus money by either of them isn't logical, but thats why we created the Loyalty points, find the total sum of all the 50 players loyalty points and then find percentage of how much each player contributed to it and distributing the bonus amount by that percentage.

		-- Example :  If the total Loyalty points from 50 players are 10,000 and one of the players has contributed 1000 points, then they contributed 10% of Loyalty points in the total, which means, they will recieve 10% of the Bonus amount, if the bonus amount is 50,000 then that player will recieve 5,000.

		-- It is an simple and efficient method for dividing bonus amount and the base of the calculation goes directly back to how much activity the player has in the platform.



	-- Q6: Would you say the loyalty point formula is fair or unfair?, Can you suggest any way to make the loyalty point formula more robust?
    
WITH abc_company AS (
SELECT g.User_ID,
ROUND(SUM((0.01 * IFNULL(d.Amount_Deposited, 0)) +(0.005 * IFNULL(w.Amount_Withdrawn, 0)) 
+ (0.001 * GREATEST(IFNULL(d.Amount_Deposited, 0) - IFNULL(w.Amount_Withdrawn, 0), 0)) 
+(0.2 * IFNULL(g.Games_Played, 0))), 2) AS Loyalty_Points  -- Given Formula
FROM user_games g
LEFT JOIN amount_deposited d 
	ON g.User_ID = d.User_ID AND g.Datetime = d.Datetime
LEFT JOIN amount_withdrawn w 
	ON g.User_ID = w.User_ID AND g.Datetime = w.Datetime
WHERE MONTH(g.Datetime) = "10"
GROUP BY g.User_ID
ORDER BY Loyalty_Points DESC
LIMIT 50
)
SELECT SUM(Loyalty_Points) AS Top_50_Total_Loyalty_Points
FROM abc_company;     -- This code will output the total sum of first 50 players loyalty points.
  

-- From the above code, it is visible that '58068.94' is the  Total Loyalty Points of top 50 players, the player '16' has acquired the amount of total '4565.92' Loyalty points which is almost 7.80% of the total top 50 Players contribution, then that player will recieve a sum of 3,900(7.80% of 50,000) out of 50,000 from total bonus amount . 

SELECT SUM(Amount_Deposited)
FROM amount_deposited
WHERE User_ID = "16" AND Month(`Datetime`) = "10" -- Total Amount Deposited
;

SELECT SUM(Amount_Withdrawn)
FROM amount_withdrawn
WHERE User_ID = "16" AND Month(`Datetime`) = "10"  -- Total Amount withdrawn
;

-- Now the total amount the player having User_ID "16" has deposited is: '3,60,201' on the month of october, The amount the player has withdrawn is '4,18,387', the profit for that player was "58,186", which is 16% of the what he deposited, now for that player the bonus amount "3,900" is 6% of his total profit.

-- Now to our main question, is the formula fair or not fair? i'd say our current model isn't fair, the bonus amount should come close to atleast 10% of the players total profit, here it is 6%, but we can make another formula to check before distributing the bonus amount, to make it fair.

-- ((Percentage of player contribution in top 50(eg:0.07 for 7%) * total bonus amount) / (Total Amount deposited - Total Amount Withdrawn )) *100 = how much percentage of profit is the bonus amount.

-- percentage of Player contribution in the top 50 = (player total Loyalty points / Total Bonus amount) * 100

-- eg: ((0.078 * 50,000) / 58,186) * 100 = 6.7% of the profit he made, it correlates with profit he gained.

-- Now if the percentage from above formula is >= 10, then its fair, dont have to change anything, but if its below 10%, then we need to increase the Loyalty Points for the player to make it close to or 10% or give an extra loyalty point boost to them to make it fair.

--------------------------------------------------------------------------------------------------------------------------------------------

SELECT * 
FROM amount_withdrawn;

SELECT *
FROM amount_deposited;

SELECT *
FROM user_games;









     
     
         