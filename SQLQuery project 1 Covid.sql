-- I did this project with the help from Alex project video: https://www.youtube.com/@AlexTheAnalyst

SELECT*
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT*
--FROM PortfolioProject..CovidVaccinations
--order by 3,4
-- Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood if you contract covid in your France

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%France%'
order by 1,2

-- Looking at the Total Cases vs Population
-- shows what percentage of people got covid
Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%France%'
order by 1,2

-- Looking at Countries with highest infection rate compared to population
Select location, population, max(total_cases) as highest_infection_count, max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- where location like '%France%'
group by location, population
order by 4 desc

-- Showing the highest death count per population

Select location, max(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- where location like '%France%'
Where continent is not null
group by location
order by TotalDeathCount desc

-- Let's break thing down by continent

-- Showing continents with the highest death count per population

Select continent, max(cast (total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- where location like '%France%'
Where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT SUM(new_cases), SUM(cast(new_deaths as int)), 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%France%'
where continent is not null
--group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location, dea.Date) as RollingPeapleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER(partition by dea.location order by dea.location, dea.Date) as RollingPeapleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT*, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location ) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
