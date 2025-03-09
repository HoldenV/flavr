import pandas as pd


def cbe(user_taste_vector):
    dish_matrix = pd.read_csv('dish_metadata.csv')
    dish_matrix.set_index('dish name', inplace=True)

    dish_matrix = dish_matrix.loc[user_taste_vector.index]

    tastes = dish_matrix.T.dot(user_taste_vector)
    rankings = dish_matrix.dot(tastes)
    print(rankings)

