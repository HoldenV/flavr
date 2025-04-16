from engine import cbe, ube, utv
import argparse
import pandas as pd
import random

def UM_from_csv(csv_name):
    # support "file_name" and "file_name.csv"
    if csv_name[-4:] != ".csv":
        csv_name += ".csv"

    # load data, survey_responses.csv could be loaded dynamically from firestore
    df = pd.read_csv(csv_name)
    df.set_index('user_number', inplace=True)

    return df # users_matrix -- user taste vectors stacked on each other

def UTV_from_csv(csv_name):
    # support "file_name" and "file_name.csv"
    if csv_name[-4:] != ".csv":
        csv_name += ".csv"

    df = pd.read_csv(csv_name)
    df.set_index('dish', inplace=True)
    return df # user taste vector for the current user

def DM_from_csv(csv_path):
    if csv_path[-4:] != ".csv":
        csv_path += ".csv"

    dish_matrix = pd.read_csv(csv_path)    
    dish_matrix.set_index('dish', inplace=True)
    
    return dish_matrix

def cre(DM, UM, UTV, swipes, scale = .8):
    """Run the combined content recommendation engine.

    Args:
        DM (pd.DataFrame): Dish metadata (pre-baked by DM_prebaker.py).
        UM (pd.DataFrame): User matrix (stacked user taste vectors from Firestore).
        UTV (pd.DataFrame): User Taste Vector for the current user
        swipes (list of tuples): Swipe history for the current user.

    Returns:
        pd.Series: Recommended dishes and their scores, normalized to [-1, 1].
    """
    # Get the user taste vector
    UTV = utv.update_UTV_swipes(UTV, swipes, scale)

    # Get recommendations
    cbe_recs = cbe.cbe(DM, UTV)
    ube_recs = ube.ube(UM, UTV)

    # Combine recommendations from CBE and UBE
    combined_recs = pd.concat([cbe_recs, ube_recs], axis=1)
    combined_recs.columns = ['CBE', 'UBE']
    combined_recs = combined_recs.mean(axis=1)
    combined_recs = combined_recs.sort_values(ascending=False)
    
    # Save to output file if specified
    return combined_recs, UTV
    

def init_UTV():
    """Initialize the user taste vector for the current user."""
    # Load dish metadata
    DM = DM_from_csv("data/dish_metadata.csv")

    # Initialize UTV with zeros
    UTV = pd.DataFrame(0, index=DM.index, columns=['taste'])

    #Randomly select 25 dishes to ask the user to swipe left(l) or right(r) on
    for i in range(25):
        dish = DM.sample(1)
        print(f"Do you like {dish.index[0]}? (l/r)")
        response = input()
        if response == 'r':
            UTV.at[dish.index[0], 'taste'] += 1
        elif response == 'l':
            UTV.at[dish.index[0], 'taste'] += -1
        else:
            print("Invalid response, please enter l or r")
            i -= 1

    for scale in [.5, .65, .8]:
        # Save the initial user taste vector
        UTV.to_csv(f"data/UTV_{scale}.csv")


def get_swipes():
    DM = DM_from_csv("data/dish_metadata.csv")
    swipes = {}

    num_dishes = random.randint(5, 8)
    for i in range(num_dishes):
        dish = DM.sample(1)
        print(f"Do you like {dish.index[0]}? (l/r)")
        response = input()
        if response == 'r':
            swipes[dish.index[0]] = 1
        elif response == 'l':
            swipes[dish.index[0]] = -1
        else:
            print("Invalid response, please enter l or r")
            i -= 1

    return swipes


if __name__ == "__main__":
    # parse args if run from cmdline
    parser = argparse.ArgumentParser(description="Run the collaborative recommendation engine.")
    parser.add_argument("--start", action="store_true", help="Optional flag to initialize the user taste vector")

    args = parser.parse_args()

    if args.start:
        init_UTV()

    else:
        swipes = get_swipes()


    # Load the dish matrix, user matrix, and swipe history
    DM = DM_from_csv("data/dish_metadata.csv")
    UM = UM_from_csv("data/survey_responses.csv")

    for scale in [.5, .65, .8]:
        UTV = UTV_from_csv(f"data/UTV_{scale}.csv")

        recs, UTV =cre(DM, UM, UTV, swipes, scale)

        # Save the updated user taste vector
        UTV.to_csv(f"data/UTV_{scale}.csv")


        print(f"\n========== {scale} Recommendations==========\n")
        print(recs)

