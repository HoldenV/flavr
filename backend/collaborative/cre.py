import pandas as pd
from similar_users_matrix import make_similar_users_matrix

# This function needs to be fast
def cre(similar_users_matrix, user_taste_vector, user_id):
    # Align the user_taste_vector with the columns of similar_users_matrix
    similar_users_matrix.loc[user_id] = user_taste_vector.squeeze()

    # Calculate User Similarity using cosine similarity
    user_similarity = similar_users_matrix @ similar_users_matrix.T
    user_similarity_df = pd.DataFrame(user_similarity, 
                                      index=similar_users_matrix.index, 
                                      columns=similar_users_matrix.index)

    # find most similar users to our guy
    user_ratings = similar_users_matrix.loc[user_id].dropna()
    similarity_scores = user_similarity_df.loc[user_id]
    similarity_scores = similarity_scores[similarity_scores > 0]
    similarity_scores = similarity_scores.sort_values(ascending=False)
    similar_users = similarity_scores.index
    recommendations_df = pd.DataFrame()

    # put those in a df
    for user in similar_users:
        user_ratings = similar_users_matrix.loc[user].dropna()
        recommendations_df = recommendations_df._append(user_ratings)

    # average similar user's tastes to get our guy's recommendations
    recommended_dishes = recommendations_df.mean(axis=0)
    recommended_dishes = recommended_dishes.sort_values(ascending=False) 

    return recommended_dishes


def main():
    # load pre-made data
    SMU = make_similar_users_matrix("survey_responses.json")
    SMU = SMU.drop(columns=['timestamp'])
    UTV = pd.read_csv('user_taste_vector.csv', index_col='dish')

    # print result of CRE
    print(cre(SMU, UTV, 0))


if __name__ == "__main__":
    main()