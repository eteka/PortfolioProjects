Select *
From PortfolioProject..CovidDeaths
order by 3, 4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3, 4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of death after contracting covid in Nigeria

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like 'Nigeria'
order by 1, 2

--Looking at total cases vs Population
--Shows what perceantage of population caught covid in Nigeria
Select Location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
where location like 'Nigeria'
order by 1, 2
-- Looking at countries with highest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentageOfPopulationInfected
From PortfolioProject..CovidDeaths
--where location like 'Nigeria'
Group by Location, population
order by PercentageOfPopulationInfected desc

-- Looking at countries with highest death rate compared to population

Select Location, Population, MAX(total_deaths) as HighestDeathCount, Max(total_deaths/population)*100 as PercentageOfPopulationKilled
From PortfolioProject..CovidDeaths
--where location like 'Nigeria'
Group by Location, population
order by PercentageOfPopulationKilled desc

-- Looking at countries with highest death rate

Select Location, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
--where location like 'Nigeria'
where continent is not null
Group by Location, population
order by HighestDeathCount desc



-- LETS BREAK DOWN BY CONTINENT


Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
--where location like 'income'
where continent is not null
Group by continent
order by HighestDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int))as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like 'Nigeria'
where continent is not null
--Group by date
order by 1, 2


--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT (bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT (bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT (bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



-- Creating view to store data for future visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT (bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
