import numpy as np
from datetime import datetime
import pandas as pd

def update_UTV_swipes(UTV, swipes, scale):
    """Updates the user taste vector based on incoming swipes.

    Args:
        UTV (pd.DataFrame): User Taste Vector for the current user
        swipes (dictionary): dish : Swipe (int) Incoming swipes for recommendation engine
    
    Returns:
        a pandas dataframe with dishs as index and a single column 'taste' with the taste vector
    """

    #scale down current UTV
    UTV['taste'] = UTV['taste'] * scale

    #add in swipes
    for dish_name, swipe in swipes.items():
        UTV.at[dish_name, 'taste'] += swipe
    
    #normalize the UTV
    np.arctan(UTV['taste'])

    return UTV

def update_UTV_recs(UTV, recs):
    """Updates the user taste vector based on reactions to recommendations.
    Args:
        UTV (pd.DataFrame): User Taste Vector for the current user
        rec (list of dictionaries): Reactions to recommendations
    
    Returns:
        a pandas dataframe with dishs as index and a single column 'taste' with the taste vector
    """

    #update current UTV based on reactions
    for rec in recs:
        UTV.at[rec['dish'], 'taste'] += rec['swiped']
    
    #normalize the UTV
    np.arctan(UTV['taste'])

    return UTV
