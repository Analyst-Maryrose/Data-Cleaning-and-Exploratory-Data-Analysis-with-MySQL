-- Exploratory Data Analysis
SELECT *
FROM layoffs_staging2;


-- Calculate the maximum number of layoff
SELECT MAX(total_laid_off)
FROM layoffs_staging2;

-- Looking at Percentage to see how big these layoffs were
SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM layoffs_staging2
WHERE  percentage_laid_off IS NOT NULL;

-- List of companies that completely lost their employees. The company that had 1 means that they had 100 percent of the company laid off. 
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1;
-- It looks like it is mostly startups that went out of business during this time.


-- Ordering the company by funds_raised_millions shows how big some of these companies were.
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- Britishvolt raised the highest fund and went under just like. 


-- Top 5 companies with the largest layoff on a single day
SELECT company, total_laid_off
FROM layoffs_staging2
ORDER BY 2 DESC
LIMIT 5;

-- Top 10 Companies with the most total layoff
SELECT company, SUM(total_laid_off) AS total_layoff
FROM layoffs_staging2
GROUP BY company 
ORDER BY 2 DESC
LIMIT 10;

-- Total layoff by location
SELECT location, SUM(total_laid_off) AS total_layoff
FROM layoffs_staging2
GROUP BY location 
ORDER BY 2 DESC;

-- Total layoff by country
SELECT country, SUM(total_laid_off) AS total_layoff
FROM layoffs_staging2
GROUP BY country 
ORDER BY 2 DESC;

-- Total layoff by industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Knowing the date range of our data
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;
-- This dataset covers a peroid of three years ie from 2020 to 2023

-- Which year had the most layoff
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Which stage had the most layoff
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


-- Yearly and Monthly Layoffs
SELECT SUBSTRING(`date`,1,7) AS year_months, SUM(total_laid_off) AS total_layoff
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY year_months
ORDER BY 1 ASC;

-- Rolling Total of Layoffs Per Month
WITH Rolling_Total AS
(SELECT SUBSTRING(`date`,1,7) AS year_months, SUM(total_laid_off) AS total_layoff
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY year_months
ORDER BY 1 ASC
)
SELECT year_months, total_layoff, SUM(total_layoff) OVER (ORDER BY year_months) AS rolling_total
FROM Rolling_Total;

-- Company layoff per year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Company layoffs per year ranking 
WITH company_year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
)
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM company_year
WHERE years IS NOT NULL
ORDER BY Ranking;

-- The top five company per year ranking
WITH company_year (company, years, total_laid_off) AS 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
), company_year_rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE Ranking <= 5;










