select * from [Portfolio Project]..CovidDeath
where continent is null
order by 3,4

--select * from [Portfolio Project]..[Covid Vaccination]
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeath
order by 1,2


--Looking Total case VS total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeath
Where location = 'Thailand'


--Looking at Total case VS population 

select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from [Portfolio Project]..CovidDeath
where location = 'Thailand'
order by 1,2

--Looking at countries with highest infection rate

select location, Max(total_cases) as highestInfectionCount, population, (Max(total_cases)/population)*100 as InfectedPercentage
from [Portfolio Project]..CovidDeath
group by location, population
order by InfectedPercentage desc

--Looking at countries with highest Death rate

select location, Max(cast(Total_deaths as int)) as highestDeathsCount
from [Portfolio Project]..CovidDeath
where continent is not null
group by location
order by highestDeathsCount desc


--BREAK THINGS DOWN BY CONTINENT 

select location, Max(cast(Total_deaths as int)) as highestDeathsCount
from [Portfolio Project]..CovidDeath
where continent is null
group by location
order by highestDeathsCount desc

-- GLOBAL NUMBERS 

select sum(new_cases) as sum_newCases, sum(cast(new_deaths as int)) as NewDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPer
from [Portfolio Project]..CovidDeath 
where continent is not null 
--group by date 
order by 1,2 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int))
over (partition by dea.location ORDER by dea.location, dea.date) as rollingVaccine
from [Portfolio Project]..CovidDeath dea
join [Portfolio Project]..[Covid Vaccination] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 1,2,3

-- use CTE
With PopVsVac (Continent, Location, Date, Population, New_vaccincations, rollingVaccine) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int))
over (partition by dea.location ORDER by dea.location, dea.date) as rollingVaccine
from [Portfolio Project]..CovidDeath dea
join [Portfolio Project]..[Covid Vaccination] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
)
select * ,
from PopVsVac

-- TEMP TABLE 

Drop table if exists #PercentPoplationVaccinated
Create table #PercentPoplationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
rollingVaccine numeric
)
Insert into #PercentPoplationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int))
over (partition by dea.location ORDER by dea.location, dea.date) as rollingVaccine
from [Portfolio Project]..CovidDeath dea
join [Portfolio Project]..[Covid Vaccination] vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null and vac.new_vaccinations is not null

select * from #PercentPoplationVaccinated


-- Crating view 

create view PercentPoplationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int))
over (partition by dea.location ORDER by dea.location, dea.date) as rollingVaccine
from [Portfolio Project]..CovidDeath dea
join [Portfolio Project]..[Covid Vaccination] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null

select * from PercentPoplationVaccinated
