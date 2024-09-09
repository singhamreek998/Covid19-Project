select *
From Portfolio..CovidDeaths$
where continent is not null
order by 3,4


--select *
--From Portfolio..CovidVaccinations$
--order by 3,4

--Select Data we are going to use

select location,date,total_cases, new_cases,total_deaths,population 
from Portfolio..CovidDeaths$
order by 1,2

--looking at total cases vs total deaths
--death percentage 
select location,date,total_cases,total_deaths,(total_deaths/total_cases) *100 as DeathPercentage
from Portfolio..CovidDeaths$
--where location like '%aus%'
where continent is not null
order by 1,2

--looking at total cases vs population
--population which got covid
select location,date,total_cases,population,(total_cases/population) *100 as PopulationInfected
from Portfolio..CovidDeaths$
--where location like '%australia%'
where continent is not null
order by 1,2

--highest infection rate by country vs population
select location,MAX(total_cases) as HighestInfection,MAX(total_cases/population) *100 as PopulationInfected
from Portfolio..CovidDeaths$
--where location like '%aus%'
where continent is not null
group by location,population
order by PopulationInfected desc
 
 --Showing countries with highest death count/population
 select location, MAX(Cast(total_deaths as int)) as TotalDeathCount
 from Portfolio..CovidDeaths$
 --where location '%australia%'
 where continent is null
 Group by location
 order by TotalDeathCount desc


 -- showing continents with highest dath counts
 select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
 from Portfolio..CovidDeaths$
 --where location '%australia%'
 where continent is not null
 Group by continent
 order by TotalDeathCount desc



 --GLOBAL NUMBERS
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast
	(new_deaths as int))/Sum(New_Cases)*100 as DeathPercentage
from Portfolio..CovidDeaths$
--where location like '%aus%'
where continent is not null
--group by date
order by 1,2

--looking at toal population vs Vaccinations

Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, 
 dea.date) as RollingPeopleVacc
 --, (RollingPeopleVacc/population) *100
from Portfolio..CovidDeaths$ dea
join Portfolio..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3


--USE CTE
with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVacc)
as 
(
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, 
 dea.date) as RollingPeopleVacc
 --, (RollingPeopleVacc/population) *100
from Portfolio..CovidDeaths$ dea
join Portfolio..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (RollingPeopleVacc/Population) *100
from PopvsVac

--temp table
Drop table if exists #PERCENTPOPVACC
Create Table #PERCENTPOPVACC
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVacc numeric
)
Insert into #PERCENTPOPVACC 
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, 
 dea.date) as RollingPeopleVacc
 --, (RollingPeopleVacc/population) *100
from Portfolio..CovidDeaths$ dea
join Portfolio..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
--order by 2,3

Select*, (RollingPeopleVacc/Population) *100
from #PERCENTPOPVACC

--creating views
Create View PercentPopulationVacc as
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location, 
 dea.date) as RollingPeopleVacc
 --, (RollingPeopleVacc/population) *100
from Portfolio..CovidDeaths$ dea
join Portfolio..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVacc

