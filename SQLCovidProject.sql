/*

Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views

*/

--SELECT *
--FROM SQLPortfolioProject1..CovidDeaths
--ORDER BY 1,2

--SELECT *
--FROM SQLPortfolioProject1..CovidVaccinations
--ORDER BY 3,4


-- WORLD'S COVID TIMELINE

select date, total_deaths, total_cases, ROUND((total_deaths/total_cases)*100, 2) as death_percentage
from SQLPortfolioProject1..CovidDeaths
where location = 'World'
order by 1


-- HIGHEST DEATH PERCENTAGES BY LOCATION

select location as Location, SUM(population) as Population, SUM(total_cases) as Total_cases, SUM(total_deaths) as Total_deaths, ROUND(AVG((total_deaths/population)*100), 2) AS Death_percentage
from SQLPortfolioProject1..CovidDeaths
where continent <> ''
group by location
order by death_percentage desc


-- DEATH PERCENTAGES OF DIFFERENT INCOME LEVELS

select location, population, SUM(total_deaths) as TotalDeaths, ROUND(AVG((total_deaths/population)*100), 2) AS DeathPercentage
from SQLPortfolioProject1..CovidDeaths
where location = 'High income' or location = 'Upper middle income' or location = 'Lower middle income' or location = 'Low income'
group by location, population
order by TotalDeaths desc


-- GLOBAL DEATH PERCENTAGES

select location, population, SUM(total_deaths) as TotalDeaths, ROUND(AVG((total_deaths/population)*100), 2) AS DeathPercentage
from SQLPortfolioProject1..CovidDeaths
where location = 'World'
group by location, population
order by TotalDeaths desc


-- ROLLING TOTAL VACCINATIONS AND PERCENTAGE BY CTE

with pop_vs_vac (continent, location, date, population, new_vaccinations, total_vaccinations, vaccination_percentage)
as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as total_vaccinations
, (total_vaccinations/population)*100 as vaccination_percentage
from SQLPortfolioProject1..CovidDeaths as dea
JOIN SQLPortfolioProject1..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.location <> 'World'
)
select *
from pop_vs_vac



-- ROLLING TOTAL VACCINATIONS AND PERCENTAGE BY TABLE

drop table if exists #PercentVaccinated
create table #PercentVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccinations numeric,
TotalVaccinations numeric,
VaccinatedPercentage numeric
)

insert into #PercentVaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as total_vaccinations
, (total_vaccinations/population)*100 as vaccination_percentage
from SQLPortfolioProject1..CovidDeaths as dea
JOIN SQLPortfolioProject1..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.location <> 'World'
select *
from #PercentVaccinated



-- CREATE VIEWS



-- GLOBAL COVID TIMELINE

use SQLPortfolioProject1
go
create view GlobalTimeline as
select date, total_deaths, total_cases, ROUND((total_deaths/total_cases)*100, 2) as death_percentage
from SQLPortfolioProject1..CovidDeaths
where location = 'World'


-- HIGHEST DEATH PERCENTAGES BY LOCATION

use SQLPortfolioProject1
go
create view DeathPercentageByLocation as
select location as Location, SUM(population) as Population, SUM(total_cases) as Total_cases, SUM(total_deaths) as Total_deaths, ROUND(AVG((total_deaths/population)*100), 2) AS Death_percentage
from SQLPortfolioProject1..CovidDeaths
where continent <> ''
group by location


-- DEATH PERCENTAGES OF DIFFERENT INCOME LEVELS

use SQLPortfolioProject1
go
create view DeathPercentageByClass as
select location, population, SUM(total_deaths) as TotalDeaths, ROUND(AVG((total_deaths/population)*100), 2) AS DeathPercentage
from SQLPortfolioProject1..CovidDeaths
where location = 'High income' or location = 'Upper middle income' or location = 'Lower middle income' or location = 'Low income'
group by location, population


-- GLOBAL DEATH PERCENTAGES

use SQLPortfolioProject1
go
create view DeathPercentageGlobal as
select location, population, SUM(total_deaths) as TotalDeaths, ROUND(AVG((total_deaths/population)*100), 2) AS DeathPercentage
from SQLPortfolioProject1..CovidDeaths
where location = 'World'
group by location, population


-- GLOBAL COVID TIMELINE WITH VACCINATIONS

use SQLPortfolioProject1
go
create view GlobalTimelineWithVaccinations as
select dea.date, dea.total_deaths, dea.total_cases, ROUND((dea.total_deaths/dea.total_cases)*100, 2) as death_percentage
, vac.new_vaccinations, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as total_vaccinations
from SQLPortfolioProject1..CovidDeaths dea
JOIN SQLPortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.location = 'World'


-- TOTAL VACCINATED BY LOCATION

use SQLPortfolioProject1
go
create view TotalVaccinationsByLocation as
with pop_vs_vac (continent, location, date, population, new_vaccinations, total_vaccinations)
as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as total_vaccinations
from SQLPortfolioProject1..CovidDeaths as dea
JOIN SQLPortfolioProject1..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.location <> 'World'
)
select *
from pop_vs_vac