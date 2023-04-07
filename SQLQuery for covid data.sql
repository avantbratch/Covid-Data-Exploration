
--Data Exploration

use KOVID

select *
from covid_vaccinations


select *
from covid_deaths
order by date

select
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
from covid_deaths
order by 1, 2

-- Total Cases vs Total Deaths by country (Percentage)

ALTER TABLE covid_deaths ALTER COLUMN total_deaths float;  
ALTER TABLE covid_deaths ALTER COLUMN total_cases float;  

select location, date,  total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid_deaths
order by 1,2

-- Total Cases / Population

select location, date,  total_cases, population, (total_cases/population)*100 as infected_percentage
from covid_deaths
where location = 'Georgia'
order by 1,2

--infection rate compared to population

select location,  MAX(total_cases) as max_total_cases, population, MAX(total_cases/population)*100 as infection_count
from covid_deaths
group by location, population
order by infection_count desc

--Vaccination / total population

with popvsvacc (continent, location, date, population, new_vaccinations, rolling_sum_vaccinations)
as
(
select cv.continent, cv.location, cv.date, cd.population, cv.new_vaccinations,
		sum(cast(cv.new_vaccinations as bigint)) over (partition by cv.location order by cv.location, cv.date) as rolling_sum_vaccination
from covid_deaths cd
join covid_vaccinations cv 
	on cv.location = cd.location 
	and cv.date = cd.date
where cd.continent is not null
)

select *, (rolling_sum_vaccinations/population)*100 from  popvsvacc
where location='Georgia'
order by continent, location, date

--Create View for Visualization

create view population_vaccinated as 
select cv.continent, cv.location, cv.date, cd.population, cv.new_vaccinations,
		sum(cast(cv.new_vaccinations as bigint)) over (partition by cv.location order by cv.location, cv.date) as rolling_sum_vaccination
from covid_deaths cd
join covid_vaccinations cv 
	on cv.location = cd.location 
	and cv.date = cd.date
where cd.continent is not null

select * from population_vaccinated

--Death Percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From covid_deaths
where continent is not null 
--Group By date
order by 1,2

--Continent and death count

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From covid_deaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
and location not like '%Income%'
Group by location
order by TotalDeathCount desc

--Infected Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deaths
Group by Location, Population
order by PercentPopulationInfected desc

--Infected Population Percentage

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_deaths
Group by Location, Population, date
order by location, date 

--Creating dates and location tables for data modelling in power bi

select distinct date 
from covid_deaths
order by date

select distinct location
from covid_deaths
where location not like '%income%'
order by location
