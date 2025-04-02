import pandas as pd


def cbe(user_taste_vector, fake_data=False):
    if fake_data:
        dish_matrix = pd.read_csv('../dish_metadata1.csv')
    else:
        dish_matrix = pd.read_csv('dish_metadata1.csv')
    dish_matrix.set_index('dish name', inplace=True)

    dish_matrix = dish_matrix.loc[user_taste_vector.index]

    tastes = dish_matrix.T.dot(user_taste_vector)
    rankings = dish_matrix.dot(tastes)
    rankings = rankings.squeeze()
    print(rankings.sort_values(ascending=False))

if __name__ == "__main__":
    user_taste_vector = pd.read_csv('fake_data/data/user_taste_vector.csv', index_col='dish')
    cbe(user_taste_vector)