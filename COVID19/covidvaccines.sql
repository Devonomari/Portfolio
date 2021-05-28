SELECT cv.continent,MAX(cd.population) Population,cv.location, MAX(cv.people_fully_vaccinated) fulled_vaxed, 
	ROUND(MAX(cv.people_fully_vaccinated::numeric)/MAX(cd.population) *100,3) as percent_vaxed
FROM covidvaccinations cv
JOIN coviddeaths cd
	ON cv.location = cd.location AND cv.date = cd.date
WHERE cd.population > 10000000
GROUP BY cv.location, cv.continent 
HAVING cv.continent IS NOT NULL AND MAX(cv.people_fully_vaccinated) IS NOT NULL
ORDER BY 4 DESC
