-- GLOBAL COVID TIMELINE

use SQLPortfolioProject1
go
create view GlobalTimeline as
select date, total_deaths, total_cases, ROUND((total_deaths/total_cases)*100, 2) as death_percentage
from SQLPortfolioProject1..CovidDeaths
where location = 'World'
-- order by date


-- DEATH PERCENTAGES BY LOCATION

use SQLPortfolioProject1
go
create view DeathPercentageByLocation as
select location as Location, MAX(total_cases) as Total_cases, MAX(total_deaths) as Total_deaths, ROUND(AVG((total_deaths/total_cases)*100), 2) AS Death_percentage
from SQLPortfolioProject1..CovidDeaths
where continent <> ''
group by location
-- order by 3 desc


-- DEATH PERCENTAGES OF DIFFERENT INCOME LEVELS

use SQLPortfolioProject1
go
create view DeathPercentageByClass as
select location, MAX(total_cases) as TotalCases, MAX(total_deaths) as TotalDeaths, ROUND(AVG((total_deaths/total_cases)*100), 2) AS DeathPercentage
from SQLPortfolioProject1..CovidDeaths
where location = 'High income' or location = 'Upper middle income' or location = 'Lower middle income' or location = 'Low income'
group by location
-- order by 3 desc


-- GLOBAL DEATH PERCENTAGES

use SQLPortfolioProject1
go
create view DeathPercentageGlobal as
select location, MAX(total_cases) as TotalCases, MAX(total_deaths) as TotalDeaths, ROUND(AVG((total_deaths/total_cases)*100), 2) AS DeathPercentage
from SQLPortfolioProject1..CovidDeaths
where location = 'World'
group by location


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
where dea.continent <> ''
)
select *
from pop_vs_vac