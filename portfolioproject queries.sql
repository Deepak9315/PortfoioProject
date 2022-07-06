select * from [dbo].[covid deaths1]
order by 3,4

--select * from [dbo].[covid vaccination]
--order by 3,4

--select data that we are going to use

select location ,date ,total_cases,new_cases,total_deaths,population 
from [dbo].[covid deaths1]
order by 1,2

--looking at total cases vs total deaths


select location ,date ,total_cases,total_deaths,(total_cases/total_deaths)*100 as deathspercentages
from [dbo].[covid deaths1]
order by 1,2


select location ,date ,total_cases,total_deaths,(total_cases/total_deaths)*100 as deathspercentages
from [dbo].[covid deaths1]
where location like '%india%'
order by 1,2

--looking at the total cases vs population
--what percentage of population got covid

select location ,date ,total_cases,population,(population/total_cases)*100 as populationpercentages
from [dbo].[covid deaths1]
where location like '%india%'
order by 1,2


--looking at countries with highest infection rate compared to population


select location ,population ,MAX(total_cases) as highestinfectioncount ,MAX((total_cases/population))*100 as deathspercentages
from [dbo].[covid deaths1]
--where location like '%india%'
group by population,location
order by 1,2

--showing Countries with highest Death count per population
select location ,Max (cast(Total_deaths as int)) as TotalDeathCount
from [dbo].[covid deaths1]
--where location like '%states%'
group by location
order by TotalDeathCount desc

--Lets break the things down by continents--
select continent,Max (cast(Total_deaths as int)) as TotalDeathCount
from [dbo].[covid deaths1]
--where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc

--showing continents with the highest death counts per population--
select continent,Max (cast(Total_deaths as int)) as TotalDeathCount
from [dbo].[covid deaths1]
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Global numbers

select SUM(new_cases)as total_cases, SUM (CAST(new_deaths as int))  as total_deaths , SUM (CAST (new_deaths as int
))/SUM (new_cases)*100 as deathspercentages
from [dbo].[covid deaths1]
where continent is not null
order by 1,2



--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CAST(vac.new_vaccinations as int))OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo. [covid deaths1]dea
join dbo. [covid vaccination] vac
	On dea.date= vac.date
where dea.continent is not null
	order by 1,2,3


--USE CTE

wITH PopvsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CAST(vac.new_vaccinations as int))OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo. [covid deaths1]dea
join dbo. [covid vaccination] vac
	On dea.date= vac.date
where dea.continent is not null
	order by 1,2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



--Temp Table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CAST(vac.new_vaccinations as int))OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo. [covid deaths1]dea
join dbo. [covid vaccination] vac
	On dea.date= vac.date
where dea.continent is not null
--	order by 1,2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Create View

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CAST(vac.new_vaccinations as int))OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from dbo. [covid deaths1]dea
join dbo. [covid vaccination] vac
	On dea.date= vac.date
where dea.continent is not null
--order by 1,2,3

---Script for SelectTopNTRows command

select top(1000)[continent],[location],[date],[population],[new_vaccinations],[RollingPeopleVaccinated]
from dbo. PercentPopulationVaccinated