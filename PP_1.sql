Select *
From Portfolio_Project..Covid_Deaths
Where continent is not null;

--Select *
--From Portfolio_Project..Covid_Vaccinations
--Order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..Covid_Deaths
order by 1,2;



-- Changing data types

Alter table Covid_Deaths
Alter column total_deaths decimal;

Alter table Covid_Deaths
Alter column total_cases decimal;



-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Vietnam

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentPopulationInfected
From Portfolio_Project..Covid_Deaths
Where location like '%Vietnam%'
Order by 1,2;


-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
From Portfolio_Project..Covid_Deaths
Where location like '%Vietnam%'
Order by 1,2;


-- Looking at Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as 
	PercentPopulationInfected
From Portfolio_Project..Covid_Deaths
Group by location, population
Order by PercentPopulationInfected desc;


-- Showing Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as numeric)) as TotalDeathCount
From Portfolio_Project..Covid_Deaths
Where continent is not null
Group by location
Order by TotalDeathCount desc;



-- BREAKING THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_Project..Covid_Deaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc;


-- GLOBAL NUMBERS

Select date, SUM(new_cases)as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From Portfolio_Project..Covid_Deaths
Where continent is not null and new_cases > 0 
Group by date
Order by 1,2;


-- JOIN Covid Deaths table with Covid Vaccinations table
-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as numeric)) 
OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..Covid_Deaths dea
Join Portfolio_Project..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3;



--USING CTE

With PopvsVac (Continent, Location, Date, Population,New_vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as numeric)) 
OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..Covid_Deaths dea
Join Portfolio_Project..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select*,(RollingPeopleVaccinated/population)*100
From PopvsVac;


--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as numeric)) 
OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..Covid_Deaths dea
Join Portfolio_Project..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select*,(RollingPeopleVaccinated/population)*100 as PercentageOfVaccinationsDayByDay
From #PercentPopulationVaccinated;



--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as numeric)) 
OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Portfolio_Project..Covid_Deaths dea
Join Portfolio_Project..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3