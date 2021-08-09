SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY 1,2

------------------
--Total Deaths as a proportion to Total cases in a country over time
-- This is not a perfect representation of the likelihood of death, since not all cases of covid are tested and reported
SELECT location, date, total_cases, total_deaths, CAST(total_deaths as float)/total_cases*100 AS death_perentage
FROM coviddeaths
ORDER BY 1,2

------------------
--Total Cases vs Population
SELECT location, date, total_cases, population, CAST(total_cases as float)/population*100 AS percentage_infected
FROM coviddeaths
ORDER BY 1,2

------------------
--Countries ranked by percentage of their population testing positive for Covid
SELECT location, MAX(total_cases) as total_cases_today, MAX(population) Population, ROUND(CAST(MAX(total_cases) as numeric)/MAX(population)*100,2) AS percentage_infected
FROM coviddeaths
WHERE continent IS NOT NULL -- Some of location entries are entire continents and can be identified by where continent is NULL
GROUP BY location
HAVING MAX(total_cases) IS NOT NULL
ORDER BY 4 DESC

------------------
--Countries ranked by percentage of their population dying from Covid
SELECT location, MAX(total_deaths) as total_deaths_today, MAX(population) Population, ROUND(CAST(MAX(total_deaths) as numeric)/MAX(population)*100,2) AS percentage_died
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
HAVING MAX(total_deaths) IS NOT NULL 
ORDER BY 4 DESC

------------------
-- TOTAL DEATH BY CONTINENT
SELECT location, MAX(total_deaths) as Total_Death_Count
FROM coviddeaths
WHERE continent IS NULL
GROUP BY location
HAVING MAX(total_deaths) IS NOT NULL AND location NOT IN('International','World','European Union')
ORDER BY 2 DESC

------------------
-- GLOBAL caseses over time
SELECT date, SUM(new_Cases) as global_new_cases 
, SUM(SUM(new_Cases)) OVER(order by date) AS running_total
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date
Order by date

------------------
--Vaccines administered over time
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(vacc.new_vaccinations) OVER(partition by death.location ORDER BY death.location, death.date) total_vaccs_rolling
FROM coviddeaths death
JOIN covidvaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3

------------------
-- CTE
WITH popvsvac AS
(
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, vacc.people_fully_vaccinated
, SUM(vacc.new_vaccinations) OVER(partition by death.location ORDER BY death.location, death.date) total_vaccs_rolling
FROM coviddeaths death
JOIN covidvaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3
)
SELECT *, people_fully_vaccinated/population*100 AS percent_population_vaccinated_fully
FROM popvsvac
WHERE location = 'United States'
AND date > '12/25/2020'

------------------
-- Creating View to store for later
CREATE VIEW PercentPopulationVaccinatedGlobal AS

WITH popvsvac AS
(
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations, vacc.people_fully_vaccinated
, SUM(vacc.new_vaccinations) OVER(partition by death.location ORDER BY death.location, death.date) total_vaccs_rolling
FROM coviddeaths death
JOIN covidvaccinations vacc
	ON death.location = vacc.location
	AND death.date = vacc.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3
)

SELECT *, people_fully_vaccinated/population*100 AS percent_population_vaccinated_fully
FROM popvsvac
--WHERE location = 'United States'
WHERE date > '12/25/2020'
