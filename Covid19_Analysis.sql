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
-- sort from highest Cases/Population to lowest
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



-- looking at countries with highest Infection Rate compare to Population
SELECT
	location, population, MAX(total_cases) as HighestInfectionRate, 
	MAX((total_cases/population)*100) as InfectionRate
FROM
	PortfolioProject..CovidDeaths
GROUP BY
	location, population
ORDER BY
	InfectionRate desc



-- Total Cases vs Population in Germany
-- show percentage of population contracted covid
SELECT location, CAST(date as DATE) as date, population, total_cases, (total_cases/population)*100 as cases_per_population
FROM PortfolioProject..CovidDeaths
WHERE location like '%Germany%'
ORDER BY 2



-- get the total cases from every country
-- every 1st day of the month
SELECT location, CAST(date AS DATE) AS date, total_cases
FROM PortfolioProject..CovidDeaths
WHERE DAY(date) = '01' AND continent <> 'NULL'
ORDER BY 1,2



-- show countries with highest Death Count
SELECT
	location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent is not null
GROUP BY
	location
ORDER BY
	TotalDeathCount desc



-- show Death Count by Continent
-- get wrong values
SELECT
	continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent is not null
GROUP BY
	continent
ORDER BY
	TotalDeathCount desc



-- show Death Count by Continent 2nd
-- correct values
SELECT
	location as Continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent is null
	AND
	(location = 'Europe' OR location = 'North America' OR location = 'South America' OR
	location = 'Asia' OR location = 'Oceania' OR location = 'Africa')
GROUP BY
	location
ORDER BY
	TotalDeathCount desc



-- Global numbers
SELECT 
	CAST(date as DATE) as date, total_cases, total_deaths
FROM
	PortfolioProject..CovidDeaths
WHERE location = 'World'
ORDER BY 1



-- Global numbers
SELECT 
	CAST(date as DATE) as Date, 
	SUM(new_cases) as TotalCases,
	SUM(CAST(new_deaths as int)) as TotalDeaths,
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Date
ORDER BY 1,2



-- Total Population vs Vaccinations
SELECT
	dea.continent, dea.location, dea.date, dea.population,
	vac.new_vaccinations, 
	SUM(CONVERT(bigint, vac.new_vaccinations)) 
		OVER (Partition by dea.location ORDER BY dea.location, dea.date)
		AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3



-- use CTE (Common Table Expression) : temporary named result set
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT
	dea.continent, dea.location, dea.date, dea.population,
	vac.new_vaccinations, 
	SUM(CONVERT(bigint, vac.new_vaccinations)) 
		OVER (Partition by dea.location ORDER BY dea.location, dea.date)
		AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinationPerPopulation
FROM PopVsVac
WHERE Location like 'malaysia'



-- temp table
DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT into #PercentPopulationVaccinated
SELECT
	dea.continent, dea.location, dea.date, dea.population,
	vac.new_vaccinations, 
	SUM(CONVERT(bigint, vac.new_vaccinations)) 
		OVER (Partition by dea.location ORDER BY dea.location, dea.date)
		AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 as VaccinationPerPopulation
FROM #PercentPopulationVaccinated
WHERE Location like 'malaysia'



-- creating VIEW to store data for later visualizations
Create View PercentPopulationVaccinated as
SELECT
	dea.continent, dea.location, dea.date, dea.population,
	vac.new_vaccinations, 
	SUM(CONVERT(bigint, vac.new_vaccinations)) 
		OVER (Partition by dea.location ORDER BY dea.location, dea.date)
		AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3



-- query from VIEW
SELECT *
FROM PercentPopulationVaccinated