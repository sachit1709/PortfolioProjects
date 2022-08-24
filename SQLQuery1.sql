

-- The dataset was taken from https://ourworldindata.org/covid-deaths on 19-August-2022


use ProjectResume;

-- Select query that we are going to use repitetively in the project

Select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2;

--Looking at total cases VS total deaths as well as death rate per day in all the locations

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS Death_rate
from CovidDeaths
--where Location = 'Canada' Or Location= 'India'
order by 1,2;

-- Looking at the total Cases Vs Population ( how much population got infected every day)

Select Location, date, total_cases, Population, (total_cases/population) *100 AS Infection_Rate
from CovidDeaths
where Location = 'Canada' Or Location= 'India'
order by 1,2;

-- Looking at countries with highest infection rate( total cases per total population)

Select Location, Max(total_cases) as Highest_Infection_count, Population, (Max(total_cases)/population) *100 AS Infection_Rate
from CovidDeaths
where Continent is not null
group by Location, population
order by population desc;

-- Looking Countries with highest Death rate per total population

Select Location, population, Max( Cast(total_deaths as int)) as Total_no_deaths ,  (Max(cast(total_deaths as int))/Population) *100 as Death_rate
from CovidDeaths
where continent is not null
Group by Location, population
order by total_no_deaths desc;

--Looking total no of deaths in terms of continents

Select continent, Max( Cast(total_deaths as int)) as Total_no_deaths
from CovidDeaths
where continent is not null
Group by continent
order by total_no_deaths desc;


--Looking continents in terms of highest death rate

Select continent,sum(distinct Population) as Total_Population, Sum( Cast(new_deaths as int)) as Total_no_deaths,  (Max(cast(total_deaths as int))/sum(distinct Population)) *100 as Death_rate
from CovidDeaths
where continent is not null
Group by continent
order by total_no_deaths desc;

--select Continent, Sum(distinct population) from CovidDeaths where continent='North America' group by Continent;
--select location, population from CovidDeaths where continent='North America';
--select * from CovidDeaths;

-- Global numbers per day

Select date, Sum(new_cases) as Total_cases_given_date, sum(cast (new_deaths as int)) as Total_deaths_given_date, (sum(cast(new_deaths as int))/sum(new_cases)) * 100 as Death_Rate_given_date
from CovidDeaths
where continent is not null
group by date
order by 1 desc;

-- creating temp table to look at rolling population getting new vaccines vs Fully Vaccinated rate till the date

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nVarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
People_Fully_Vaccinated numeric,
New_Vaccinations numeric,
Rolling_Vaccinated_People numeric

)

Insert into #PercentPopulationVaccinated
Select dea.Continent, dea.location, dea.date, dea.population,  
cast(vac.people_fully_vaccinated as BigINT) as people_fully_vaccinated,
cast(vac.new_vaccinations as BIGINT) as new_vaccinations,
SUM(Cast( vac.new_vaccinations as BIGINT )) Over (Partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinated_People
from CovidDeaths dea
Join CovidVaccinations vac
ON dea.location= vac.location
and dea.date=vac.date
where dea.continent is not null and dea.location ='Canada'

select *, (people_fully_vaccinated/population) * 100 as Fully_Vaccinated_Rate from #PercentPopulationVaccinated;

--Creating view for visualtization


Create View PercentPeopleVaccinated 
AS
Select dea.Continent, dea.location, dea.date, dea.population,  
cast(vac.people_fully_vaccinated as BigINT) as people_fully_vaccinated,
cast(vac.new_vaccinations as BIGINT) as new_vaccinations,
SUM(Cast( vac.new_vaccinations as BIGINT )) Over (Partition by dea.location order by dea.location, dea.date) as Rolling_Vaccinated_People
from CovidDeaths dea
Join CovidVaccinations vac
ON dea.location= vac.location
and dea.date=vac.date
where dea.continent is not null;

Select * from PercentPeopleVaccinated;