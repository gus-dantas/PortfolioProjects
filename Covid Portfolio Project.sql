Select *
From PortfolioProject..Covid_Deaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..Covid_Vaccination
--order by 3,4

--Select the data that we want to be using
Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..Covid_Deaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you get Covid in Australia
Select location, date, total_cases, population, total_deaths, (total_cases/population)*100 as DeathPercentage
from PortfolioProject..Covid_Deaths
Where location like '%Australia%' and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows the percentage of the population who got Covid
Select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from PortfolioProject..Covid_Deaths
Where location like '%Australia%' AND continent is not null
order by 1,2

-- Looking at Countries with the highest infection rate
Select location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..Covid_Deaths
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

-- Looking at Countries with the highest death per population
Select location, population, MAX(total_deaths) as HighestDeathCount, Max(total_deaths/population)*100 as PercentPopulationDead
from PortfolioProject..Covid_Deaths
where continent is not null
Group by location, population
order by PercentPopulationDead desc

-- Looking at Countries with the highest absolute deaths
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..Covid_Deaths
where continent is not null
Group by location
order by TotalDeathCount desc

--Breaking it down by continent
-- Looking at Countries with the highest absolute deaths
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..Covid_Deaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers
Select sum(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, 100*SUM(cast(new_deaths as int))/SUM(new_cases)	as DeathPercentage--, total_cases, total_deaths, (total_cases/total_cases)*100 as DeathPercentage
from PortfolioProject..Covid_Deaths
where continent is not null
Group by date--, total_cases, total_deaths
order by 1,2

-- VACCINATION IN THE WORLD

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..Covid_Deaths as dea
join PortfolioProject..Covid_Vaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE to know the % of vaccinated people

With PopVsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..Covid_Deaths as dea
join PortfolioProject..Covid_Vaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
Select *, 100*(RollingPeopleVaccinated/Population) as PercentaceOfVaccination
from PopVsVac

-- Use TEMP Tableto know the % of vaccinated people

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))
over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..Covid_Deaths as dea
join PortfolioProject..Covid_Vaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *, 100*(RollingPeopleVaccinated/Population) as PercentaceOfVaccination
From #PercentPopulationVaccinated


--Creating view to store data for later visualisations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int))
over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..Covid_Deaths as dea
join PortfolioProject..Covid_Vaccination as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select *
from PercentPopulationVaccinated

