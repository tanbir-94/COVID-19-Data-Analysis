# COVID-19 Global Data Analysis Portfolio Project

## Project Overview
End-to-end data analysis of the COVID-19 pandemic covering data cleaning, exploratory analysis, SQL analytics, and interactive dashboards. Analyzed 30M+ cases across 209 countries to derive actionable insights.

## Technologies Used

### Data Preparation & Cleaning
- Microsoft Excel & Power Query - Data transformation and cleaning
- Data Validation - Handling missing values, consistency checks

### Data Analysis & EDA  
- Python - Exploratory Data Analysis (EDA)
  - Pandas for data manipulation
  - Matplotlib & Seaborn for visualization
  - Statistical analysis and insights generation

### Database & Advanced Analytics
- PostgreSQL - Database management and advanced SQL queries
  - Complex queries with Window Functions
  - CTEs (Common Table Expressions) 
  - Statistical correlations and trend analysis

### Data Visualization & BI
- Power BI - Interactive dashboards and reports
  - Executive dashboards
  - Geographic heat maps
  - Time series analysis

## Key Findings & Results

### Python EDA Results

#### Continent Level Analysis

CONTINENT LEVEL ANALYSIS

#Continent        #new_cases   #new_deaths   #location  #population

 - Asia             9,266,760     174,364        46   110,428,255.31
 - North America   8,090,185     292,949         36    21,515,047.49
 - South America    7,419,022     231,638        13    38,167,272.17
 - Europe           4,351,958     217,145        51    16,057,419.40
 - Africa           1,391,566      33,623        55    26,813,127.26
 - Oceania             32,211         908         8     6,147,198.48



#### Country Performance Ranking

COUNTRY PERFORMANCE RANKING
==================================================
Top 10 countries by total cases:

1. United States           6,724,667
2. India                   5,308,014
3. Brazil                  4,495,183
4. Russia                  1,091,186
5. Peru                      756,412
6. Colombia                  750,471
7. Mexico                    688,954
8. South Africa              657,627
9. Spain                     640,040
10. Argentina                 601,700

Top 10 countries by total deaths:

1. United States             198,589
2. Brazil                    135,793
3. India                      85,619
4. Mexico                     72,803
5. United Kingdom             41,732
6. Italy                      35,668
7. Peru                       31,283
8. France                     31,249
9. Spain                      30,495
10. Iran                      23,952



#### Statistical Correlations


VARIABLE CORRELATION ANALYSIS
==================================================
Key correlations found:
total_cases vs total_deaths: 0.910
total_deaths vs total_cases: 0.910
new_cases vs total_cases: 0.853
total_cases vs new_cases: 0.853
total_deaths vs new_cases: 0.756
new_cases vs total_deaths: 0.756
new_deaths vs new_cases: 0.746
new_cases vs new_deaths: 0.746



####  Metrics


METRICS CALCULATION
==================================================
Europe          Fatality Rate:4.99%
Asia            Fatality Rate:1.88%
Oceania         Fatality Rate:2.82%
South America   Fatality Rate:3.12%
North America   Fatality Rate:3.62%
Africa          Fatality Rate:2.42%



### Project Summary


PROJECT SUMMARY AND INSIGHTS
==================================================
Total cases analyzed:30,551,702
Total deaths recorded:950,627
Global fatality rate:3.11%
Countries in analysis:209
Analysis time period:2019 - 2020



### Power BI Dashboard Features

#### Page 1 - Global Overview
- Total Cases: 30 Million+
- Total Deaths: 951K
- Case Fatality Rate: 3.1%
- Peak New Cases: Visualization of maximum infection periods
- Peak New Deaths: Highest mortality periods identified
- Global Time-Series Trends: Pandemic progression over time
- World Map Visualization: Geographic spread of cases

#### Page 2 - Continent Analysis
- Cases by Continent: Asia leading with 9.2M cases
- Deaths by Continent: North America highest with 292K deaths
- Population Treemap: Visual representation of population distribution
- Continent-level trends: Regional pandemic patterns
- Country drill-through: Detailed country-level analysis

## Technical Skills Demonstrated

### Power Query & Data Cleaning
- Data transformation and normalization of 43,631 records
- Handling missing values in 50%+ of healthcare metrics columns
- Creating calculated columns and measures
- Data quality validation and consistency checks

### Python Data Analysis
python
# Key Python libraries and techniques
import pandas as pd      # Data manipulation (43K+ records)
import matplotlib.pyplot as plt  # Visualization
import seaborn as sns    # Statistical visualization
import numpy as np       # Numerical computing

# Analysis performed:
- Exploratory Data Analysis (EDA)
- Statistical correlation analysis (0.91 cases-deaths correlation)
- Data visualization and chart creation
- Automated data processing scripts


SQL Advanced Analytics

sql
-- Advanced SQL techniques implemented
Window Functions: RANK(), LAG(), AVG() OVER()
CTEs (Common Table Expressions)
Statistical Functions: CORR(), STDDEV()
Date/Time analysis: DATE_TRUNC(), EXTRACT()

-- complex query executed:
WITH country_totals AS (
    SELECT location, MAX(total_cases) as max_cases,
    RANK() OVER (ORDER BY MAX(total_cases) DESC) as global_rank
    FROM covid_data GROUP BY location
)
SELECT * FROM country_totals LIMIT 10;


Power BI & Data Visualization

· Interactive dashboard creation with 2 report pages
· KPI tracking and monitoring of key metrics
· Geographic data mapping with world heat maps
· Time series analysis and trend forecasting

Business Insights Generated

Key Discoveries:

1. Strong Case-Death Correlation: 0.91 correlation between total cases and deaths
2. Continental Variations: Europe showed highest fatality rate (4.99%) despite fewer cases
3. Healthcare Impact: Clear correlation between hospital capacity and outcomes
4. Geographic Patterns: Asia had most cases but lower fatality rate than North America

Actionable Recommendations:

· Resource Allocation: Focus healthcare resources on high-fatality regions
· Prevention Strategies: Implement targeted measures in high-density population areas
· Monitoring Systems: Develop early warning systems using growth rate analysis

Project Implementation

Data Pipeline:

1. Raw Data → Power Query Cleaning → Clean Dataset
2. Clean Dataset → Python EDA → Statistical Insights
3. Statistical Insights → SQL Analysis → Business Intelligence
4. Business Intelligence → Power BI → Executive Dashboards

Files Structure:


GLOBAL COVID-19 PROJECT
├── COVID-19-SQL-Analysis/
│   ├──/screenshots →   # SQL output screenshots
|   ├── covid_pgadmin_ready.csv
|   ├── covid_sql_analysis.sql
│   └── export_for_sql.py
├── Power-BI-Dashboard/
│   ├── 1.Global_Overview.png      
│   └── 2.Continent_Analysis.png   
├── Visualizations/
|   ├── global_trends.png   # Monthly trends
│   ├── continent_trends.png # Continent lines 
|   ├── top_countries.png    # Country rankings   
│   ├── correlation_heatmap.png # Statistical correlation  
|   └── data_distribution.png  # Histogram & boxplot           
├── covid_data.csv      # Raw data 
├── covid_cleaned.csv   # Cleaned data 
├── covid_eda.py
└── README.md



Contact & Links

Md Tanbir Rja
Nepal
Email: mdtanbirraza7@gmail.com
LinkedIn: https://www.linkedin.com/in/md-tanbir-rja-067561236
GitHub:   https://github.com/tanbir-94


---

This project demonstrates comprehensive data analysis capabilities across the complete data lifecycle, from raw data acquisition to actionable business insights and executive-level visualizations.

Analysis Period: 2019-2020
Dataset:43,631 records × 31 columns
Coverage:209 countries across 6 continents
Tools:Excel, Power Query, Python, PostgreSQL, Power BI

Impact:Data-driven pandemic response recommendations


