--The smallest and largest GDP in 2020

SELECT MIN(GDP) AS SmallestGDP, MAX(GDP) AS LargestGDP
FROM PortfolioProjects.dbo.gdp_per_country_2020_2024
WHERE Year = 2024


--Top 5 Countries with the highest GDP in 2024
SELECT TOP 5 Country, GDP, Year, 'Max' as Type
FROM PortfolioProjects.dbo.gdp_per_country_2020_2024
WHERE Year = 2024
ORDER BY GDP DESC;

--Top 5 Countries with the lowest GDP in 2024
SELECT TOP 5 Country, GDP, Year, 'Min' as Type
FROM PortfolioProjects.dbo.gdp_per_country_2020_2024
WHERE Year = 2024
ORDER BY GDP ASC;


--Top 5 Countries with the highest GDP in 2023
SELECT TOP 5 Country, GDP, Year, 'Max' as Type
FROM PortfolioProjects.dbo.gdp_per_country_2020_2024
WHERE Year = 2023
ORDER BY GDP DESC;

--Top 5 Countries with the lowest GDP in 2023
SELECT TOP 5 Country, GDP, Year, 'Min' as Type
FROM PortfolioProjects.dbo.gdp_per_country_2020_2024
WHERE Year = 2023
ORDER BY GDP ASC;


--Top 5 Countries with the highest GDP in 2022
SELECT TOP 5 Country, GDP, Year, 'Max' as Type
FROM PortfolioProjects.dbo.gdp_per_country_2020_2024
WHERE Year = 2022
ORDER BY GDP DESC;

--Top 5 Countries with the lowest GDP in 2022
SELECT TOP 5 Country, GDP, Year, 'Min' as Type
FROM PortfolioProjects.dbo.gdp_per_country_2020_2024
WHERE Year = 2022
ORDER BY GDP ASC;

--Top 5 Countries in Africa with the Largest GDP in 2024

SELECT TOP 5 C.Country, G.GDP
FROM PortfolioProjects.dbo.gdp_per_country_2020_2024 G
JOIN PortfolioProjects.dbo.countries_continents AS C
ON G.Country = C.Country
WHERE C.Continent = 'Africa' AND G.Year = 2024
ORDER BY G.GDP DESC


--Top 5 Countries in Asia with the Largest GDP in 2024

SELECT TOP 5 C.Country, G.GDP
FROM PortfolioProjects.dbo.gdp_per_country_2020_2024 G
JOIN PortfolioProjects.dbo.countries_continents AS C
ON G.Country = C.Country
WHERE C.Continent = 'Asia' AND G.Year = 2024
ORDER BY G.GDP DESC

--Top 5 Countries in Europe with the Largest GDP in 2024

SELECT TOP 5 C.Country, G.GDP
FROM PortfolioProjects.dbo.gdp_per_country_2020_2024 G
JOIN PortfolioProjects.dbo.countries_continents AS C
ON G.Country = C.Country
WHERE C.Continent = 'Europe' AND G.Year = 2024
ORDER BY G.GDP DESC

--Top 5 Countries in North America with the Largest GDP in 2024

SELECT TOP 5 C.Country, G.GDP
FROM PortfolioProjects.dbo.gdp_per_country_2020_2024 G
JOIN PortfolioProjects.dbo.countries_continents AS C
ON G.Country = C.Country
WHERE C.Continent = 'North America' AND G.Year = 2024
ORDER BY G.GDP DESC

--Top 5 Countries in Oceania with the Largest GDP in 2024

SELECT TOP 5 C.Country, G.GDP
FROM PortfolioProjects.dbo.gdp_per_country_2020_2024 G
JOIN PortfolioProjects.dbo.countries_continents AS C
ON G.Country = C.Country
WHERE C.Continent = 'Oceania' AND G.Year = 2024
ORDER BY G.GDP DESC

--Top 5 Countries in Other with the Largest GDP in 2024

SELECT TOP 5 C.Country, G.GDP
FROM PortfolioProjects.dbo.gdp_per_country_2020_2024 G
JOIN PortfolioProjects.dbo.countries_continents AS C
ON G.Country = C.Country
WHERE C.Continent = 'Other' AND G.Year = 2024
ORDER BY G.GDP DESC

--Top 5 Countries in South America with the Largest GDP in 2024

SELECT TOP 5 C.Country, G.GDP
FROM PortfolioProjects.dbo.gdp_per_country_2020_2024 G
JOIN PortfolioProjects.dbo.countries_continents AS C
ON G.Country = C.Country
WHERE C.Continent = 'South America' AND G.Year = 2024
ORDER BY G.GDP DESC

--Continents and their respective yearly GDPs

SELECT C.Continent,
	SUM(CASE WHEN G.Year = 2020 THEN GDP ELSE 0 END) AS GDP_2020,
	SUM(CASE WHEN G.Year = 2021 THEN GDP ELSE 0 END) AS GDP_2021,
	SUM(CASE WHEN G.Year = 2022 THEN GDP ELSE 0 END) AS GDP_2022,
	SUM(CASE WHEN G.Year = 2023 THEN GDP ELSE 0 END) AS GDP_2023,
	SUM(CASE WHEN G.Year = 2024 THEN GDP ELSE 0 END) AS GDP_2024
FROM PortfolioProjects.dbo.gdp_per_country_2020_2024 G
JOIN PortfolioProjects.dbo.countries_continents C
ON G.Country = C.Country
GROUP BY C.Continent
ORDER BY C.Continent

--Continents 2020 & 2024 GDPs and difference

SELECT Continent, 
[2020] AS GDP_2020,
[2024] AS GDP_2024, [2024]  - [2020] AS GDP_Change
FROM(
	SELECT C.Continent, G.Year, G.GDP
	FROM PortfolioProjects.dbo.gdp_per_country_2020_2024 G
	JOIN PortfolioProjects.dbo.countries_continents C
	ON G.Country = C.Country
	) AS Continent_Data
PIVOT 
	(
		SUM(GDP)
		FOR Year IN ([2020], [2024])
	) AS PivotTable
ORDER BY Continent


-- Percentage change in GDP using 2020 as the base year against 2024

SELECT 
    Continent,
    [2020] AS GDP_2020,                
    [2024] AS GDP_2024,                
    [2024] - [2020] AS GDP_Difference,
    -- Calculate % change: (New - Old) / Old * 100
    -- NULLIF ensures we don't divide by zero if 2020 is empty
    CAST(([2024] - [2020]) * 100.0 / NULLIF([2020], 0) AS DECIMAL(10, 2)) AS Percentage_Change
FROM
    (
        SELECT 
            C.Continent, 
            G.Year, 
            G.GDP
        FROM PortfolioProjects.dbo.gdp_per_country_2020_2024 G                
        JOIN PortfolioProjects.dbo.countries_continents C 
          ON G.Country = C.Country
    ) AS Continent_Data
PIVOT
    (
        SUM(GDP)
        FOR Year IN ([2020], [2024])
    ) AS PivotTable
ORDER BY 
    Percentage_Change DESC; -- Optional: Orders by highest growth


-- Countries that fall under Other Continent

SELECT DISTINCT C.Country, C.Continent
FROM PortfolioProjects.dbo.gdp_per_country_2020_2024 G
JOIN PortfolioProjects.dbo.countries_continents AS C
ON G.Country = C.Country
WHERE C.Continent = 'Other'


--Top 5 Countries in each continent base on combined GDP from 2020-2024

WITH RankedGDP AS (
SELECT C.Continent, C.Country, SUM(G.GDP) AS Total_GDP, ROW_NUMBER() OVER (PARTITION BY Continent ORDER BY SUM(G.GDP) DESC) AS ROW_NUM
	FROM PortfolioProjects.dbo.gdp_per_country_2020_2024 G
	JOIN PortfolioProjects.dbo.countries_continents C
	ON G.Country = C.Country
	GROUP BY C.Continent, C.Country
)
SELECT Continent, Country, Total_GDP
FROM RankedGDP
WHERE ROW_NUM <= 5
ORDER BY Continent, Total_GDP DESC

--Bottom 5 Countries in each continent base on combined GDP from 2020_2024

WITH RankedGDPBottom AS (
	SELECT C.Continent, C.Country, SUM(G.GDP) AS Total_GDP, ROW_NUMBER() OVER (PARTITION BY C.Continent ORDER BY SUM(G.GDP) ASC) AS ROW_NUM
	FROM PortfolioProjects.dbo.gdp_per_country_2020_2024 G
	JOIN PortfolioProjects.dbo.countries_continents C
	ON G.Country = C.Country
	GROUP BY C.Continent, C.Country
)
	SELECT Continent, Country, Total_GDP
	FROM RankedGDPBottom
	WHERE ROW_NUM <=5
	ORDER BY Continent, Total_GDP ASC

