--Check number of females and males in the data set

SELECT sex, COUNT (*) AS gender_count
FROM PortfolioProjects.dbo.MedInsurance
GROUP BY sex


SELECT *
FROM PortfolioProjects.dbo.MedInsurance

--Rename the charges column to med_insurance_cost and also change the data type to an integer to make it more readable

SELECT CAST (charges AS INT) AS med_insurance_cost
FROM PortfolioProjects.dbo.MedInsurance

--Check to see if the above query worked

SELECT *
FROM PortfolioProjects.dbo.MedInsurance

--Gender distribution of smokers and non-smokers

SELECT sex,smoker, COUNT (smoker) AS gender_smoker_count
FROM PortfolioProjects.dbo.MedInsurance
GROUP BY sex, smoker

--Use BMI to classify individuals into 'under_weight', 'healthy_weight', 'overweight' and 'Obese' category

SELECT *,
CASE WHEN bmi < 18.5 THEN 'under_weight'
	WHEN bmi BETWEEN 18.5 AND 24.9 THEN 'healthy_weight'
	WHEN bmi BETWEEN 25.0 AND 29.9 THEN 'over_weight'
	WHEN bmi >=30 THEN 'obese'
END AS weight_status
FROM PortfolioProjects.dbo.MedInsurance


-- Exploring the youngest and older age in the dataset to help establish the age bands 

SELECT MIN(age) AS youngest, MAX(age) AS oldest
FROM PortfolioProjects.dbo.MedInsurance

--Grouping individuals into 'young_adults', 'fully_grown', 'above_60'

SELECT *,
CASE WHEN age BETWEEN 18 AND 25 THEN 'young_adult'
	 WHEN age BETWEEN 26 AND 60 THEN 'fully_grown'
	 WHEN age > 60 THEN 'above_60'
END AS age_groupings
FROM PortfolioProjects.dbo.MedInsurance

--Use the above groupings as a sub-query to determine how many individuals are Obese or otherwise in each age groupings
--CAST bmi column to two decimal places to make the figures consistent

SELECT age, sex, CAST(bmi AS DECIMAL(10,2)) AS bmi_rounded,
CASE WHEN age BETWEEN 18 AND 25 THEN 'young_adult'
	 WHEN age BETWEEN 26 AND 60 THEN 'fully_grown'
	 WHEN age > 60 THEN 'above_60'
END AS age_groupings,
CASE WHEN bmi < 18.5 THEN 'under_weight'
	WHEN bmi BETWEEN 18.5 AND 24.9 THEN 'healthy_weight'
	WHEN bmi BETWEEN 25.0 AND 29.9 THEN 'over_weight'
	WHEN bmi >=30 THEN 'obese'
END AS weight_status
FROM PortfolioProjects.dbo.MedInsurance

--Distribution of age_groupings and count of weigth status, using the above as a sub-query

SELECT age_groupings, weight_status, COUNT(*) AS Count_per_group
FROM 
	(
	SELECT age, sex, CAST(bmi AS DECIMAL(10,2)) AS bmi_rounded,
CASE WHEN age BETWEEN 18 AND 25 THEN 'young_adult'
	 WHEN age BETWEEN 26 AND 60 THEN 'fully_grown'
	 WHEN age > 60 THEN 'above_60'
END AS age_groupings,
CASE WHEN bmi < 18.5 THEN 'under_weight'
	WHEN bmi BETWEEN 18.5 AND 24.9 THEN 'healthy_weight'
	WHEN bmi BETWEEN 25.0 AND 29.9 THEN 'over_weight'
	WHEN bmi >=30 THEN 'obese'
END AS weight_status
	FROM PortfolioProjects.dbo.MedInsurance
	) AS status
GROUP BY age_groupings, weight_status
ORDER BY age_groupings

--After the above query i realized some of the weight status had return NULL so wanted to investigate where they were coming from
--There were three ways we could have identified where the NULL values where coming from 1. Using a sub-query, 2. Using the case statement in the WHERE Clause to filter or 3. Using a CTE which is Common table expression.
--We will use both option 2 and 3 although option 3 CTE is more cleaner

--Option 2 - Using the case statement in the WHERE Clause to filter

SELECT bmi, region,
CASE WHEN bmi < 18.5 THEN 'under_weight'
	WHEN bmi BETWEEN 18.5 AND 24.9 THEN 'healthy_weight'
	WHEN bmi BETWEEN 25.0 AND 29.9 THEN 'over_weight'
	WHEN bmi >=30 THEN 'obese'
END AS weight_status
FROM PortfolioProjects.dbo.MedInsurance 
WHERE 
	(CASE 
        WHEN bmi < 18.5 THEN 'under_weight' 
        WHEN bmi BETWEEN 18.5 AND 24.9 THEN 'healthy_weight' 
        WHEN bmi BETWEEN 25.0 AND 29.9 THEN 'over_weight' 
        WHEN bmi >= 30 THEN 'obese' 
    END) IS NULL

--3. Using a CTE which is Common table expression

WITH WeightStatusTab AS (
	SELECT bmi, region,
		CASE WHEN bmi < 18.5 THEN 'under_weight'
			WHEN bmi BETWEEN 18.5 AND 24.9 THEN 'healthy_weight'
			WHEN bmi BETWEEN 25.0 AND 29.9 THEN 'over_weight'
			WHEN bmi >=30 THEN 'obese'
			--ELSE 'unkown'
		END AS weight_status
	FROM PortfolioProjects.dbo.MedInsurance 
)
SELECT bmi, weight_status
FROM WeightStatusTab
WHERE weight_status IS NULL

--To solve the above NULL issues had to first CAST the bmi column to two decimal places and to amend the CASE statement by increasing the weight bands to two decimal places

WITH WstatusTAB AS (
	SELECT age, sex, CAST(bmi AS DECIMAL(10,2)) AS bmi_rounded,
		CASE WHEN age BETWEEN 18 AND 25 THEN 'young_adult'
			WHEN age BETWEEN 26 AND 60 THEN 'fully_grown'
			WHEN age > 60 THEN 'above_60'
		END AS age_groupings,
		CASE WHEN bmi < 18.5 THEN 'under_weight'
			WHEN bmi BETWEEN 18.50 AND 24.99 THEN 'healthy_weight'
			WHEN bmi BETWEEN 25.0 AND 29.99 THEN 'over_weight'
			WHEN bmi >=30 THEN 'obese'
		END AS weight_status
	FROM PortfolioProjects.dbo.MedInsurance
) 
SELECT age_groupings, weight_status, COUNT(*) AS weight_count
FROM WstatusTAB
GROUP BY age_groupings, weight_status
ORDER BY age_groupings

--Window function calculating percentage of total to know the percentage distribution in each age grouping

WITH WstatusTAB AS (
	SELECT age, sex, CAST(bmi AS DECIMAL(10,2)) AS bmi_rounded,
		CASE WHEN age BETWEEN 18 AND 25 THEN 'young_adult'
			WHEN age BETWEEN 26 AND 60 THEN 'fully_grown'
			WHEN age > 60 THEN 'above_60'
		END AS age_groupings,
		CASE WHEN bmi < 18.5 THEN 'under_weight'
			WHEN bmi BETWEEN 18.50 AND 24.99 THEN 'healthy_weight'
			WHEN bmi BETWEEN 25.0 AND 29.99 THEN 'over_weight'
			WHEN bmi >=30 THEN 'obese'
		END AS weight_status
	FROM PortfolioProjects.dbo.MedInsurance
)
SELECT age_groupings, weight_status, COUNT(*) AS weight_count
FROM WstatusTAB
GROUP BY age_groupings, weight_status
ORDER BY age_groupings


--test
--Had to CAST both the cat_count and cat_total columns to decimals in order for the percent_of_cat to show as decimals.
--First create a sub-query 'statuss' which returns all columns together with the 'age_groupings' and 'weight_status'
--Then used the outer-query to count the number of observations per sub-category i.e under_weight, healthy_weight, over_weight, and obese for each age_grouping ,
--Then queried by my CTE table, i used the SUM Window function to get the sub-total count per age_grouping using that to calculate my 'percent_of_cat' column

WITH Testtable AS (
	SELECT statuss.age_groupings, statuss.weight_status, COUNT(*) AS cat_count
	FROM 
	(
		SELECT *, CAST(bmi AS DECIMAL(10,2)) AS bmi_rounded,
			CASE WHEN age BETWEEN 18 AND 25 THEN 'young_adult'
				WHEN age BETWEEN 26 AND 60 THEN 'fully_grown'
				WHEN age > 60 THEN 'above_60'
			END AS age_groupings,
			CASE WHEN bmi < 18.5 THEN 'under_weight'
				WHEN bmi BETWEEN 18.50 AND 24.99 THEN 'healthy_weight'
				WHEN bmi BETWEEN 25.00 AND 29.99 THEN 'over_weight'
				WHEN bmi >=30 THEN 'obese'
			END AS weight_status
		FROM PortfolioProjects.dbo.MedInsurance
	) AS statuss
	GROUP BY statuss.age_groupings, statuss.weight_status
)
SELECT tt.age_groupings, tt.weight_status, CAST(tt.cat_count AS DECIMAL(10,2)) AS cat_count, CAST(SUM(tt.cat_count) OVER (PARTITION BY tt.age_groupings ORDER BY tt.age_groupings) AS DECIMAL(10,2)) AS cat_total, CAST(cat_count * 100.00 / SUM(tt.cat_count) OVER (PARTITION BY tt.age_groupings ORDER BY tt.age_groupings) AS DECIMAL(10,2)) AS percent_of_cat
FROM Testtable tt
ORDER BY tt.age_groupings
