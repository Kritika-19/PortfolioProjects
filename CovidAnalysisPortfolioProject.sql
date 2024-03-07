Select * 
From PortfolioProject..covid_deaths
where continent is not null
order by 3,4

Select * 
From PortfolioProject..covid_vaccination
order by 3,4

Select Location, Date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covid_deaths
order by 1,2

-- Total cases vs Total deaths
-- Shows likelihood of dying if you contrct covid in your country

Select Location, Date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..covid_deaths
Where location like 'India'
order by 1,2


-- Tatal cases vs Population
-- Shows what percentage of population got covid

Select Location, Date,  population, total_cases, (cast(total_deaths as float)/cast(population as float))*100 as PercentPopulationInfected
From PortfolioProject..covid_deaths
Where location like 'India'
order by 1,2


--Country having highest infection rate compared to Population

Select Location,  population, max(total_cases) as HighestInfectionCount, MAX(cast(total_deaths as float)/cast(population as float))*100 as PercentPopulationInfected
From PortfolioProject..covid_deaths
Group by location, population
order by 1,2

-- in descending order
Select Location,  population, max(total_cases) as HighestInfectionCount, MAX(cast(total_deaths as float)/cast(population as float))*100 as PercentPopulationInfected
From PortfolioProject..covid_deaths
Group by location, population
order by PercentPopulationInfected desc


--Countries with the Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..covid_deaths
where continent is not null
Group by location
order by TotalDeathCount desc

--Break things down by Continent

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..covid_deaths
where continent is null
Group by location
order by TotalDeathCount desc


-- Showing the continents with highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..covid_deaths
where continent is null
Group by continent
order by TotalDeathCount desc


--Global Numbers

Select SUM(new_cases) as totalcases ,SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..covid_deaths
--Where location like 'India'
where continent is not null
--group by date
order by 1,2


-- Total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..covid_deaths as dea
JOIN PortfolioProject..covid_vaccination as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, date,Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..covid_deaths as dea
JOIN PortfolioProject..covid_vaccination as vac
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
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..covid_deaths as dea
JOIN PortfolioProject..covid_vaccination as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as RES
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinatedd as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..covid_deaths as dea
JOIN PortfolioProject..covid_vaccination as vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated