select *
from CovidDeaths
where continent is not null
order by 3,4

/*SELECT *
FROM [dbo].[CovidVaccinations]
ORDER BY 3,4*/

--select data to be used
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2


--changing data types on total_cases and total_deaths column from nvarchar(255) to float
--this is to be able to perform arithmetic operations on the columns

alter table CovidDeaths
alter column total_cases float

alter table CovidDeaths
alter column total_deaths float

--total cases vs total deaths
--shows chances of dying if you get covid

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as [death_percentage]
from CovidDeaths
where continent is not null
order by 1,2

--total cases vs population
--shows the percentage of the population that got covid

select location, date, population, total_cases, (total_cases/population)*100 as [population_infected_percentage]
from CovidDeaths
where continent is not null
order by 1,2

--countries with higest infection rates compared to population

select location, population, max(total_cases) as [highest_infection_count], max((total_cases/population))*100 as [population_infected_percentage]
from CovidDeaths
where continent is not null
group by location, population
order by 4 desc

--countries with highest death count per population

select location, max(total_deaths) as [total_death_count]
from CovidDeaths
where continent is not null
group by location
order by 2 desc

--highest total death count by continent

select location, max(total_deaths) as [total_death_count]
from CovidDeaths
where continent is null and location not like'World%' and location not like '%income%' and location not like '%union%'
group by location
order by 2 desc

--global numbers

--showing global death percentage by date

select date, isnull(sum(new_cases), 0) as [total_cases], isnull(sum(new_deaths), 0) as [total_deaths],
    case
        when isnull(sum(new_cases), 0) = 0 then 0
        else isnull(sum(new_deaths), 0) / isnull(sum(new_cases), 0) * 100
    end as [death_percentage]
from CovidDeaths
where continent is not null
group by date
order by date


--global total population vs vaccinations
--this shows the percentage of population vaccinated
--using CTE

with PopVsVac (continent, location, date, population, new_vaccinations, rolling_vaccination_count)
as
(
select distinct a.continent, a.location, a.date, a.population, b.new_vaccinations, sum(cast(b.new_vaccinations as float)) over (partition by a.location order by a.location, a.date) as [rolling_vaccination_count]
from CovidDeaths a
join CovidVaccinations b
on a.location = b.location and a.date = b.date
where a.continent is not null
)
select *, (rolling_vaccination_count/population)*100
from PopVsVac


--using temp table to get the percentage of population vaccinated

drop table if exists #percentofpopvac
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


--creating views to store data for visualizations

--1.percentage of population vaccinated

create view percentofpopvac as
select distinct a.continent, a.location, a.date, a.population, b.new_vaccinations, sum(cast(b.new_vaccinations as float)) over (partition by a.location order by a.location, a.date) as [rolling_vaccination_count]
from CovidDeaths a
join CovidVaccinations b
on a.location = b.location and a.date = b.date
where a.continent is not null

--2.showing global death percentage by date

create view deathpercentage as
select date, isnull(sum(new_cases), 0) as [total_cases], isnull(sum(new_deaths), 0) as [total_deaths],
    case
        when isnull(sum(new_cases), 0) = 0 then 0
        else isnull(sum(new_deaths), 0) / isnull(sum(new_cases), 0) * 100
    end as [death_percentage]
from CovidDeaths
where continent is not null
group by date

--3.highest total death count by continent

create view highestdeathcount as
select location, max(total_deaths) as [total_death_count]
from CovidDeaths
where continent is null and location not like'World%' and location not like '%income%' and location not like '%union%'
group by location

--4.countries with highest death count per population

create view deathcountbycountries as
select location, max(total_deaths) as [total_death_count]
from CovidDeaths
where continent is not null
group by location

--5.countries with highest infection rates compared to population

create view highestinfectedpercentage as
select location, population, max(total_cases) as [highest_infection_count], max((total_cases/population))*100 as [population_infected_percentage]
from CovidDeaths
where continent is not null
group by location, population

--6.shows the percentage of the population that got covid

create view populationinfectedpercentage as
select location, date, population, total_cases, (total_cases/population)*100 as [population_infected_percentage]
from CovidDeaths
where continent is not null

--7.total cases vs total deaths i.e chances of dying from covid

create view totalcasesvstotaldeath as
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as [death_percentage]
from CovidDeaths
where continent is not null