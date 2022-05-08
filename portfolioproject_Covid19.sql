/**** Portfolio Project Covid19 Analysis *****/


create database portfolio

use portfolio

select * 
from portfolio..deaths
order by 3,4



/** value in the column 'location' is the name of the continet wherever the value in the column 'continent' is null.
Hence we have used 'where continent is not null' whenever we pull the location so as to get exact results **/

select location
	,date
	,total_cases
	,new_cases
	,new_deaths
	,cast(total_deaths as float) as total_death
	,population
from portfolio..deaths
where continent is not null
order by 1,2


-- Total cases VS population. 
-- To see what percentage of people have been infected by Covid worldwide.===========================================

select location
	,date
	,total_cases
	,population
	,round((total_cases/population)*100,4) as infection_percentage
from portfolio..deaths
where continent is not null
order by 1,2


-- Total cases VS total deaths for India (death percentage)==============================================
 -- typecasted the total death column as it was a nvarchar and was givinfg wrong results in max function

select a.location
	,a.population
	,a.date
	,a.total_cases
	,round((cast(a.total_cases as float) /a.population)*100,3) as percent_people_infected
	,b.people_fully_vaccinated as people_fully_vaccinated
	,round((cast(b.[people_fully_vaccinated] as float) /a.population)*100,3) as percent_people_fully_vaccinated
	,cast(total_deaths as float) as total_deaths
	,round(((cast(total_deaths as float)/total_cases))*100,3) as death_percentage_India
from portfolio..deaths a
join portfolio..vaccinations b 
on a.location = b.location and a.date = b.date
where a.location = 'india'
and a.continent is not null
--and a.date between '2021-07-18' and '2022-01-18'
order by 1,3
 




select * 
from portfolio..vaccinations
order by 3,4



-- Population Vs Vaccinations =================================================================================
/*  We need to create a temp table as we want to calculate percentage of total people vaccinated 
w.r.t. population per courntry out of a derived column (sum of all new vaccinations
as 'total_people_vaccinated_by_country')   */

with pop_vac (location, date, population, new_vaccinations, total_people_vaccinated_by_country)
as
(
select d.location
	,d.date
	,d.population
	,new_vaccinations
	,sum(convert(float,new_vaccinations)) over(partition by d.location order by d.location, d.date) 
	as total_people_vaccinated_by_country
from portfolio..deaths as d
join portfolio..vaccinations as v
on d.location = v.location
and d.date = v.date
where d.continent is not null
)
select *
	,(total_people_vaccinated_by_country/population)*100 percent_population_vaccinated
from pop_vac




-- Global death percentage ========================================================================================

select location
	,date
	,total_cases
	,cast(total_deaths as float) as total_deaths
	,round(((cast(total_deaths as float)/total_cases))*100,3) as death_percentage
from portfolio..deaths
where continent is not null
order by 1,2



-- countries with highest infection percentage compared to population ============================================= 

select location
	,max(total_cases) as max_total_cases
	,population
	,round(max(total_cases/population)*100,4) as infection_percentage
from portfolio..deaths
where continent is not null
group by location, population
order by infection_percentage desc


-- countries with highest death count compared to population ============================================= 
 -- typecasted the total death column as it was a nvarchar and was givinfg wrong results in max function 

select location
	,max(cast (total_deaths as int)) as total_deaths_count 
	,population
from portfolio..deaths
where continent is not null
group by location, population
order by total_deaths_count desc



-- Continents with highest death count ========================================================================


create view total_deaths_by_continents as
select continent 
	,max(cast(total_deaths as float)) as total_deaths_count
from portfolio..deaths
where continent is not null
group by continent
--order by total_deaths_count desc



-- Looking at global numbers total cases, total deaths, total death percentage =======================================
create view global as
select sum(new_cases) as total_cases
	,sum(cast(new_deaths as float)) as total_deaths
	,(sum(cast(new_deaths as float))/sum(new_cases))*100 as global_death_percentage
from portfolio..deaths
where continent is not null



-- Looking at Indian numbers total cases, total deaths, total death percentage =======================================

create view India_overall as
select population as India_population
	,sum(new_cases) as total_cases_India
	,sum(cast(new_deaths as float)) as total_deaths_India
	,(sum(cast(new_deaths as float))/sum(new_cases))*100 as death_percentage_India
from portfolio..deaths
where continent is not null
and location = 'India'
group by population

-- View created -> total_deaths_by_continents, India_overall, global


