import pandas as pd
import os

def load_dish_metadata(csv_path):
    if csv_path[-4:] != ".csv":
        csv_path += ".csv"

    dish_matrix = pd.read_csv(csv_path)    
    dish_matrix.set_index('dish name', inplace=True)
    
    return dish_matrix

def cbe(dish_matrix, user_taste_vector):
    # Align the user_taste_vector with the columns of dish_matrix
    dish_matrix = dish_matrix.loc[user_taste_vector.index]

    # Calculate dish similarity using cosine similarity
    tastes = dish_matrix.T.dot(user_taste_vector)
    recommended_dishes = dish_matrix.dot(tastes)
    recommended_dishes.sort_values(ascending=False, inplace=True)

    # min/max normalize the recommendations
    min_val = recommended_dishes.min()
    max_val = recommended_dishes.max()
    recommended_dishes = 2* ((recommended_dishes - min_val) / (max_val - min_val)) - 1

    return recommended_dishes
