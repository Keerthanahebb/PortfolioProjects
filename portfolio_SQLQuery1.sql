select * from PortfolioProject.dbo.covid19deaths$
--where continent is not null
order by 3,4;

--select * from PortfolioProject.dbo.covidvaccinations$
--order by 3,4;

-- select data that we are going to be using
select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject.dbo.covid19deaths$
where continent is not null
order by 1,2;


--looking at the total cases vs total deaths
--shows likelihood of dying if you contact covid in your country
select location,date,total_cases,total_deaths,CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)*100 as DeathPercentage 
from PortfolioProject.dbo.covid19deaths$
where location like '%states%' and continent is not null
order by 1,2;

select continent,location,max(CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT))*100 as DeathPercentage 
from PortfolioProject.dbo.covid19deaths$
where location like '%asia%'
group by continent,location
--order by DeathPercentage
order by 1,2;

--looking at the Total cases vs population
--shows what % of population got covid
select location,date,total_cases,population,CAST(total_deaths AS FLOAT) / CAST(population AS FLOAT)*100 as DeathPercentage 
from PortfolioProject.dbo.covid19deaths$
--where location like '%states%'
order by 1,2;


--looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as highestinfectioncount,max(cast(total_cases as float)/cast(population as float))*100 as highestpopulationinfection
from PortfolioProject.dbo.covid19deaths$
--where location like '%states%'
group by location,population
--order by 1,2
order by highestpopulationinfection desc


select location,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject.dbo.covid19deaths$
--where location like '%states%'
where continent is null
group by location
order by totaldeathcount desc

--LET'S BREAK THINKS DOWN BY CONTINENT
--showing highest death count per poppulation

select continent,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject.dbo.covid19deaths$
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc

--GLOBAL NUMBERS(across the world)
select date,SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths,SUM(CAST(new_deaths AS float)) /sum( CAST(new_cases AS float))*100 as DeathPercentage 
from PortfolioProject.dbo.covid19deaths$
--where location like '%states%'
where continent is not null
group by date
order by 1,2;

select SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths,SUM(CAST(new_deaths AS float)) /sum( CAST(new_cases AS float))*100 as DeathPercentage 
from PortfolioProject.dbo.covid19deaths$
where continent is not null
--group by date
order by 1,2;


--looking at total population vs vaccinations
--USE CTE,
with PopvsVac(Continent,Location,Date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.covid19deaths$ dea
join PortfolioProject.dbo.covidvaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--(doesn't work)(new_vass=sum(new_vacc)group by dea.continent,dea.location,dea.population,vac.new_vaccinations
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)
from PopvsVac


--Temp Table
drop table if exists #percentagepopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.covid19deaths$ dea
join PortfolioProject.dbo.covidvaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--(doesn't work)(new_vass=sum(new_vacc)group by dea.continent,dea.location,dea.population,vac.new_vaccinations
--order by 2,3

select *,(RollingPeopleVaccinated/population)
from #PercentPopulationVaccinated


create view PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.covid19deaths$ dea
join PortfolioProject.dbo.covidvaccinations$ vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--(doesn't work)(new_vass=sum(new_vacc)group by dea.continent,dea.location,dea.population,vac.new_vaccinations
--order by 2,3


select * from PercentPopulationVaccinated