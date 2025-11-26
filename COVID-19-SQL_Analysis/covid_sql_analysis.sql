-- COVID-19 COMPREHENSIVE DATA ANALYSIS



--  DATA PROFILING AND QUALITY CHECKS


-- Dataset Overview
SELECT 
    'COVID Data Profile' as analysis_type,
    COUNT(*) as total_records,
    COUNT(DISTINCT location) as total_countries,
    MIN(date) as data_start_date,
    MAX(date) as data_end_date,
    ROUND(AVG(new_cases), 2) as avg_daily_cases,
    ROUND(AVG(new_deaths), 2) as avg_daily_deaths
FROM covid_data
WHERE continent IS NOT NULL;

-- Data Quality Validation
SELECT 
    COUNT(*) - COUNT(total_cases) as missing_total_cases,
    COUNT(*) - COUNT(new_cases) as missing_new_cases,
    COUNT(*) - COUNT(total_deaths) as missing_total_deaths,
    COUNT(*) - COUNT(new_deaths) as missing_new_deaths,
    COUNT(*) - COUNT(population) as missing_population
FROM covid_data;

-- Data Consistency Check
SELECT 
    'Cases-Deaths Consistency' as check_type,
    COUNT(*) as inconsistent_records
FROM covid_data
WHERE total_deaths > total_cases
UNION ALL
SELECT 
    'Negative Values' as check_type,
    COUNT(*) as inconsistent_records
FROM covid_data
WHERE new_cases < 0 OR new_deaths < 0;


-- GLOBAL AND CONTINENTAL OVERVIEW

-- Global Summary Statistics
SELECT 
    SUM(new_cases) as global_total_cases,
    SUM(new_deaths) as global_total_deaths,
    ROUND((SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0)), 2) as global_fatality_rate,
    AVG(population) as avg_country_population,
    COUNT(DISTINCT location) as countries_analyzed
FROM covid_data
WHERE continent IS NOT NULL;

-- Continent-wise Performance
SELECT 
    continent,
    SUM(new_cases) as total_cases,
    SUM(new_deaths) as total_deaths,
    ROUND((SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0)), 2) as fatality_rate,
    COUNT(DISTINCT location) as number_of_countries,
    ROUND(AVG(population), 2) as avg_population,
    ROUND(AVG(gdp_per_capita), 2) as avg_gdp_per_capita
FROM covid_data
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_cases DESC;


-- COUNTRY PERFORMANCE ANALYSIS

-- Top 10 Countries by Total Cases with Ranking
WITH country_totals AS (
    SELECT 
        location,
        MAX(total_cases) as max_total_cases,
        MAX(total_deaths) as max_total_deaths,
        MAX(population) as population
    FROM covid_data
    WHERE continent IS NOT NULL
    GROUP BY location
)
SELECT 
    location,
    max_total_cases as total_cases,
    max_total_deaths as total_deaths,
    ROUND((max_total_deaths * 100.0 / NULLIF(max_total_cases, 0)), 2) as fatality_rate,
    ROUND((max_total_cases * 1000000.0 / NULLIF(population, 0)), 2) as cases_per_million,
    RANK() OVER (ORDER BY max_total_cases DESC) as global_rank
FROM country_totals
ORDER BY max_total_cases DESC
LIMIT 10;

-- Country Performance Tiers
SELECT 
    CASE 
        WHEN total_cases > 1000000 THEN 'Tier 1 (>1M cases)'
        WHEN total_cases > 100000 THEN 'Tier 2 (100K-1M cases)'
        WHEN total_cases > 10000 THEN 'Tier 3 (10K-100K cases)'
        ELSE 'Tier 4 (<10K cases)'
    END as country_tier,
    COUNT(*) as countries_count,
    ROUND(AVG(fatality_rate), 2) as avg_fatality_rate,
    ROUND(AVG(cases_per_million), 2) as avg_cases_per_million
FROM (
    SELECT 
        location,
        MAX(total_cases) as total_cases,
        ROUND((MAX(total_deaths) * 100.0 / NULLIF(MAX(total_cases), 0)), 2) as fatality_rate,
        ROUND(MAX(total_cases_per_million), 2) as cases_per_million
    FROM covid_data
    WHERE continent IS NOT NULL
    GROUP BY location
) country_stats
GROUP BY country_tier
ORDER BY countries_count DESC;


-- TIME SERIES AND TREND ANALYSIS


-- Monthly Trend Analysis
SELECT 
    EXTRACT(YEAR FROM date) as year,
    EXTRACT(MONTH FROM date) as month,
    TO_CHAR(date, 'YYYY-MM') as year_month,
    SUM(new_cases) as monthly_cases,
    SUM(new_deaths) as monthly_deaths,
    ROUND(AVG(new_cases), 2) as avg_daily_cases,
    ROUND((SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0)), 2) as monthly_fatality_rate
FROM covid_data
WHERE continent IS NOT NULL
GROUP BY year, month, year_month
ORDER BY year, month;

-- Weekly Growth Rate Analysis
WITH weekly_data AS (
    SELECT 
        DATE_TRUNC('week', date) as week_start,
        SUM(new_cases) as weekly_cases,
        LAG(SUM(new_cases)) OVER (ORDER BY DATE_TRUNC('week', date)) as prev_week_cases
    FROM covid_data
    WHERE continent IS NOT NULL
    GROUP BY week_start
)
SELECT 
    week_start,
    weekly_cases,
    prev_week_cases,
    ROUND(((weekly_cases - prev_week_cases) * 100.0 / NULLIF(prev_week_cases, 0)), 2) as weekly_growth_rate,
    CASE 
        WHEN weekly_cases > prev_week_cases THEN 'Increasing'
        WHEN weekly_cases < prev_week_cases THEN 'Decreasing'
        ELSE 'Stable'
    END as trend
FROM weekly_data
ORDER BY week_start;


-- STATISTICAL AND CORRELATION ANALYSIS


-- Correlation Analysis Between Metrics
SELECT 
    CORR(population_density, total_cases_per_million) as density_cases_correlation,
    CORR(gdp_per_capita, total_cases_per_million) as gdp_cases_correlation,
    CORR(median_age, total_deaths_per_million) as age_deaths_correlation,
    CORR(hospital_beds_per_thousand, total_deaths_per_million) as beds_deaths_correlation
FROM (
    SELECT 
        location,
        AVG(population_density) as population_density,
        AVG(total_cases_per_million) as total_cases_per_million,
        AVG(gdp_per_capita) as gdp_per_capita,
        AVG(total_deaths_per_million) as total_deaths_per_million,
        AVG(median_age) as median_age,
        AVG(hospital_beds_per_thousand) as hospital_beds_per_thousand
    FROM covid_data
    WHERE continent IS NOT NULL
    GROUP BY location
) country_avgs;


-- HEALTHCARE INFRASTRUCTURE IMPACT


-- Healthcare Capacity vs COVID Outcomes
SELECT 
    CASE 
        WHEN hospital_beds_per_thousand < 2 THEN 'Low (<2 beds)'
        WHEN hospital_beds_per_thousand BETWEEN 2 AND 5 THEN 'Medium (2-5 beds)'
        ELSE 'High (>5 beds)'
    END as bed_availability,
    COUNT(DISTINCT location) as countries,
    ROUND(AVG(total_cases_per_million), 2) as avg_cases_per_million,
    ROUND(AVG(total_deaths_per_million), 2) as avg_deaths_per_million,
    ROUND(AVG((total_deaths_per_million * 100.0 / NULLIF(total_cases_per_million, 0))), 2) as avg_fatality_rate
FROM covid_data
WHERE continent IS NOT NULL 
    AND hospital_beds_per_thousand IS NOT NULL
GROUP BY bed_availability
ORDER BY avg_fatality_rate;

-- Healthcare with Fatality Rate Analysis
WITH country_stats AS (
    SELECT 
        location,
        AVG(hospital_beds_per_thousand) as beds,
        MAX(total_cases_per_million) as max_cases,
        MAX(total_deaths_per_million) as max_deaths
    FROM covid_data
    WHERE continent IS NOT NULL
    GROUP BY location
)
SELECT 
    location,
    beds as hospital_beds,
    max_cases as cases_per_million,
    max_deaths as deaths_per_million,
    ROUND((max_deaths * 100.0 / NULLIF(max_cases, 0)), 2) as fatality_rate,
    CASE 
        WHEN beds > 5 THEN 'Good Beds'
        WHEN beds BETWEEN 2 AND 5 THEN 'Medium Beds'
        WHEN beds < 2 THEN 'Low Beds'
        ELSE 'No Data'
    END as bed_status
FROM country_stats
ORDER BY beds DESC;


-- ANALYTICS WITH WINDOW FUNCTIONS


-- Running Totals and Moving Averages (for specific country)
SELECT 
    date,
    location,
    new_cases,
    SUM(new_cases) OVER (PARTITION BY location ORDER BY date) as running_total_cases,
    AVG(new_cases) OVER (
        PARTITION BY location 
        ORDER BY date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as cases_7day_avg,
    new_deaths,
    SUM(new_deaths) OVER (PARTITION BY location ORDER BY date) as running_total_deaths
FROM covid_data
WHERE location IN ('India', 'United States', 'Brazil', 'Nepal')
ORDER BY location, date;

-- Country vs Continent Performance
WITH continent_stats AS (
    SELECT 
        continent,
        location,
        MAX(total_cases) as country_cases,
        AVG(MAX(total_cases)) OVER (PARTITION BY continent) as continent_avg_cases
    FROM covid_data
    WHERE continent IS NOT NULL
    GROUP BY continent, location
)
SELECT 
    continent,
    location,
    country_cases,
    ROUND(continent_avg_cases, 2) as continent_avg,
    ROUND((country_cases * 100.0 / NULLIF(continent_avg_cases, 0)), 2) as percent_of_continent_avg,
    CASE 
        WHEN country_cases > continent_avg_cases THEN 'Above Average'
        ELSE 'Below Average'
    END as performance
FROM continent_stats
ORDER BY continent, country_cases DESC;


-- BUSINESS INTELLIGENCE AND EXECUTIVE REPORTS


-- Executive Dashboard Summary
SELECT 
    'Global' as region,
    SUM(new_cases) as total_cases,
    SUM(new_deaths) as total_deaths,
    ROUND((SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0)), 2) as fatality_rate,
    COUNT(DISTINCT location) as countries_covered
FROM covid_data
WHERE continent IS NOT NULL
UNION ALL
SELECT 
    continent as region,
    SUM(new_cases) as total_cases,
    SUM(new_deaths) as total_deaths,
    ROUND((SUM(new_deaths) * 100.0 / NULLIF(SUM(new_cases), 0)), 2) as fatality_rate,
    COUNT(DISTINCT location) as countries_covered
FROM covid_data
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_cases DESC;


-- DATA EXPORT FOR VISUALIZATION


-- Time Series Data for Charts
SELECT 
    date,
    location,
    new_cases,
    new_deaths,
    total_cases,
    total_deaths
FROM covid_data
WHERE location IN ('United States', 'India', 'Brazil', 'United Kingdom', 'Nepal')
ORDER BY location, date;

-- Geographic Heat Map Data
SELECT 
    location,
    MAX(total_cases_per_million) as cases_per_million,
    MAX(total_deaths_per_million) as deaths_per_million,
    MAX(population) as population,
    AVG(life_expectancy) as life_expectancy
FROM covid_data
WHERE continent IS NOT NULL
GROUP BY location;


-- PANDEMIC WAVE DETECTION


-- Surge Detection for Specific Country
WITH daily_avg AS (
    SELECT 
        date,
        location,
        AVG(new_cases) OVER (
            PARTITION BY location 
            ORDER BY date 
            ROWS BETWEEN 7 PRECEDING AND CURRENT ROW
        ) as cases_7day_avg
    FROM covid_data
    WHERE location = 'Nepal'
)
SELECT 
    date,
    cases_7day_avg,
    LAG(cases_7day_avg, 7) OVER (ORDER BY date) as prev_week_avg,
    CASE 
        WHEN cases_7day_avg > LAG(cases_7day_avg, 7) OVER (ORDER BY date) * 1.5 
        THEN 'Surge Detected'
        WHEN cases_7day_avg < LAG(cases_7day_avg, 7) OVER (ORDER BY date) * 0.7 
        THEN 'Decline'
        ELSE 'Stable'
    END as trend_indicator
FROM daily_avg
ORDER BY date;


-- ANALYSIS COMPLETE

SELECT 'COVID-19 Data Analysis Completed Successfully!' as project_status;

