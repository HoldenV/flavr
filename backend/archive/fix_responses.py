import pandas as pd

# Load survey response 1 into a pandas DataFrame
file_path = '/home/chase/Computer_Science/EECS_582/flavr/backend/data/survey_responses_1.csv'
df = pd.read_csv(file_path)

# Make all column labels lowercase
df.columns = df.columns.str.lower()

# Replace values: 1 -> -1, 2 -> 1, NaN -> 0
df = df.replace({1: -1, 2: 1}).fillna(0)

df['user_number'] = -(df.index + 1)
# Set user_number as the index
df.set_index('user_number', inplace=True)
df.reset_index(inplace=True)


df = df.astype(int)

# Save the modified DataFrame back to a CSV file (optional)
output_path = '/home/chase/Computer_Science/EECS_582/flavr/backend/data/fixed_survey_responses.csv'
df.to_csv(output_path, index=False)