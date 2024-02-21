-- Select data we are using
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Deaths
Where continent IS NOT NULL
Order by 1,2

--Total cases vs total deaths in %, shows likehood of dying if contracting Covid-19
--Rounded up to 5 decimals, without columns with NULL values
Select location, date, total_cases, total_deaths, population, ROUND(total_deaths/total_cases,5)*100 as DeathPercentage
From PortfolioProject..Deaths
Where total_deaths IS NOT NULL
Order by 1,2

--Total cases vs population
--Shows the percentage of population who got Covid
Select location, date,population,total_cases, ROUND(total_cases/population,5)*100 as DeathPercentage
From PortfolioProject..Deaths
--Where location like '%Kingdom'
Where continent IS NOT NULL
Order by 1,2

--Looking at countries with highest infection rate compared to population
Select location,population,MAX(total_cases)as HighestInfectCount, MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..Deaths
group by location, population
Order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
Select location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Deaths
Where continent IS NOT NULL
group by location
Order by TotalDeathCount desc

--Breaking down by Continent
Select location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Deaths
Where continent is null
group by location
Order by TotalDeathCount desc

--Looking at Total Population vs Vaccinations
Select Deaths.continent,Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations,
SUM(Convert(int,Vacc.new_vaccinations)) OVER(Partition by Deaths.location Order by Deaths.location, Deaths.date) as RollingPeopleVaccinated
From PortfolioProject..Deaths as Deaths
Join PortfolioProject..Vaccinations as Vacc
	On Deaths.location = Vacc.location
	and Deaths.date = Vacc.date
Where Deaths.continent is not null
Order by 2,3

--Use of CTE

With PopVacc(Continent, Location, Date, Population, New_Vaccinations,RollingPeopleVaccinated)
as 
(
Select Deaths.continent,Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations,
SUM(Convert(int,Vacc.new_vaccinations)) OVER(Partition by Deaths.location Order by Deaths.location, Deaths.date) as RollingPeopleVaccinated
From PortfolioProject..Deaths as Deaths
Join PortfolioProject..Vaccinations as Vacc
	On Deaths.location = Vacc.location
	and Deaths.date = Vacc.date
Where Deaths.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopVacc

--Temp table
Drop Table if exists #PercentPupulationVaccinated
Create Table #PercentPupulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into  #PercentPupulationVaccinated
Select Deaths.continent,Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations,
SUM(Convert(int,Vacc.new_vaccinations)) OVER(Partition by Deaths.location Order by Deaths.location, Deaths.date) as RollingPeopleVaccinated
From PortfolioProject..Deaths as Deaths
Join PortfolioProject..Vaccinations as Vacc
	On Deaths.location = Vacc.location
	and Deaths.date = Vacc.date
Where Deaths.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPupulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select Deaths.continent,Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations,
SUM(Convert(int,Vacc.new_vaccinations)) OVER(Partition by Deaths.location Order by Deaths.location, Deaths.date) as RollingPeopleVaccinated
From PortfolioProject..Deaths as Deaths
Join PortfolioProject..Vaccinations as Vacc
	On Deaths.location = Vacc.location
	and Deaths.date = Vacc.date
Where Deaths.continent is not null

Select *
From PercentPopulationVaccinated