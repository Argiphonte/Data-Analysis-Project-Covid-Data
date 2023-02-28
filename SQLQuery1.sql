SELECT *
FROM CovidPortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM CovidPortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

---- Select Data that we are going to use  

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

---- Looking at Total Cases vs Total Deaths
---- Shows the likelihood of dying after getting Covid-19, per country

SELECT Location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as Death_Ratio
FROM CovidPortfolioProject..CovidDeaths
WHERE location like 'France'
ORDER BY 1,2

---- Looking at Total Cases vs Population

SELECT Location, date, total_cases, population, ((total_cases/population)*100) as Percent_Population_Infected
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location like 'France'
ORDER BY 1,2

---- Which country has had the highest infected ratio?

SELECT Location, population, MAX(total_cases) as Highest_Infection_Count, MAX(((total_cases/population)*100)) as Percent_Population_Infected
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null
--WHERE location like 'France'
GROUP BY Location, Population
ORDER BY Percent_Population_Infected DESC

---- Which country has had the highest death count?

SELECT Location, MAX(CAST(total_deaths as int)) as Total_Deaths_Count 
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY Total_Deaths_Count DESC

---- Which continent has had the highest death count?

SELECT location, MAX(CAST(total_deaths as int)) as Total_Deaths_Count 
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY Total_Deaths_Count DESC

---- Cases and Deaths count across the world

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as death_ratio
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

---- Looking at Total Population vs. Vaccinations

---- Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, total_vaccinations_atm)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as total_vaccinations_atm
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT*, (total_vaccinations_atm/Population)*100 as vaccination_percentage_atm
FROM PopvsVac

---- Temp Table

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
total_vaccinations_atm numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as total_vaccinations_atm
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT*, (total_vaccinations_atm/Population)*100
FROM #PercentPopulationVaccinated

---- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as total_vaccinations_atm
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
