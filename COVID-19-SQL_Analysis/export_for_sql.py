import pandas as pd


# CSV load karo
df = pd.read_csv('covid_cleaned.csv')

# Date format fix
df['Date'] = pd.to_datetime(df['Date']).dt.strftime('%Y-%m-%d')


# New CSV save for sql
df.to_csv('COVID-19-SQL_Analysis/covid_pgadmin_ready.csv', index=False)

