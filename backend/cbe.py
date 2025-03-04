import numpy as np
import pandas as pd
import json
from sklearn.preprocessing import MultiLabelBinarizer


# Read JSON data into a pandas DataFrame
with open('dishes.json') as f:
    json_data = json.load(f)

df = pd.DataFrame(json_data)
df.set_index('dish name', inplace=True)


df.drop(columns=['description'], inplace=True)
df["cuisine"] = df["cuisine"].apply(lambda x: x.split(", ") if isinstance(x, str) else [])
df["temperature"] = df["temperature"].apply(lambda x: x.split(" or ") if isinstance(x, str) else [])


#One hot encoding
list_columns = ['key ingredients', 'color dominance', 'allergens/diet stuff', 'cuisine', 'temperature']
categorical_columns = ['seasonality', 'texture', 'eating method', 'sub category']
encoded_dfs = []


for col in list_columns:
    mlb = MultiLabelBinarizer()
    df[col] = df[col].apply(lambda x: [i.strip().strip(',') for i in x] if isinstance(x, list) else [])
    one_hot = pd.DataFrame(mlb.fit_transform(df[col]), columns=mlb.classes_, index=df.index)
    encoded_dfs.append(one_hot)

for col in categorical_columns:
    one_hot = pd.get_dummies(df[col])
    one_hot.index = df.index
    encoded_dfs.append(one_hot)

df_final = pd.concat([df] + encoded_dfs, axis=1)
df_final.drop(columns=list_columns + categorical_columns, inplace=True)


#Really silly case for grilled cheese
#also error in firebase i dont wanna fix rn
df_final.drop(columns=['sandwich, soup/stew'], inplace=True)
df_final.at['panini/grilled cheese w/ tomato soup', 'sandwich'] = True
df_final.at['panini/grilled cheese w/ tomato soup', 'soup/stew'] = True

df_final = df_final.astype(int)

'''
Next Steps:

I want to figure out a way to group metadata columns into their categories so that all ingredients will
have an equal weighting compared to other categories and not especially outsized because there are more
columns. 

The next step would be to weight the columns, and this is fairly arbitrary. We can do equal weighting,
or we can put stronger weight on columns we think are more important. We can also combine columns like
texture and crunchiness to be weighted together.

After we have it balanced, we will export the data to a csv or a pickled numpy array.

We could potentially use the data to train a model, or we can stick with the original idea of cosine similarity.

The next step from there would be to begin to format user swipe input and user history into an input taste
vector that can be used to compare against the dish metadata. 

This processes will output a ranking for all 131 dishes, which is pretty epic. There are a lot of options 
from there as far as setting a threshold for what is a match, or just returning the top 10 or so dishes. 
We will need to come up with a weighting method between this and the collaborative filtering method, which is
going to be a bit more complex.

'''