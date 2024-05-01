-- Looking at columns in the CovidVaccination table --
SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 1,2;

-- Looking at columns in the CovidDeaths table --
SELECT *
FROM PortfolioProject..CovidDeaths 
ORDER BY 3,4;

-- Looking at Total cases vs Total Deaths in United States (It shows the likelihood of dying if you contract in your country) --
SELECT location, date, total_cases, total_deaths, total_deaths/NULLIF(total_cases, 0) *100 DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE location like '%United States%'
ORDER BY 1,2;

-- Looking at Total Cases vs Population (Shows what percentage of population got Covid) --
SELECT location, date, total_cases, population, total_cases/NULLIF(population, 0) *100 AS CovidPercentage 
FROM PortfolioProject..CovidDeaths
WHERE location like '%United States%'
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to location --
SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/NULLIF(population, 0))) *100 AS PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC;

-- Updating the continent column to fill blank spaces with NULL --
UPDATE PortfolioProject..CovidDeaths
SET continent = NULL
WHERE continent = '';

-- Showing countries with the highest death  count
SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;

-- Showing the countries with the highest death rate per population
SELECT location,population, MAX(total_deaths) AS HighestDeathCount, MAX((total_deaths/NULLIF(population, 0))) *100 AS PercentDeathPopulation 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC;

-- Showing the Continent with the highest death
SELECT continent, MAX(total_deaths) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC;

-- Showing Global Numbers --
SELECT continent, SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalNewDeaths, SUM(new_deaths)/ NULLIF(SUM(new_cases),0) *100 AS TotalNewDeathRate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 4 DESC;

-- Total Population vs Vaccinations
SELECT d.continent, d.location,d.date, d.population, v.new_vaccinations
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location
AND D.date = V.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3 DESC;


-- 
WITH PopvsVac (continent, location, Date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT d.continent, 
		d.location,
		d.date, 
		d.population, 
		v.new_vaccinations, 
		SUM(V.new_vaccinations) OVER (Partition by d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location
AND D.date = V.date
WHERE d.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/NULLIF (population,0))*100
FROM PopvsVac



-- TEMP TABLE --
DROP TABLE IF EXISTS #PercentPopulationVaccinated
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
SELECT d.continent, 
		d.location,
		d.date, 
		d.population, 
		v.new_vaccinations, 
		SUM(V.new_vaccinations) OVER (Partition by d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location
AND D.date = V.date
WHERE d.continent IS NOT NULL
SELECT *, (RollingPeopleVaccinated/NULLIF (population,0))*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations --

CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, 
		d.location,
		d.date, 
		d.population, 
		v.new_vaccinations, 
		SUM(V.new_vaccinations) OVER (Partition by d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
ON d.location = v.location
AND D.date = V.date
WHERE d.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated








