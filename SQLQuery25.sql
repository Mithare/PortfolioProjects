select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..Covidvaccinations
--order by 3,4

--Showing deathpercentage in states

select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


--showing what percentage of population got covid in states


select location, date, population, total_cases,  (total_cases/population)*100 as covidpercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


--Highest infected conutries


select location, population, max(total_cases) as highestinfection,  max((total_cases/population))*100 as covidpercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by covidpercentage desc


--highest death count per population


select location, population, max(cast(total_deaths as int)) as highestdeaths,  max((total_deaths/population))*100 as deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location, population
order by highestdeaths desc


--deleting unwanted locations


delete from PortfolioProject..CovidDeaths
where location = 'Upper middle income'


delete from PortfolioProject..CovidDeaths
where location = 'High income'



delete from PortfolioProject..CovidDeaths
where location = 'Lower middle income'


delete from PortfolioProject..CovidDeaths
where location = 'Low income'


--continents with highest death counts

select continent, max(cast(total_deaths as int)) as highestdeaths
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by highestdeaths desc



--global numbers


select date, sum(new_cases) as totalcase, sum(cast(new_deaths as int))as totaldeath, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2



--joining two tables


select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date


--looking into total population vs vaccination


with popVSvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popVSvac



--temp table

drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated


--creating view to store the data for later visualization

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3


--viewing it

select *
from percentpopulationvaccinated