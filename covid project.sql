select *
from CovidDeaths
where continent is not null
order by 3,4

/*SELECT *
FROM [dbo].[CovidVaccinations]
ORDER BY 3,4*/


--1. total cases, total deaths, total death percentage


select sum(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as [death_percentage]
from CovidDeaths
where continent is not null 
order by 1,2

--2. total death count across the globe

select location, sum(new_deaths) as total_death_count
from CovidDeaths
where continent is null and location not in ('World', 'European Union', 'International', 'High income', 'Lower middle income', 'Upper middle income', 'Low income')
group by location
order by 2 desc

--3.infected population by country
--shows the percentage of the population that got covid in each country

select location, population, max(total_cases) as highest_infection_count, max(total_cases/population)*100 as [population_infected_percentage]
from CovidDeaths
where continent is not null
group by location, population
order by 4 desc

--4. highest percentage of infected population and dates

select location, population, date, max(total_cases) as HighestInfectionCount,  max(total_cases/population)*100 as [population_infected_percentage]
From CovidDeaths
group by location, population, date
order by population_infected_percentage desc


--5. total death count per country

select location, max(total_deaths) as [total_death_count]
from CovidDeaths
where continent is not null
group by location
order by 2 desc

--6.total death count by continent

select location, max(total_deaths) as [total_death_count]
from CovidDeaths
where continent is null and location not like'World%' and location not like '%income%' and location not like '%union%'
group by location
order by 2 desc

--7.global death percentage by date

select date, isnull(sum(new_cases), 0) as [total_cases], isnull(sum(new_deaths), 0) as [total_deaths],
    case
        when isnull(sum(new_cases), 0) = 0 then 0
        else isnull(sum(new_deaths), 0) / isnull(sum(new_cases), 0) * 100
    end as [death_percentage]
from CovidDeaths
where continent is not null
group by date
order by date


--8.percentage of population vaccinated globally
--a.using CTE

with PopVsVac (continent, location, date, population, new_vaccinations, rolling_vaccination_count)
as
(
select distinct a.continent, a.location, a.date, a.population, b.new_vaccinations, sum(cast(b.new_vaccinations as float)) over (partition by a.location order by a.location, a.date) as [rolling_vaccination_count]
from CovidDeaths a
join CovidVaccinations b
on a.location = b.location and a.date = b.date
where a.continent is not null
)
select *, (rolling_vaccination_count/population)*100 as [vaccinated_percentage]
from PopVsVac


--b.using temp table

drop table if exists #percentofpopvac --this is to ensure this query runs without error in the event of a rerun
create table #percentofpopvac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations float,
rolling_vaccination_count float
)

insert into #percentofpopvac
select distinct a.continent, a.location, a.date, a.population, b.new_vaccinations, sum(cast(b.new_vaccinations as float)) over (partition by a.location order by a.location, a.date) as [rolling_vaccination_count]
from CovidDeaths a
join CovidVaccinations b
on a.location = b.location and a.date = b.date
where a.continent is not null

select *, (rolling_vaccination_count/population)*100
from #percentofpopvac

