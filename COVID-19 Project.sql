Select *
from PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4


--Select *
--from PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select the Data that we are going to be using


Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases Vs. Total Deaths (Shows likelyhood of dying if yiou contract Covid-19 from your country)

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 [Death%]
From PortfolioProject..CovidDeaths
Where location like '%Kenya%'
Order by 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 [Death%]
From PortfolioProject..CovidDeaths
Where location = 'Haiti'
Order by 1,2


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 [Death%]
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2


--Looking at Total Cases Vs. Population (What % of the Populatioin got Covid)

Select Location, date, population, total_cases,  (total_cases/population)*100 [% Pop with Covid]
From PortfolioProject..CovidDeaths
Where location like '%Kenya%'
Order by 1,2

Select Location, date, population, total_cases,  (total_cases/population)*100 [% Pop with Covid]
From PortfolioProject..CovidDeaths
Where location like '%states'
Order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) [Highest Infection Count], MAX((total_cases/population))*100 [% Population Infected]
From PortfolioProject..CovidDeaths
--Where location like '%Kenya%'
Group by location, population
Order by 4 desc


--Showing Countries with Highest Death Count per Population

Select Location, MAX(Cast(total_deaths as int)) [Total Death Count]--, MAX((total_deaths/population))*100 [Total Death Count]
From PortfolioProject..CovidDeaths
--Where location like '%Kenya%'
Where continent is not null
Group by location
Order by 2 desc


-- Let's Break Things Down by Continent

Select continent, MAX(Cast(total_deaths as int)) [Total Death Count]--, MAX((total_deaths/population))*100 [Total Death Count]
From PortfolioProject..CovidDeaths
--Where location like '%Kenya%'
Where continent is not null
Group by continent
Order by 2 desc



Select location, MAX(Cast(total_deaths as int)) [Total Death Count]--, MAX((total_deaths/population))*100 [Total Death Count]
From PortfolioProject..CovidDeaths
--Where location like '%Kenya%'
Where continent is null
Group by location
Order by 2 desc



-- Showing the Continents with the highest Death Count per Population

Select continent, MAX(Cast(total_deaths as int)) [Total Death Count]--, MAX((total_deaths/population))*100 [Total Death Count]
From PortfolioProject..CovidDeaths
--Where location like '%Kenya%'
Where continent is not null
Group by continent
Order by 2 desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) [Total Cases], SUM(Cast(new_deaths as int))[Total Deaths], SUM(Cast(new_deaths as int))/SUM(new_cases)*100 [Global Death%]
From PortfolioProject..CovidDeaths
--Where location like '%Kenya%'
Where continent is not null
Group by date
Order by 1,2


Select SUM(new_cases) [Total Cases], SUM(Cast(new_deaths as int))[Total Deaths], SUM(Cast(new_deaths as int))/SUM(new_cases)*100 [Global Death%]
From PortfolioProject..CovidDeaths
--Where location like '%Kenya%'
Where continent is not null
--Group by date
Order by 1,2


-- Looking at the Total Poluation Vs. Vaccinated
	-- First script sets it up
Select * 
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date


--Second script goes into details

Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(Cast(v.new_vaccinations as int)) OVER (Partition by d.location)
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
Where d.continent is not null
Order by 2,3


Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int, v.new_vaccinations)) OVER (Partition by d.location Order by d.location, d.date) [Rolling People Vaccinated]

From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
Where d.continent is not null
Order by 2,3



-- Using CTE to perform calculation on 'Partition By' in previous query

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(int, v.new_vaccinations)) OVER (Partition by d.Location Order by d.Location, d.Date) [Rolling People Vaccinated]
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
Where d.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 [% Pop Vaccinated Vs. Population]
From PopVsVac



-- Using Temp Table to perform Calculation on Partition By previous query

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
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) [Rolling People Vaccinated]
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
		On d.location = v.location
		and d.date = v.date
--Where d.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 [% Pop Vaccinated Vs. Population]
From #PercentPopulationVaccinated



-- Creating View to Store Data for Later Visualization

Create View PercentPopulationVaccinated as 
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(CONVERT(bigint,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) [Rolling People Vaccinated]
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths d
Join PortfolioProject..CovidVaccinations v
		On d.location = v.location
		and d.date = v.date
Where d.continent is not null
--Order by 2,3


Select * 
From PercentPopulationVaccinated