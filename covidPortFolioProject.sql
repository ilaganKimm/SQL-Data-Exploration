

USE PortfolioProject

SELECT DB_NAME()

SELECT *
FROM PortfolioProject..CovidDeaths

SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


-- data that will be use

SELECT Location, date, total_cases, new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
order by 1,2


--total cases vs total deaths

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as deathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%philippines%'
and continent is not null
order by 1,2


-- total cases vs population
--percentage of population infected by covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
where location like '%philippines%'
and continent is not null
order by 1,2



-- countries with highest infection rate compared to their population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by InfectedPopulationPercentage desc




-- Global total Covid-19 cases, total deaths, and death rate

SELECT SUM(new_cases) as totalCases, SUM(cast(New_deaths as int)) as totalDeaths,
SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2



-- Total death count per continent

SELECT Location, SUM(cast(new_deaths as int))  as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is null
and location not in ('world','European Union','International','High income',
'Upper middle income','Lower middle income','Low income')
group by location
order by TotalDeathCount desc



-- countries with highest deathcount per population

SELECT Location, MAX(cast(total_deaths as int))  as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc



-- infected population percentage per country

SELECT Location, population, MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
group by location, population
order by InfectedPopulationPercentage desc


-- Infected population percentage

SELECT Location, population, date, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 as InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
group by location, population, date
order by InfectedPopulationPercentage desc



SELECT *
FROM PortfolioProject..CovidVaccinations


-- total number of vaccinated worlwide

SELECT dead.continent, dead.location, dead.date, dead.population, vacc.new_vaccinations,
SUM(cast (vacc.new_vaccinations as bigint)) over (Partition by dead.location 
order by dead.location, dead.date) as AddingUpPeopleVaccinated
 --(AddingUpPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dead
Join PortfolioProject..CovidVaccinations vacc
	on dead.location = vacc.location
	and dead.date = vacc.date
where dead.continent is not null
order by 2,3


-- CTE

With PopvsVac (continent, location, date, population, new_vaccinations, AddingUpPeopleVaccinated)
as
(SELECT dead.continent, dead.location, dead.date, dead.population, vacc.new_vaccinations,
SUM(cast (vacc.new_vaccinations as bigint)) over (Partition by dead.location 
order by dead.location, dead.date) as AddingUpPeopleVaccinated
FROM PortfolioProject..CovidDeaths dead
Join PortfolioProject..CovidVaccinations vacc
	on dead.location = vacc.location
	and dead.date = vacc.date
where dead.continent is not null
--order by 2,3
)
select * , (AddingUpPeopleVaccinated/population)*100
FROM PopvsVac



-- temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
AddingUpPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
SELECT dead.continent, dead.location, dead.date, dead.population, vacc.new_vaccinations,
 SUM(cast (vacc.new_vaccinations as bigint)) over (Partition by dead.location 
 order by dead.location, dead.date) as AddingUpPeopleVaccinated
FROM PortfolioProject..CovidDeaths dead
Join PortfolioProject..CovidVaccinations vacc
	on dead.location = vacc.location
	and dead.date = vacc.date
where dead.continent is not null
--order by 2,3
select * , (AddingUpPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



-- creating a view to store data for visualization

create view PercentPopulationVaccinated as
SELECT dead.continent, dead.location, dead.date, dead.population, vacc.new_vaccinations,
 SUM(cast (vacc.new_vaccinations as bigint)) over (Partition by dead.location 
 order by dead.location, dead.date) as AddingUpPeopleVaccinated
FROM PortfolioProject..CovidDeaths dead
Join PortfolioProject..CovidVaccinations vacc
	on dead.location = vacc.location
	and dead.date = vacc.date
where dead.continent is not null



Select * 
from PercentPopulationVaccinated
