--select * from first_portfolio_project..['covidDeaths'] 
--order by 3,4 

--select * from first_portfolio_project..['CovidVaccinations']
--order by 3, 4

--select location, date, population, total_cases, new_cases, total_deaths

--from first_portfolio_project..['covidDeaths']

--order by 1,2

 
 -- Looking at toatl cases vs total deaths

select location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as Percenatge

from first_portfolio_project..['covidDeaths']

where location = 'india'

order by 1,2


--loodking at total cases vc population

select location, date, population, total_cases, ((total_cases/population)*100) as Percenatge

from first_portfolio_project..['covidDeaths']

order by 1,2

--looking at highest country infected comapred to population

select location, population, MAX( total_cases) as highest_infection_rate , (max(total_cases/population)*100) as Percenatge

from first_portfolio_project..['covidDeaths']

group by location, population
order by Percenatge desc

-- loking at country with highest death count per population

select location, max(cast(total_deaths as int)) as total_deaths

from first_portfolio_project..['covidDeaths']

where continent is  null

group by location
order by total_deaths desc

-- by continent

select continent, max(cast(total_deaths as int)) as total_deaths

from first_portfolio_project..['covidDeaths']

where continent is not null

group by continent
order by total_deaths desc


-- global numbers 

select date, sum(cast(new_cases as int)) as Total_cases, sum( cast(new_deaths as int)) as total_deaths, ((sum(cast(new_cases as int))/sum((cast(new_deaths as int))))*100) as total_percentage 

from first_portfolio_project..['covidDeaths']

where continent is not null

group by date

order by 1,2 


-- join both tables
select * 
from first_portfolio_project..['covidDeaths'] dea
join first_portfolio_project..['CovidVaccinations'] vac
on dea.location = vac.location
and dea.date = vac.date


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations

from first_portfolio_project..['covidDeaths'] dea
join first_portfolio_project..['CovidVaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3 


--finding sum_of vaccineted 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations))  over (partition by dea.location order by dea.location, dea.date) as sumOf_people_vaccinated

from first_portfolio_project..['covidDeaths'] dea
join first_portfolio_project..['CovidVaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 


--use CTE- commom tabel expression

with popvsVac(continent, location, date, population, new_vaccinations, sumOf_people_vaccinated)

as
(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert(int,vac.new_vaccinations))  over (partition by dea.location order by dea.location, dea.date) as sumOf_people_vaccinated

	from first_portfolio_project..['covidDeaths'] dea
	join first_portfolio_project..['CovidVaccinations'] vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
)
select * , ((sumOf_people_vaccinated/population)*100) as percentage 

from popvsVac

-- create temp table 
drop table if exists  #Percent_people_vaccinated

create table #Percent_people_vaccinated
(
  continent nvarchar(255),
  location nvarchar(255),
  date datetime, 
  population numeric,
  new_vaccinations numeric,
  sumOf_people_vaccinated numeric
)
insert into #Percent_people_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert(int,vac.new_vaccinations))  over (partition by dea.location order by dea.location, dea.date) as sumOf_people_vaccinated

	from first_portfolio_project..['covidDeaths'] dea
	join first_portfolio_project..['CovidVaccinations'] vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null

select * , ((sumOf_people_vaccinated/population)*100) as percentage 

from #Percent_people_vaccinated

where location = 'india'

-- create view 

create view percent_of_people_vaccinenated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert(int,vac.new_vaccinations))  over (partition by dea.location order by dea.location, dea.date) as sumOf_people_vaccinated

	from first_portfolio_project..['covidDeaths'] dea
	join first_portfolio_project..['CovidVaccinations'] vac
		on dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null

select * from percent_of_people_vaccinenated