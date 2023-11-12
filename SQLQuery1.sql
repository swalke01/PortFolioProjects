SELECT * 
FROM CovidDeaths
order by 3,4

--SELECT * 
--FROM CovidVaccinations
--order by 3,4

-- Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
order by 1,2


-- We will look at the total case vs total deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths,
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM CovidDeaths
Where location = 'India'
order by 1,2

-- Lets look at the total cases vs population & shows what % of population got covid


SELECT Location, date, total_cases, population,
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0)) * 100 AS Deathpercentage
FROM CovidDeaths
Where location = 'India'
order by 1,2


--Lets look at the countries with highest infection rates compared to population.



Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like = 'India'
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing countries with highest death counts per population & continent wise

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount 
From CovidDeaths
--Where location like = 'India'
WHERE continent is  not null
Group by continent
order by TotalDeathCount DESC


-- global numbers


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location = 'India'
where continent is not null 
--Group By date
order by 1,2



-- LOOKING AT TOTAL POPULATION VS VACCINATIONS



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER BY dea.location , dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100

From CovidDeaths dea
Join CovidVaccinations vac
	 ON dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- USE A CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER BY dea.location , dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100

From CovidDeaths dea
Join CovidVaccinations vac
	 ON dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE



DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER BY dea.location , dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100

From CovidDeaths dea
Join CovidVaccinations vac
	 ON dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating view to store data later for visualation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER BY dea.location , dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100

From CovidDeaths dea
Join CovidVaccinations vac
	 ON dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated
