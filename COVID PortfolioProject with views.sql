SELECT *
FROM PortfolioProject..CovidDeaths
Order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select Data that we are going to be using 

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood od dying if you contract COVID in your country

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location ='Brazil' 
Order by 1,2


--Total Cases vs Population
--Shows what percentage of population infected with Covid

SELECT Location, Date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location ='Brazil'
Order by 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
Order by PercentPopulationInfected desc



-- Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
Order by TotalDeathCount desc



-- Breaking it Down by Continent 

-- Showing Contintents with the Highest Heath Count per Population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
Order by TotalDeathCount desc



-- Global Numbers

-- By date
SELECT Date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP by date
Order by 1,2


-- TOTAL
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent,Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, ( RollingPeopleVaccinated/Population)*100 as  PercentagePopulationVaccinated
FROM PopvsVac



-- Using a Temporary Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null


SELECT *, ( RollingPeopleVaccinated/Population)*100 as  PercentagePopulationVaccinated
FROM #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated


Create view DeathPercentage as
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location ='Brazil' 
--Order by 1,2


Create view PercentPopulationInfectedBR as
SELECT Location, Date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location ='Brazil'

Create view CountriesHighestInfectionRate as
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
--Order by PercentPopulationInfected desc


Create view TotalDeathbyCountry as
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
--Order by TotalDeathCount desc


Create view TotalDeathbyContinent as
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
--Order by TotalDeathCount desc

Create view ContinentDeathPercentagebyDate as
SELECT Date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP by date
--Order by 1,2

