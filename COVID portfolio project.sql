Select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

/*
Select *
from PortfolioProject..CovidVaccinations
where continent is not null
order by 3,4
*/

--select the data that we are going to be using
Select Location, date, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at the Total Cases vs Total Death
-- likelyhood of dying of covid if you catch it in the US
Select Location, date,total_cases , total_deaths,  (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%Iran%' and continent is not null
order by 1,2

-- looking at Total Cases vs Population
-- shows what percentage of population got covid
Select Location, date,total_cases , population,  (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%Iran%' and continent is not null
order by 1,2

-- looking at countries with highest infection rate compared to population
Select Location, population,  MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 
as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%Iran%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--showing the countries the highest deth count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%Iran%'
where continent is not null
group by location
order by TotalDeathCount desc

-- showing the continents with the highest death counts
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%Iran%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- global numbers 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
-- where location like '%Iran%' 
where continent is not null
--group by date
order by 1,2

-- joining the two tables
-- then looking at total population vs vaccination

-- using CTE
with PopvsVac (Continent ,Location ,Date ,Population ,New_Vaccinations ,RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.Location order by dea.Location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join  PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location 
	  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac

-- TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE table #PercentPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.Location order by dea.Location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join  PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location 
	  and dea.date = vac.date
--where dea.continent is not null

select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.Location order by dea.Location, 
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join  PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location 
	  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
