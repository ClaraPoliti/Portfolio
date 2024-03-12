Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4




--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4


--Select Data 

Select Location, date, total_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total Cases vs Total Deaths in France
-- Taux de mortalité en France
Select Location, date, total_cases, total_deaths
,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location = 'France'
and continent is not null
order by 1,2

--Total Cases vs Population in France
-- Pourcentage de population contaminée
Select Location, date, population, total_cases
,(total_cases/population)*100 as InfectedCasesPercentage
From PortfolioProject..CovidDeaths
where location = 'France'
and continent is not null
order by 1,2

--Countries with highest infection rate according to population
--Les pays avec la taux de contamination plus élevé selon population
Select Location, population, MAX(total_cases) as HighestInfectionCount
, Max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location, population
order by PercentagePopulationInfected desc

-- Countries with highest Death Count per population
--Les pays avec la taux de contamination plus élevé selon population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
where continent is not null
Group by Location, population
order by TotalDeathCount desc

--DeathCount by Continent
-- Analysis pour Continent
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths
where continent is null
Group by Location
order by TotalDeathCount desc

--World Deaths by date
-- Morts mondiales pour date
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths
, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths 
where continent is not null
Group by date
order by 1,2


-- total population vs vaccinated
-- Population vs population vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) 
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Creation CTE
With PopvsVacc (Continent,location,date, population, new_vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as PeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
) 
Select *,(PeopleVaccinated/population)*100 as PercentageVacc
From PopvsVacc


-- Creation Tableau
DROP Table if exists #PercentPeopleTested
Create Table #PercentPeopleTested
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
new_tests numeric,
PeopleTested numeric
)

Insert into #PercentPeopleTested
Select dea.continent, dea.location, dea.date, dea.population, vac.new_tests
,sum(convert(int,vac.new_tests)) Over (Partition by dea.location Order by dea.location,
dea.date) as PeopleTested
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
 

Select *,(PeopleTested/population)*100 as PercentageTested
From #PercentPeopleTested


--creation de données stockées a utiliser apres dans la visualisation
Create View PercentPeopleTested as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_tests
,sum(convert(int,vac.new_tests)) Over (Partition by dea.location Order by dea.location,
dea.date) as PeopleTested
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPeopleTested 