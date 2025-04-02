import pandas as pd
import os


def cbe(user_taste_vector, fake_data=False):
    if fake_data:
        script_dir = os.path.dirname(__file__)
        csv_path = os.path.join(script_dir, "dish_metadata1.csv") 
    else:
        csv_path = r"backend\content_based\dish_metadata1.csv"

    dish_matrix = pd.read_csv(csv_path)
    dish_matrix.set_index('dish name', inplace=True)

    dish_matrix = dish_matrix.loc[user_taste_vector.index]

    tastes = dish_matrix.T.dot(user_taste_vector)
    recommended_dishes = dish_matrix.dot(tastes)
    recommended_dishes.sort_values(by = "wave_rating", ascending=False, inplace=True)
    recommended_dishes['rank'] = range(1, len(recommended_dishes) + 1)
    return recommended_dishes

if __name__ == "__main__":
    user_taste_vector = pd.read_csv(r'backend/fake_data/data/user_taste_vector.csv', index_col='dish')
    cbe(user_taste_vector)