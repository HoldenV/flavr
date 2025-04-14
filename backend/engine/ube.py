import pandas as pd
import json

# This function needs to be fast
def ube(users_matrix, user_taste_vector, user_id = 0):
    """Get recommendations using the collaborative recommendation (user-based) algorithm.
    
    Args:
        users_matrix: a bunch of UTVs stacked on top of each other with user_number as index
        user_taste_vector: a pandas Series with the user's taste vector
    
    Returns:
        a pandas Series with the recommended dishes and their scores, normalized to [-1, 1]
    """

    # Align the user_taste_vector with the columns of similar_users_matrix
    users_matrix.loc[user_id] = user_taste_vector.squeeze()
    # print(users_matrix)

    # Calculate User Similarity using cosine similarity
    user_similarity = users_matrix @ users_matrix.T
    user_similarity_df = pd.DataFrame(user_similarity, 
                                      index=users_matrix.index, 
                                      columns=users_matrix.index)

    # find most similar users to our guy
    user_ratings = users_matrix.loc[user_id].dropna()
    similarity_scores = user_similarity_df.loc[user_id]
    similarity_scores = similarity_scores[similarity_scores > 0]
    similarity_scores = similarity_scores.sort_values(ascending=False)
    similar_users = similarity_scores.index
    recommendations_df = pd.DataFrame()

    # put those in a df
    for user in similar_users:
        user_ratings = users_matrix.loc[user].dropna()
        recommendations_df = recommendations_df._append(user_ratings)


    # average similar user's tastes to get our guy's recommendations
    recommended_dishes = recommendations_df.mean(axis=0)
    recommended_dishes = recommended_dishes.sort_values(ascending=False)
    
    # min/max normalize the recommendations
    min_val = recommended_dishes.min()
    max_val = recommended_dishes.max()
    recommended_dishes = 2* ((recommended_dishes - min_val) / (max_val - min_val)) - 1

    return recommended_dishes
