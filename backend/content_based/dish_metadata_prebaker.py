import numpy as np
import pandas as pd
import json
from sklearn.preprocessing import MultiLabelBinarizer

### THIS WHOLE SCRIPT IS FOR PREBAKING DISH_METADATA.CSV ###

# Read JSON data into a pandas DataFrame
try:
    with open('dishes.json') as f:
        json_data = json.load(f)
except FileNotFoundError:
    print("dishes.json not found. Download it from Firebase and place it in the same directory as this script.")
    exit()

df = pd.DataFrame(json_data)
df.set_index('dish name', inplace=True)

# define weights, these are arbitrary and can be added to or changed
weights = {
    'cuisine': 15,

    'key ingredients': 20,
    'sub category': 5,
    
    'spiciness': 15,
    
    'seasonality': 1.875,
    'temperature': 5.625,

    'texture': 6,
    'crunchiness': 4,
    
    'color dominance': 5,
    'ingredient visibility': 5,
    
    'perceived heaviness': 6.25,
    'perceived healthiness': 6.25,
    
    'eating method': 5,

    'allergens/diet stuff': 0
}

sum_weights = round(sum(weights.values()), 3)
for key, weight in weights.items():
    weights[key] = round(weight / sum_weights, 6)

df.drop(columns=['description'], inplace=True)
df.drop(columns=['allergens/diet stuff'], inplace=True)
df["cuisine"] = df["cuisine"].apply(lambda x: x.split(", ") if isinstance(x, str) else [])
df["temperature"] = df["temperature"].apply(lambda x: x.split(" or ") if isinstance(x, str) else [])


#One hot encoding
list_columns = ['key ingredients', 'color dominance','cuisine', 'temperature'] # 'allergens/diet stuff'
categorical_columns = ['seasonality', 'texture', 'eating method', 'sub category']
numerical_columns = ['spiciness', 'crunchiness', 'ingredient visibility', 'perceived heaviness', 'perceived healthiness']
encoded_dfs = []

for col in numerical_columns:
    # scale to 0-1 from 1-5
    weight = weights[col]
    df[col] = df[col].apply(lambda x: (x - 1) / 4)
    df[col] = round(df[col] * weight, 8)

for col in list_columns:
    # create a new column for each item in the list
    mlb = MultiLabelBinarizer()
    # remove whitespace and commas
    df[col] = df[col].apply(lambda x: [i.strip().strip(',') for i in x] if isinstance(x, list) else [])
    # one hot encode, be sure to weight the columns
    weight = weights[col]
    one_hot = pd.DataFrame(mlb.fit_transform(df[col]), columns=mlb.classes_, index=df.index)
    number_of_columns = len(one_hot.columns)
    one_hot = round(one_hot * weight / number_of_columns, 8)
    encoded_dfs.append(one_hot)

for col in categorical_columns:
    # one hot encode, be sure to weight the columns
    weight = weights[col]
    one_hot = pd.get_dummies(df[col])
    one_hot = round(one_hot * weight, 8)
    one_hot.index = df.index
    encoded_dfs.append(one_hot)

df_final = pd.concat([df] + encoded_dfs, axis=1)
df_final.drop(columns=list_columns + categorical_columns, inplace=True)


#Really silly case for grilled cheese
#also error in firebase i dont wanna fix rn
df_final.drop(columns=['sandwich, soup/stew'], inplace=True)
df_final.at['panini/grilled cheese w/ tomato soup', 'sandwich'] = weights['sub category']
df_final.at['panini/grilled cheese w/ tomato soup', 'soup/stew'] = weights['sub category']

# df_final = df_final.astype(int)

print(df_final.head())
df_final.to_csv('dish_metadata1.csv')
