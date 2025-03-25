-- SQL DATA CEANING PROJECT

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank values
-- 4. Remove any columns



SELECT * FROM layoffs; 

CREATE TABLE layoff_staging 
LIKE layoffs;

SELECT * FROM layoff_staging; 

-- CREATING AND INSERTING VALUES INTO SECONDARY TABLE SAME AS ORIGINAL FOR DATA CLEANING 

INSERT layoff_staging
SELECT *  
FROM layoffs;

-- IDENTIFYING AND REMOVING DUPLICATES

SELECT *, ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised) as row_num
FROM layoff_staging;

WITH duplicates_ctes as (
SELECT *, ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised) as row_num
FROM layoff_staging
)
SELECT * FROM duplicates_ctes
where row_num > 1;
 
 -- WE CAN'T USE DELETE FUNCTION IN CTE, SO CREATING A SAME TABLE FOR DROPING DUPLICATEs
 
CREATE TABLE `layoff_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` double DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from layoff_staging2;

INSERT INTO layoff_staging2
SELECT *, ROW_NUMBER() OVER(
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised) as row_num
FROM layoff_staging;
 
 DELETE 
 FROM layoff_staging2 
 WHERE row_num > 1;
 
 SELECT*
 FROM layoff_staging2;
 
 -- STANDARDIZING DATA
  
  SELECT DISTINCT(trim(company)),company
  FROM layoff_staging2;
  
  UPDATE layoff_staging2
  SET company = trim(company);
  
  SELECT *
  FROM layoff_staging2;
  
  -- REPLACING SPECIAL CHARACTERS FROM DATA
  
  SELECT 
    REPLACE(REPLACE(REPLACE(SUBSTRING_INDEX(location, ',', 1), '[', ''), ']', ''), "'", '') AS locations
FROM layoff_staging2;

  
UPDATE layoff_staging2 
SET 
    location = REPLACE(REPLACE(REPLACE(SUBSTRING_INDEX(location, ',', 1),
                '[',
                ''),
            ']',
            ''),
        '\'',
        '');
  
  
  SELECT DISTINCT
    country
FROM
    layoff_staging2;

-- EXTRACTING DATE FROM THE DATA

SELECT LEFT(`date`, 10) AS extracted_date
FROM layoff_staging2;

UPDATE layoff_staging2
SET `date` = LEFT(`date`, 10);

-- CHANGING DATATYPE OF DATE FROM TEXT TO DATE

ALTER TABLE layoff_staging2
MODIFY COLUMN `date` DATE;


-- DEALING WITH NULL VALUES AND BLANK VALUES
  
  
  SELECT * FROM layoff_staging2
  WHERE industry IS NULL 
  OR industry = '';
  
  SELECT * FROM layoff_staging2
  WHERE company = 'Appsmith';
  
  -- i manually searched online for appsmith's industry it shows appsmith as an IT company 
  
UPDATE layoff_staging2
SET industry = 'IT'
WHERE company = 'Appsmith';

-- DROPPING row_num BECAUSE IT WAS MADE FOR  CALCULATION

ALTER TABLE layoff_staging2
DROP COLUMN	row_num;
  
  
SELECT * FROM layoff_staging2; 