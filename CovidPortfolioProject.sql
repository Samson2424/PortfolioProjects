Select *
From PortfolioProjectCovidDeath..CovidDeaths$
Where continent is not null
order by 3,4


--Select *
--From PortfolioProjectCovidDeath..CovidVaccinations$
--order by 3,4

--select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjectCovidDeath..CovidDeaths$
order by 1,2

--Looking at total cases vs Total Deaths
--Shows likelyhood of dying if you get covid in your country

Select Location, date, total_cases, total_deaths, (Convert(float,total_deaths)/Convert(float,total_cases))*100 as DeathPercentage
From PortfolioProjectCovidDeath..CovidDeaths$
Where location like '%states%'
order by 1,2


--Looking at the total cases vs Population
--Shows what percentage of population got Covid

Select Location, date, population, total_cases, (Convert(float,total_cases)/Convert(float,population))*100 as PercentPopulationInfected
From PortfolioProjectCovidDeath..CovidDeaths$
Where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((Convert(float,total_cases)/Convert(float,population)))*100 as PercentPopulationInfected
From PortfolioProjectCovidDeath..CovidDeaths$
--Where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

--Showing the countries with highest death count per population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectCovidDeath..CovidDeaths$
--Where location like '%states%'
Where continent is not null
group by location
order by TotalDeathCount desc

--LEts break things down by continent

Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectCovidDeath..CovidDeaths$
--Where location like '%states%'
Where continent is null
group by location
order by TotalDeathCount desc


--Showing the continents with the hightest death count per population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectCovidDeath..CovidDeaths$
--Where location like '%states%'
Where continent is not null
group by continent
order by TotalDeathCount desc


-- global numbers

SET ANSI_WARNINGS OFF

Select date, SUM(new_cases) as total_cases_worldwide, SUM(new_deaths) as total_deaths_worldwide, SUM(cast(new_deaths as int))/SUM(cast(new_cases as int))*100 as DeathPercentage
From PortfolioProjectCovidDeath..CovidDeaths$
where continent is not null
group by date
order by 1,2


--Joining the two datasets

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovidDeath..CovidDeaths$ dea
Join PortfolioProjectCovidDeath..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovidDeath..CovidDeaths$ dea
Join PortfolioProjectCovidDeath..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Creating a Temporary Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovidDeath..CovidDeaths$ dea
Join PortfolioProjectCovidDeath..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovidDeath..CovidDeaths$ dea
Join PortfolioProjectCovidDeath..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 