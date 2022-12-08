select * from PortfolioProject001..covid_deaths
order by 3,4
--looking at the data available

select * from PortfolioProject001..covid_vac
order by 3,4

-- data
--looking at total cases vs deaths in INDIA
-- shows likelihood of dieing with covid



select location , date , total_cases , total_deaths ,(total_deaths /total_cases)*100 as Deathpercentage
from PortfolioProject001..covid_deaths
where location like '%india%'
order by 1,2


--- looking at Total cases vs population


select location  , total_cases , population ,(total_cases/population)*100 as pop_ifec
from PortfolioProject001..covid_deaths
where location like '%india%'
order by 1,2


--- looking at  countries with highest infection compared to population

select location  , max(total_cases ) as highestInfectionCount, population ,Max(total_cases/population)*100 as pop_infec
from PortfolioProject001..covid_deaths
group by location , population
order by pop_infec desc

-- looking for countiries with highest death count against their population


select location  , max(cast(total_deaths as int)) as toataldeathCount --,population ,Max(total_deaths/population)*100 as pop_died
from PortfolioProject001..covid_deaths
where continent is not null
group by location --, population
order by toataldeathCount desc

---filter by continents

select location , max(cast(total_deaths as int)) as toataldeathCount --,population ,Max(total_deaths/population)*100 as pop_died
from PortfolioProject001..covid_deaths
where continent is  null
group by location--, population
order by toataldeathCount desc 

-- GLOABL NUMBERS


select sum(new_cases)  as totalCases, sum(cast(new_deaths as int)) as totalDeaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as death_per
from PortfolioProject001..covid_deaths  
where continent is not null
--group by date
order by 1 ,2

-- join vaccination table with deaths table
select *
from PortfolioProject001..covid_deaths as dea
join PortfolioProject001..covid_vac as vac
on dea.location = vac.location and dea.date = vac.date

-- Looking for toatal population vs Vaccinations

select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations , sum( cast (vac.new_vaccinations as int) ) over (partition by dea.location order by dea.location, dea.date) as rollingCount
from PortfolioProject001..covid_deaths as dea
join PortfolioProject001..covid_vac as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- CTE

with popvsvac ( continent , location , date , population , new_vaccinations , rollingCount) 

as
(
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations , sum( cast (vac.new_vaccinations as int) ) over (partition by dea.location order by dea.location, dea.date) as rollingCount
from PortfolioProject001..covid_deaths as dea
join PortfolioProject001..covid_vac as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select * ,( rollingCount/population ) * 100 as per_vac
from popvsvac
order by 2,3


--TEMP TABLE
DROP TABLE IF EXISTS #PERCENTPOPULATIONVACCINATED

CREATE TABLE #PERCENTPOPULATIONVACCINATED
(
CONTINENT NVARCHAR(255),
LOCATION NVARCHAR(255),
DATE DATETIME,
POPULATION NUMERIC,
NEW_VACCINATON NUMERIC,
rollingCount  NUMERIC 
)

INSERT INTO #PERCENTPOPULATIONVACCINATED
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations , sum( cast (vac.new_vaccinations as int) ) over (partition by dea.location order by dea.location, dea.date) as rollingCount
from PortfolioProject001..covid_deaths as dea
join PortfolioProject001..covid_vac as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * ,( rollingCount/population ) * 100 as per_vac
from #PERCENTPOPULATIONVACCINATED


 CREATE VIEW Percentpopulationvaccinated as 
 
select dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations , sum( cast (vac.new_vaccinations as int) ) over (partition by dea.location order by dea.location, dea.date) as rollingCount
from PortfolioProject001..covid_deaths as dea
join PortfolioProject001..covid_vac as vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3


















