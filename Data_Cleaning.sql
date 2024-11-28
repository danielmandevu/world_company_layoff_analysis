-- As best Practice, create another table to perform the cleaning process. Don't work on the pristine data of the organization so that if anything you shoould be able to rowback.
CREATE TABLE layoffs_stage1 
LIKE layoffs;

INSERT layoffs_stage1 
SELECT * FROM layoffs;

-- Step1 Check for Duplicate Data
-- create a stored procedure // of course not neccessary I have descovered.
DELIMITER //
CREATE PROCEDURE check_duplicates()
BEGIN
	WITH check_duplicate AS (
		SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,`date`, stage, country, funds_raised_millions) AS Row_Column
		FROM layoffs_stage1
	)
	SELECT * FROM check_duplicate
	WHERE row_column > 1;
END // 
DELIMITER ;

SELECT * FROM layoffs_stage1;

call check_duplicates();

SELECT * FROM layoffs_stage1
WHERE company = 'Hibob';


-- Create a stage2 table that will contain row_number as an ID used to remove duplicates.
CREATE TABLE `layoffs_stage2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` text,
  `row_column` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT layoffs_stage2 
	SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off,`date`, stage, country, funds_raised_millions) AS row_column
	FROM layoffs_stage1;

-- check the duplicates in this stage
SELECT * FROM layoffs_stage2
WHERE row_column > 1;

-- Delete the duplicates
DELETE FROM layoffs_stage2
WHERE row_column > 1;

-- Delete the row_number(column) as its of no use to our analysis
ALTER TABLE layoffs_stage2
DROP COLUMN row_column;

-- The data has no duplicates now.

-- Step 2 
-- Standardize the data


-- check the company column 
SELECT DISTINCT(company) FROM layoffs_stage2;

UPDATE layoffs_stage2
SET company = TRIM(company);

-- CHECK THE industry column
SELECT DISTINCT(industry) FROM layoffs_stage2 ORDER BY 1;

SELECT * FROM layoffs_stage2
WHERE industry LIKE '%Crypto%';

UPDATE layoffs_stage2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- standardize the date to a MySQL date format

SELECT DISTINCT(`date`), STR_TO_DATE(`date`,'%m/%d/%Y') FROM  layoffs_stage2; -- Date has a null values as a string
UPDATE layoffs_stage2
SET `date` = null
WHERE `date` = 'null'; 

UPDATE layoffs_stage2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

ALTER TABLE layoffs_stage2
MODIFY COLUMN `date` date;

-- check the country column 
SELECT DISTINCT(country) FROM layoffs_stage2 ORDER BY 1;

UPDATE layoffs_stage2
SET country = TRIM(TRAILING '.'FROM country);
-- STEP 2 DONE

-- STEP 3 Handle Missing Data  and NULL values
-- For Industry, make observation to check if there are different locations of a company to ID its industry
select * from layoffs_stage2
WHERE industry IS NULL or industry = '';


UPDATE layoffs_stage2
SET industry = null
WHERE industry = 'null' OR industry = '';


SELECT l1.industry, l2.industry FROM layoffs_stage2 as l1
join layoffs_stage2 as l2
on l1.company = l2.company
where l1.industry is not null AND l2.industry is null;

UPDATE layoffs_stage2 as l1
	join layoffs_stage2 as l2
	on l1.company = l2.company
SET l2.industry = l1.industry
where l1.industry is not null AND l2.industry is null;

-- set the string null values to mysql null data type. this is because I imported them as text
SELECT * FROM layoffs_stage2
where percentage_laid_off is null or  percentage_laid_off = 'null' OR total_laid_off = '';

ALTER TABLE layoffs_stage2
MODIFY funds_raised_millions int;
UPDATE layoffs_stage2
SET funds_raised_millions = NULL
where funds_raised_millions = 'null' OR funds_raised_millions = '';

-- null total_laid_off and percentage_laid_off rows are useless in this analysis so they have to be deleted
SELECT * FROM layoffs_stage2
where percentage_laid_off is null AND  total_laid_off is null;

DELETE 
FROM layoffs_stage2
WHERE percentage_laid_off is null AND  total_laid_off is null;

SELECT * FROM layoffs_stage2;




