import pandas as pd

def cbe(dish_matrix, user_taste_vector):
    """Get recommendations using the content-based recommendation algorithm.

    Args:
        dish_matrix: a pandas DataFrame prebaked by DM_prebaker.py
        user_taste_vector: a pandas Series with the user's taste vector
    
    Returns:
        a pandas Series with the recommended dishes and their scores, normalized to [-1, 1]
    """
    
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
