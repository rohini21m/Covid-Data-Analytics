SELECT continent,location, date, total_cases, new_cases,total_deaths,new_deaths, population, total_vaccinations,people_vaccinated,people_fully_vaccinated 

from [Covid Data Project].[dbo].[CovidDeaths$] 
where continent is not null
order by 1,2;

--Total Cases vs total deaths & Chances of getting effected by Covid in a country 
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Covid Data Project].[dbo].[CovidDeaths$] 
where location like '%States%' and continent is not null
order by 1,2;

--total population vs people fully vaccinated  

SELECT location, date, total_vaccinations, population, (total_vaccinations/population)*100 as US_Vaccination_Percentage
from [Covid Data Project].[dbo].[CovidDeaths$] 
where location like '%United States%' and continent is not null
order by 1,2;

--total Cases vs total population, Population that got covid in U.S 
SELECT location, date, total_cases, population, (total_cases/population)*100 as Total_Cases_Count
from [Covid Data Project].[dbo].[CovidDeaths$] 
where location like '%United States%' and continent is not null
order by 1,2;

--Countries with highest Covid infection rate 

select location, population ,MAX(total_cases) as HighestInfectionRate, MAX(total_cases/population)*100 as Highest_InfectionRate_Count
from [Covid Data Project].[dbo].[CovidDeaths$]
where continent is not null
Group by Location, population
order by 1,2;

--Country with New Covid Cases,new deaths despite People_fully_vaccinated 

select location,population, MAX(new_cases) as Cases_PostVaccination, Max(new_cases/people_fully_vaccinated)*100 as New_Cases_Count
from [Covid Data Project].[dbo].[CovidDeaths$] 
Group By location,population
order by 3,4;

--Specific Country with New Covid Cases despite People_fully_vaccinated 
select location,population, MAX(new_cases) as Cases_PostVaccination, Max(new_cases/people_fully_vaccinated)*100 as New_Cases_Count 
from [Covid Data Project].[dbo].[CovidDeaths$] 

Where location like '%Russia%' and continent is not null
Group By location,population
order by 3,4;

--Highest Death_Toll  per population over the world 
 select location, MAX(total_deaths) as Highest_Death_Toll
 from [Covid Data Project].[dbo].[CovidDeaths$] 
 where continent is not null
 Group By Location
 order by Highest_Death_Toll;

 --Highest death count by continent 
 select continent, MAX(total_deaths) as Highest_Death_Toll
 from [Covid Data Project].[dbo].[CovidDeaths$] 
 where continent is not null
 Group By continent
 order by Highest_Death_Toll;

 --global new cases by location 
 select location,SUM(new_cases) as New_Global_Cases
 from [Covid Data Project].[dbo].[CovidDeaths$] 
 where continent is not null
 Group By location
 order by 1,2;

 --global new cases & death global percentage by date
 select date,SUM(new_cases) as Global_New_Cases, SUM(cast(new_deaths as int))as Global_New_Deaths,(SUM(cast(new_deaths as int))/SUM(new_cases)*100) as Global_NewDeaths_Percentage
 from [Covid Data Project].[dbo].[CovidDeaths$] 
 where continent is not null
 Group By date
 order by 1,2;

 --deaths cases all over world 
 select SUM(new_cases) as Global_New_Cases, SUM(cast(new_deaths as int))as Global_New_Deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Global_NewDeaths_Percentage
 from [Covid Data Project].[dbo].[CovidDeaths$] 
 where continent is not null
 --Group By date
 order by 1,2;

 -- joining two tables 
 select *
 from [Covid Data Project].[dbo].[CovidDeaths$] as death
 join [Covid Data Project].[dbo].[CovidVaccinations$] as vaccinations
  on death.location=vaccinations.location 
  and  death.date=vaccinations.date

  --total population vs people that got vaccinations 
 select death.location, death.date, death.continent,death.population,vaccinations.people_vaccinated, vaccinations.total_vaccinations,vaccinations.new_vaccinations
 from [Covid Data Project].[dbo].[CovidDeaths$] as death
 join [Covid Data Project].[dbo].[CovidVaccinations$] as vaccinations
 on death.location=vaccinations.location 
 and  death.date=vaccinations.date
  Where death.continent is not null
 order by 2,3;

 -- new vaccinationations per location & Day,Shows Percentage of Population that has recieved at least one Covid Vaccine
 
 select death.location, death.date, death.continent,death.population,vaccinations.new_vaccinations,
 SUM(cast(vaccinations.new_vaccinations as int)) over (Partition by death.location Order by death.date, death.location) as RollingPeopleVaccinated 
 from [Covid Data Project].[dbo].[CovidDeaths$] as death
 join [Covid Data Project].[dbo].[CovidVaccinations$] as vaccinations
 on death.location=vaccinations.location 
 and  death.date=vaccinations.date
  Where death.continent is not null
 order by 2,3;

 -- Using CTE to perform Calculation on Partition By in previous query
 With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vaccinations.new_vaccinations
, SUM(CONVERT(int,vaccinations.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated

from [Covid Data Project].[dbo].[CovidDeaths$] as death
 join [Covid Data Project].[dbo].[CovidVaccinations$] as vaccinations
	On death.location = vaccinations.location
	and death.date = vaccinations.date
where death.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinationPercent
From PopvsVac

 
 --TEMP TABLE 
 Drop table if exists #TotalPopulationVaccinated 
 Create Table #TotalPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

Insert into #TotalPopulationVaccinated

Select death.continent, death.location, death.date, death.population, vaccinations.new_vaccinations
, SUM(CONVERT(int,vaccinations.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated

from [Covid Data Project].[dbo].[CovidDeaths$] as death
 join [Covid Data Project].[dbo].[CovidVaccinations$] as vaccinations
	On death.location = vaccinations.location
	and death.date = vaccinations.date
	where death.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercent
From #TotalPopulationVaccinated

--Creating View to store data for later visualizations

Create View TotalPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vaccinations.new_vaccinations
, SUM(CONVERT(int,vaccinations.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Covid Data Project].[dbo].[CovidDeaths$] as death
 join [Covid Data Project].[dbo].[CovidVaccinations$] as vaccinations
	On death.location = vaccinations.location
	and death.date = vaccinations.date
where death.continent is not null 
