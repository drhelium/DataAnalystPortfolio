Select *
from PortfolioProject..CovidDeaths
order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths 

select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / (CONVERT(float, total_cases)))*100  as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1,2

-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / (CONVERT(float, total_cases)))*100  as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

-- Looking at total cases vs population

select location, date, total_cases, population, (CONVERT(float, total_cases) / (CONVERT(float, population)))*100  as InfectionPercentage
from PortfolioProject..CovidDeaths
where location = 'India'
order by 1,2

--Looking at countries with highest infection rate
select location,  population, max(total_cases) as HighestInfectionCount, Max(CONVERT(float, total_cases) / (CONVERT(float, population)))*100  as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location = 'India'
Group by location,population
order by PercentPopulationInfected desc


-- Looking at countries with highest death count vs population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'India'
where continent is not null
Group by location
order by TotalDeathCount desc


-- Break down by continents

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'India'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing the continents with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'India'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

Select date, sum(cast(new_cases as bigint)) as total_cases, sum(cast(new_deaths as bigint)) as total_deaths, sum(cast(new_deaths as bigint))/sum(cast(new_cases as bigint))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2 


-- Looking at total population vs Vaccinations

Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE to get total people vaccinated vs population

with Popvac (Continent, location, date, population, new_vaccinations, RollingVaccinations) 
as
(
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,  (RollingVaccinations/Population)*100
from Popvac


-- Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(100),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinations numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location =vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingVaccinations/Population)*100
from #PercentPopulationVaccinated