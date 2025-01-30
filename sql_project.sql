-- Cleaning the data

-- Create database that will hold our imported data
CREATE DATABASE world_layoffs;
USE world_layoffs;

-- First, create a staging table where the data can be cleaned. This helps to ensure that the raw data is intact incase any issue comes up.
CREATE TABLE layoffs_staging 
LIKE layoffs;

-- Insert data into the staging table.
INSERT layoffs_staging 
SELECT * FROM world_layoffs.layoffs;

-- The data cleaning stages include:
-- 1. Removing duplicates if any.
-- 2. Standardization of data and fixing errors.
-- 3. Removing null values if any.
-- 4. Remove any unnecessary columns or row


-- 1. Removing Duplicates

SELECT *
FROM layoffs_staging;

-- Assigning row number to the data so as to easily indentify any duplicate value.
WITH layoff_duplicate AS 
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM layoff_duplicate
WHERE row_num > 1;

-- To delete the rows which are duplicates, it is encouraged to create another table where the duplicates will be safely deleted.
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert values into the created layoffs_stagging2 table.
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions) 
AS row_num
FROM layoffs_staging;

-- The duplicate vales is deleted
DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- 2. Standardizing the data
 
 -- Trim the data
SELECT company, TRIM(company) 
FROM layoffs_staging2;

-- Update the trimmed data
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Update every row that contain Cryptocurrency in the industry column to Crypto as majority is Crypto
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Everything looks good except apparently we have some "United States" and some "United States." with a period at the end.
-- To trim the country column 
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

-- Update the trimmed country
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- To fix the date column to date datatype.
SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

-- Update the date column
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. Removing NUll Values and empty rows.

-- There are some nulls and empty rows in the industry column.
SELECT * 
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'airbnb%';

-- Checking through the industry with null values or empty rows, it shows that airbnb falls under travel in the industry 
-- column,but it is not populated, likwewise others.
-- To solve this, write a query that if there is another row with the same company name, 
-- it will update it to the non-null industry values.

-- First set the blanks to nulls since those are typically easier to work with
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Now checking through all those that are null
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- Using self join to populate them
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.company IS NOT NULL;

-- Updating the populated value
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- checkig again for any null or blanks. Only Bally's interactive is the only one without a populated row to populate this null values
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- The null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. 
-- I don't think I want to change that.
-- I like having them null because it makes it easier for calculations during the EDA phase.


-- 4 Removing unnecessary rows and column
-- Deleting the rows where total_laid_off and percentage_laid_off is null
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- The row_num column is no longer needed so should be removed
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;



