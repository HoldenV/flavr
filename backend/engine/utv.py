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

def update_UTV_multi_user(UTV_dict, swipes, scale):
    combined_UTV = None
    
    for user, (UTV, swipes) in UTV_dict.items():

        #scale down current UTV
        UTV['taste'] = UTV['taste'] * scale

        for dish_name, swipe in swipes.items():
            UTV.at[dish_name, 'taste'] += swipe

        #firebase update current user's UTV
        # utv_dict = UTV.to_dict()["taste"]
        # batch = db.batch()
        # for key, value in utv_dict.items():
        #     doc_ref = utv_ref.document(key)
        #     batch.set(doc_ref, {"value": value})
        # batch.commit()


        if combined_UTV is None:
            combined_UTV = UTV.copy()
        else:
            combined_UTV['taste'] += UTV['taste']
        
        #normalize the UTV
        np.arctan(combined_UTV['taste'])

    return combined_UTV

