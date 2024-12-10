-- Period of layoff start year and end year
select min(`date`), max(`date`) from layoffs_stage2;

-- total laid off
select sum(total_laid_off) from layoffs_stage2;

-- highest layoff of the day
select company,`date`, max(total_laid_off)
from layoffs_stage2 group by 1,2 order by max(total_laid_off) desc;

-- Company with most layoffs
select company,sum(total_laid_off) as total_off
from layoffs_stage2
group by 1 order by sum(total_laid_off) desc;
;

-- Industry with most layoffs
select industry,sum(total_laid_off) from layoffs_stage2
where industry is not null and total_laid_off is not null
group by industry order by 2 desc;

-- lay offs per country
select country, sum(total_laid_off) total_off from layoffs_stage2
group by country order by 2 desc;

-- rank the industry with most layoffs per year

-- lay offs per year
select year(`date`) as `year`, sum(total_laid_off) 
from layoffs_stage2
where year(`date`) is not null
group by `year`
order by 1 desc;

-- company yearly layoffs
select company, `date`, sum(total_laid_off)
from layoffs_stage2
group by company, `date`;

-- Rank company lay off per year
with company_year(company,total_off,`year`) as (
	select company, sum(total_laid_off), year(`date`)
	from layoffs_stage2
	group by company, year(`date`)
), company_year_rank as (
	select *,
	dense_rank() over(partition by `year` order by total_off  desc) as ranking
	from company_year
	where `year` is not null
    ) 
    select * from company_year_rank -- select the top 5 companys per year with most lay offs
	where ranking <= 5; 
























