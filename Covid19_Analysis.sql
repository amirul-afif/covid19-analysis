-- show all data from CovidVaccinations table 
-- sort by location (ASC) and date (DESC)
SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4 desc

-- show all data from CovidDeaths table 
-- sort by location (ASC) and date (DESC)
SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4 desc

-- total_cases vs total_deaths
-- calculate death_percentage
SELECT
	DISTINCT location, date, population, total_cases, total_deaths,
	(total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths 
ORDER BY 6, 1

-- show latest date for each location/country
-- (not all country have data from current latest date 2022-01-08)
SELECT location, MAX(date) as max_date
FROM PortfolioProject..CovidDeaths
WHERE continent <> 'NULL'
GROUP BY location
ORDER BY location

-- show latest data from each location
-- use inner join to combine with queried table above
-- where latest date for each location not all the same
SELECT
	ori.location, 
	CAST(ori.date AS DATE) AS date, 
	population, total_cases, total_deaths,
	(total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths ori
INNER JOIN
	(SELECT location, MAX(date) AS max_date
	FROM PortfolioProject..CovidDeaths
	WHERE continent <> 'NULL'
	GROUP BY location) grouped
ON 
	ori.location = grouped.location
	AND
	ori.date = grouped.max_date
ORDER BY 6 DESC

-- Total Cases vs Population
SELECT
	ori.location, date, total_cases, population, 
	(total_cases/population)*100 AS cases_per_population
FROM PortfolioProject..CovidDeaths ori
INNER JOIN
	(SELECT location, MAX(date) AS max_date
	FROM PortfolioProject..CovidDeaths
	WHERE continent <> 'NULL'
	GROUP BY location) grouped
ON 
	ori.location = grouped.location
	AND
	ori.date = grouped.max_date
ORDER BY 5 DESC
	
	


