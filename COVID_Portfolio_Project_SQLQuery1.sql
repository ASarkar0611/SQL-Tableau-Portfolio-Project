-- CovidDeaths

select * from PortfolioProject..CovidDeaths
order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
order by location, date;

-- Total Cases vs Total Deaths
-- Since columns had integer data types one of the columns had to be cast as decimal. Without it, the part after the decimal was truncated
-- and result was coming as 0
-- Shows likelihood of you to die if you get covid

select location, date, total_cases, total_deaths, ((total_deaths/cast(total_cases as decimal))*100) as deathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
and continent is not null
order by location, date;

-- Total Cases vs Population

select location, date, total_cases, population, ((cast(total_cases as decimal)/population)*100) as casePercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
and continent is not null
order by location, date;

-- Countries with highest infection rate compared to population

select location, /*max(date) as RecentDate,*/ population, max(total_cases) as HighestInfectionCount, max(((cast(total_cases as decimal)/population)*100)) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- where location like '%india%'
where continent is not null
group by location, population
order by /*RecentDate,*/ PercentPopulationInfected desc;

-- Countries with highest death rate compared to population

select location, /*max(date) as RecentDate,*/ population, max(total_deaths) as HighestDeathCount, max(((cast(total_deaths as decimal)/population)*100)) as PercentPopulationDeath
from PortfolioProject..CovidDeaths
-- where location like '%india%'
where continent is not null
group by location, population
order by /*RecentDate,*/ PercentPopulationDeath desc;

-- Countries with highest death count compared to population

select location, /*max(date) as RecentDate, population,*/ max(total_deaths) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location--, population
order by /*RecentDate,*/ HighestDeathCount desc;

-- With respect to CONTINENT

-- Continents with highest death count

select location, /*max(date) as RecentDate, population,*/ max(total_deaths) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location--, population
order by /*RecentDate,*/ HighestDeathCount desc;

-- GLOBAL NUMBERS

select /*date,*/ sum(new_cases) as TotalNewCases, sum(new_deaths) as TotalNewDeaths, 
(CAST(sum(new_deaths) as decimal)/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
having sum(new_cases) > 0 or SUM(new_cases) is null
order by 1, 2;

-- CovidVaccinations

select * from PortfolioProject..CovidVaccinations
order by 3,4;

-- Join the two tables

-- Total Population vs Vaccinations

select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(cast(CV.new_vaccinations as int)) over (partition by CD.location order by CD.location, CD.date) as RollingCountofPeopleVaccinated
from PortfolioProject..CovidDeaths CD
join PortfolioProject..CovidVaccinations CV on CD.location = CV.location and CD.date = CV.date
where CD.continent is not null
order by 2, 3;

-- Using CTE

with PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingCountofPeopleVaccinated)
as (select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(cast(CV.new_vaccinations as int)) over (partition by CD.location order by CD.location, CD.date) as RollingCountofPeopleVaccinated
from PortfolioProject..CovidDeaths CD
join PortfolioProject..CovidVaccinations CV on CD.location = CV.location and CD.date = CV.date
where CD.continent is not null
)
select *, (RollingCountofPeopleVaccinated/Population)*100 as VaccinationPercentage
from PopvsVac
--order by 2, 3

-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingCountofPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(cast(CV.new_vaccinations as float)) over (partition by CD.location order by CD.location, CD.date) as RollingCountofPeopleVaccinated
from PortfolioProject..CovidDeaths CD
join PortfolioProject..CovidVaccinations CV on CD.location = CV.location and CD.date = CV.date
--where CD.continent is not null

select *, (RollingCountofPeopleVaccinated/Population)*100 as VaccinationPercentage
from #PercentPopulationVaccinated

-- Create a view as output

Create View PercentPopulationVaccinated as
select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(cast(CV.new_vaccinations as float)) over (partition by CD.location order by CD.location, CD.date) as RollingCountofPeopleVaccinated
from PortfolioProject..CovidDeaths CD
join PortfolioProject..CovidVaccinations CV on CD.location = CV.location and CD.date = CV.date
where CD.continent is not null
--order by 2, 3

select * from PercentPopulationVaccinated;