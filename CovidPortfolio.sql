SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM CovidVaccinations
ORDER BY 3,4

--Select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--Look at the total cases vs total deaths
--Likelihood of someone dying if they contract covid in their country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2  

--Total cases vs population
--Shows what % of the population got Covid
SELECT location, date, population, total_cases, (total_cases/population) * 100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE location like '%States%'
ORDER BY 1,2  

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS Infected
FROM CovidDeaths
GROUP BY location, population
ORDER BY 4 

--Looking at death rate and what country had the highest number of deaths
SELECT location, population, MAX(total_cases) AS Total_Cases, MAX(total_deaths) AS DeathCount, MAX((total_deaths/total_cases)) * 100 AS DeathPercent
FROM CovidDeaths
--WHERE location = 'Austria'
GROUP BY location, population
ORDER BY DeathPercent DESC

--Cast function from another data type cast()
SELECT location, population, MAX(cast(total_deaths as INT)) AS DeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY DeathCount DESC

--Lets break it down by continent
--Showing continents with the highest number of death counts per population
SELECT continent, MAX(cast(total_deaths as INT)) AS DeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY DeathCount DESC

--PART 2
--CREATE VIEW to store data for later visualizations
CREATE VIEW WorldWideDeaths AS
SELECT continent, MAX(cast(total_deaths as INT)) AS DeathCount
FROM CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY continent
--ORDER BY DeathCount DESC

--Viewing the view created
SELECT *
FROM WorldWideDeaths

--Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases) * 100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Global No. Repeated
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(new_cases) * 100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--JOIN, INNER JOIN, LEFT JOIN, RIGHT JOIN, FULL OUTER JOIN
--Looking at the total population vs vaccination-- new vaccinations per day
--What is the total amount of people in the world that have been vaccinated.

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date= vac.date
	WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE
WITH POPvsVAC (Continent , location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date= vac.date
	WHERE dea.continent is not null
--ORDER BY 2,3	
)
SELECT *, (RollingPeopleVaccinated/population) * 100 AS RPC_Percent
FROM POPvsVAC
--END OF CTE

--TEMP table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date= vac.date
	WHERE dea.continent is not null
--ORDER BY 2,3	

SELECT *, (RollingPeopleVaccinated/population) * 100 AS RPC_Percent
FROM #PercentPopulationVaccinated

--END OF TEMP TABLE

SELECT Count(total_deaths) AS Total_Deaths_In_Afghan
FROM CovidDeaths
WHERE location = 'Afghanistan'
