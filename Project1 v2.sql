Select * 
From Project1..CovidDeaths$
Where continent is not null
Order by 3,4


--Select * 
--From Project1..CovidVaccinations$
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From Project1..CovidDeaths$
Order by 1,2


-- Total cases vs Total Deaths
--shows likelyhood of dying depending on location

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Project1..CovidDeaths$
Where location like '%states%'
Order by 1,2


-- Total cases vs Population
--shows Percentage of population with Covid

Select Location, date, population, total_cases,(total_cases/population)*100 as CovidCasePercentage
From Project1..CovidDeaths$
--Where continent is not null
Where location like '%states%'
Order by CovidCasePercentage desc


--Countries with the highest infection rate compared to population

Select continent, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as CovidCasePercentage
From Project1..CovidDeaths$
--Where Location like '%states%'
Where continent is not null
Group by continent
Order by CovidCasePercentage desc

-- Countries with HighestDeathCount

Select continent, Max(cast(total_deaths as int)) as HighestDeathCount, Max((total_deaths/population))*100 as DeathCountPercentage
From Project1..CovidDeaths$
--Where Location like '%states%'
Where continent is not null
Group by continent
Order by HighestDeathCount desc


-- Break down By Continent
-- Continent with highest death count

Select continent, Max(cast(total_deaths as int)) as HighestDeathCount
From Project1..CovidDeaths$
--Where Location like '%states%'
Where continent is not null
Group by continent 
Order by HighestDeathCount desc


-- Global Numbers
Select Sum(new_cases) as totCases, sum(cast(new_deaths as int)) as totDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
From Project1..CovidDeaths$
--Where Location like '%states%'
Where continent is not null
--Group by date
Order by 1, 2 

-- tot population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location  order by dea.location, dea.date) as RollinPeopleVac
--, 
From Project1..CovidDeaths$ dea
Join Project1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3

--USE CTE

with PopvsVac(continent, location, date, population, new_vaccinations, RollinPeopleVac)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location  order by dea.location, dea.date) as RollinPeopleVac
--, 
From Project1..CovidDeaths$ dea
Join Project1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3
)
Select *, (RollinPeopleVac/population)*100 as PercentPeopleVac
From PopvsVac


-- Temp Table

Drop table if exists #PercentPopVac
Create table #PercentPopVac
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollinPeopleVac numeric
 )
insert into #PercentPopVac

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location  order by dea.location, dea.date) as RollinPeopleVac
--, 
From Project1..CovidDeaths$ dea
Join Project1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2, 3
Select *, (RollinPeopleVac/population)*100 as PercentPeopleVac
From #PercentPopVac



-- Create View to store for later visual

Create view PercentPopVac 
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location  order by dea.location, dea.date) as RollinPeopleVac
--, 
From Project1..CovidDeaths$ dea
Join Project1..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3

Select *
From PercentPopVac


Create view HighDeathCount 
as
Select continent, Max(cast(total_deaths as int)) as HighestDeathCount
From Project1..CovidDeaths$
--Where Location like '%states%'
Where continent is not null
Group by continent 
--Order by HighestDeathCount desc

Select *
From HighDeathCount