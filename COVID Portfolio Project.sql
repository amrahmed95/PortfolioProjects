/*
	SQL Data Exploration
*/

SELECT * 
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4


SELECT * 
FROM CovidVaccinations
ORDER BY 3,4

-- Select Data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
order by 1,2


-- Looking at Total Cases Vs. Total Deaths 
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, 
		(CONVERT(float, total_deaths) / NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%states%' AND continent is not null
ORDER BY 1,2
--ORDER BY DeathPercentage DESC


-- Looking at Total Cases Vs. Population
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, 
		((NULLIF(CONVERT(float,total_cases),0)) / population)*100 AS TotalCases_percentage
FROM CovidDeaths
WHERE location LIKE '%states%' AND continent is not null
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to Population

SELECT Location, population, MAX(total_cases) AS 'Highest Infection Count',
	MAX(((NULLIF(CONVERT(float,total_cases),0)) / population)*100) AS Percentage_Population_Infected
FROM CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location,population
ORDER BY Percentage_Population_Infected DESC


-- Showing Countries with Highest Death Count Per Population 

SELECT Location, Population, MAX(CAST(total_deaths AS int)) AS 'Total Deaths Count'
FROM CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY location, population 
ORDER BY [Total Deaths Count] DESC


-- Breaking Things down by continent

SELECT continent, MAX(CAST(total_deaths AS int)) AS 'Total Deaths Count'
FROM CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY continent 
ORDER BY [Total Deaths Count] DESC


-- Showing the Continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS 'Total Deaths Count'
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY [Total Deaths Count] DESC


SELECT continent,location
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent,location
ORDER BY continent



-- Global Numbers

SELECT date,
		SUM(new_cases) AS total_cases, 
		SUM(CAST(new_deaths AS int)) AS total_deaths,
		NULLIF( ((SUM(CAST(new_deaths AS int))/SUM(new_cases))*100)  ,0) AS 'Death Percentage'
FROM CovidDeaths
--WHERE location LIKE '%states%' 
where continent is not null
GROUP BY date
ORDER BY 1,2


----------------------------------------------------------------------------------------------------------------

-- Looking at Total Population Vs. Vaccinations

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
		SUM(CAST(cv.new_vaccinations AS float)) 
		OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
ORDER BY 1,2,3


-- USE CTE

WITH PopVSVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS float)) 
	OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
--ORDER BY 1,2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVSVac



-- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	Date datetime,
	Population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS float)) 
	OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
--ORDER BY 1,2,3


SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated 
AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations AS float)) 
	OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths cd
JOIN CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
--ORDER BY 1,2,3

SELECT * FROM PercentPopulationVaccinated







