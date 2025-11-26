import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.ticker import FuncFormatter
import os
os.makedirs('visualizations',exist_ok=True)

# Global settings for better visualization
plt.style.use('default')
pd.set_option("display.max_columns", None)
pd.set_option("display.float_format", lambda x: f"{x:,.2f}")

# Custom number formatter for better readability
def format_large_numbers(x, pos):
    if x >= 1e9:
        return f'{x*1e-9:.1f}B'
    elif x >= 1e6:
        return f'{x*1e-6:.1f}M'
    elif x >= 1e3:
        return f'{x*1e-3:.1f}K'
    else:
        return f'{x:.0f}'

number_formatter = FuncFormatter(format_large_numbers)

print("COVID-19 DATA ANALYSIS PROJECT")
print("=" * 50)

# Load dataset
df = pd.read_csv("covid_cleaned.csv")

print("Data loaded successfully")
print(f"Dataset size: {df.shape[0]} rows, {df.shape[1]} columns")

# Basic dataset information
print("\n" + "="*50)
print("DATASET OVERVIEW")
print("="*50)
print(f"Time period: {df['Date'].min()} to {df['Date'].max()}")
print(f"Number of countries: {df['location'].nunique()}")
print(f"Number of continents: {df['continent'].nunique()}")

print("\nColumn data types:")
print(df.dtypes.value_counts())

print("\nStatistical summary:")
numeric_summary = df.describe()
print(numeric_summary.loc[['mean', 'std', 'min', '50%', 'max']].T)

# Date processing
df["Date"] = pd.to_datetime(df["Date"], errors='coerce')

# Create time-based features for analysis
df["year"] = df["Date"].dt.year
df["month"] = df["Date"].dt.month
df["year_month"] = df["Date"].dt.to_period("M").astype(str)

# Check for missing data
print("\n" + "="*50)
print("DATA QUALITY CHECK")
print("="*50)
missing_data = df.isnull().sum().reset_index()
missing_data.columns = ['Column', 'Missing_Values']
missing_data['Missing_Percentage'] = (missing_data['Missing_Values'] / len(df) * 100).round(2)
missing_data = missing_data[missing_data['Missing_Values'] > 0].sort_values('Missing_Percentage', ascending=False)

if len(missing_data) > 0:
    print("Columns with missing values found:")
    print(missing_data)
else:
    print("No missing values in the dataset")

# Continent-level analysis
print("\n" + "="*50)
print("CONTINENT LEVEL ANALYSIS")
print("="*50)

continent_analysis = df.groupby('continent').agg({
    'new_cases': 'sum',
    'new_deaths': 'sum',
    'location': 'nunique',
    'population': 'mean'
}).round(2)

continent_analysis = continent_analysis.sort_values('new_cases', ascending=False)
print(continent_analysis)

# Global trends visualization

# Monthly global trends
monthly_data = df.groupby('year_month')[['new_cases', 'new_deaths']].sum()

# Create two charts for cases and deaths
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 8))

# Cases trend chart
ax1.plot(monthly_data.index, monthly_data['new_cases'], 
         linewidth=2, marker='o', markersize=3, color='blue')
ax1.set_title('Monthly New Cases Trend - Global', fontsize=14, fontweight='bold')
ax1.set_ylabel('New Cases', fontweight='bold')
ax1.yaxis.set_major_formatter(number_formatter)
ax1.grid(True, alpha=0.3)
ax1.tick_params(axis='x', rotation=45)

# Mark the peak month
peak_month = monthly_data['new_cases'].idxmax()
peak_value = monthly_data['new_cases'].max()
ax1.annotate(f'Highest: {format_large_numbers(peak_value, None)}', 
             xy=(peak_month, peak_value),
             xytext=(10, 10), textcoords='offset points',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='yellow', alpha=0.7),
             fontweight='bold')

# Deaths trend chart
ax2.plot(monthly_data.index, monthly_data['new_deaths'], 
         linewidth=2, marker='s', markersize=3, color='red')
ax2.set_title('Monthly New Deaths Trend - Global', fontsize=14, fontweight='bold')
ax2.set_ylabel('New Deaths', fontweight='bold')
ax2.set_xlabel('Time Period (Year-Month)', fontweight='bold')
ax2.yaxis.set_major_formatter(number_formatter)
ax2.grid(True, alpha=0.3)
ax2.tick_params(axis='x', rotation=45)

plt.tight_layout()
plt.savefig('visualizations/global_trends.png',dpi=300,bbox_inches='tight')
plt.show()

# Continent-wise trends
continent_monthly = df.groupby(['continent', 'year_month'])['new_cases'].sum().reset_index()

plt.figure(figsize=(14, 7))
for continent in continent_monthly['continent'].unique():
    continent_data = continent_monthly[continent_monthly['continent'] == continent]
    plt.plot(continent_data['year_month'], continent_data['new_cases'], 
             linewidth=2, marker='o', markersize=3, label=continent)

plt.title('COVID Cases Trend by Continent', fontsize=16, fontweight='bold')
plt.xlabel('Time Period', fontweight='bold')
plt.ylabel('New Cases', fontweight='bold')
plt.xticks(rotation=45)
plt.gca().yaxis.set_major_formatter(number_formatter)
plt.grid(True, alpha=0.3)
plt.legend(title='Continent')
plt.tight_layout()
plt.savefig('visualizations/continent_trend.png',dpi=300,bbox_inches='tight')
plt.show()

# Country performance analysis
print("\n" + "="*50)
print("COUNTRY PERFORMANCE RANKING")
print("="*50)

top_countries_cases = df.groupby('location')['total_cases'].max().nlargest(10)
top_countries_deaths = df.groupby('location')['total_deaths'].max().nlargest(10)

print("Top 10 countries by total cases:")
for i, (country, cases) in enumerate(top_countries_cases.items(), 1):
    print(f"{i:2d}. {country:<20} {cases:>12,}")

print("\nTop 10 countries by total deaths:")
for i, (country, deaths) in enumerate(top_countries_deaths.items(), 1):
    print(f"{i:2d}. {country:<20} {deaths:>12,}")

# Creating comparison charts
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 8))

# Cases by country
ax1.barh(range(len(top_countries_cases)), top_countries_cases.values, color='lightblue', alpha=0.8)
ax1.set_yticks(range(len(top_countries_cases)))
ax1.set_yticklabels(top_countries_cases.index)
ax1.set_title('Top 10 Countries - Total Cases', fontsize=14, fontweight='bold')
ax1.xaxis.set_major_formatter(number_formatter)
ax1.grid(axis='x', alpha=0.3)

# Adding value labels
for i, (country, value) in enumerate(top_countries_cases.items()):
    ax1.text(value + value*0.01, i, f'{value:,.0f}', 
             va='center', fontweight='bold', fontsize=9)

# Deaths by country
ax2.barh(range(len(top_countries_deaths)), top_countries_deaths.values, color='lightcoral', alpha=0.8)
ax2.set_yticks(range(len(top_countries_deaths)))
ax2.set_yticklabels(top_countries_deaths.index)
ax2.set_title('Top 10 Countries - Total Deaths', fontsize=14, fontweight='bold')
ax2.xaxis.set_major_formatter(number_formatter)
ax2.grid(axis='x', alpha=0.3)

# Add value labels
for i, (country, value) in enumerate(top_countries_deaths.items()):
    ax2.text(value + value*0.01, i, f'{value:,.0f}', 
             va='center', fontweight='bold', fontsize=9)

plt.tight_layout()
plt.savefig('visualizations/top_countries.png',dpi=300,bbox_inches='tight')
plt.show()

# Correlation analysis
print("\n" + "="*50)
print("VARIABLE CORRELATION ANALYSIS")
print("="*50)

analysis_columns = [
    'new_cases', 'new_deaths', 'total_cases', 'total_deaths',
    'population', 'gdp_per_capita', 'life_expectancy', 'population_density'
]

# Use only columns that exist in the dataset
available_columns = [col for col in analysis_columns if col in df.columns]

if len(available_columns) > 1:
    correlation_matrix = df[available_columns].corr()
    
    plt.figure(figsize=(10, 8))
    mask = np.triu(np.ones_like(correlation_matrix, dtype=bool))
    
    sns.heatmap(correlation_matrix, mask=mask, annot=True, cmap='coolwarm', center=0,
                fmt='.2f', square=True, cbar_kws={'shrink': 0.8})
    
    plt.title('Correlation Between COVID Metrics', fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig('visualizations/correlation_heatmap.png',dpi=300,bbox_inches='tight')
    plt.show()
    
    # Show strongest relationships
    print("Key correlations found:")
    correlations = correlation_matrix.unstack().sort_values(key=abs, ascending=False)
    correlations = correlations[correlations != 1.0].head(8)
    for pair, value in correlations.items():
        print(f"  {pair[0]} vs {pair[1]}: {value:.3f}")

# Data distribution analysis
plt.figure(figsize=(12, 5))

plt.subplot(1, 2, 1)
plt.hist(df['new_cases'].dropna(), bins=50, color='blue', alpha=0.7, edgecolor='black')
plt.title('Daily New Cases Distribution', fontweight='bold')
plt.xlabel('New Cases')
plt.ylabel('Frequency')
plt.yscale('log')

plt.subplot(1, 2, 2)
df_boxplot = df[df['new_cases_per_million'].notna()]
plt.boxplot([df_boxplot[df_boxplot['continent'] == cont]['new_cases_per_million'].dropna() 
             for cont in df_boxplot['continent'].unique()], 
            labels=df_boxplot['continent'].unique())
plt.title('Cases per Million by Continent', fontweight='bold')
plt.xticks(rotation=45)
plt.ylabel('Cases per Million')

plt.tight_layout()
plt.savefig('visualizations/data_distribution.png',dpi=300,bbox_inches='tight')
plt.show()

# Metrics calculation
print("\n" + "="*50)
print("METRICS CALCULATION")
print("="*50)

# Calculate fatality rates by continent
for continent in df['continent'].unique():
    continent_data = df[df['continent'] == continent]
    total_cases_cont = continent_data['new_cases'].sum()
    total_deaths_cont = continent_data['new_deaths'].sum()
    
    if total_cases_cont > 0:
        fatality_rate = (total_deaths_cont / total_cases_cont) * 100
        print(f"{continent:<15} Fatality Rate: {fatality_rate:.2f}%")

# Calculate overall metrics
total_global_cases = df['new_cases'].sum()
total_global_deaths = df['new_deaths'].sum()
global_fatality_rate = (total_global_deaths / total_global_cases * 100) if total_global_cases > 0 else 0

# Final summary
print("\n" + "="*50)
print("PROJECT SUMMARY AND INSIGHTS")
print("="*50)
print(f"Total cases analyzed: {total_global_cases:>15,}")
print(f"Total deaths recorded: {total_global_deaths:>15,}")
print(f"Global fatality rate: {global_fatality_rate:>16.2f}%")
print(f"Countries in analysis: {df['location'].nunique():>14}")
print(f"Analysis time period: {df['year'].min():>4} - {df['year'].max()}")

print("\n" + "="*50)
print("TECHNICAL SKILLS DEMONSTRATED")
print("="*50)
print("✓ Data Cleaning with Power Query")
print("✓ Exploratory Data Analysis (EDA)")
print("✓ Data Visualization with Python")
print("✓ Statistical Analysis")
print("✓ Time Series Analysis") 
print("✓ Business Insights Generation")

print("\nProject completed successfully!")

