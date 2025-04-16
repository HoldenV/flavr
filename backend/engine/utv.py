import numpy as np
from datetime import datetime
import pandas as pd

# this needs to be updated if we ever add a dish
dishes = ['pizza', 'flatbread pizza', 'burrito', 'steak', 'mac and cheese', 'chicken tikka masala', "general tso's chicken", 'chili', 'lasagna', 'pasta carbonara', 'fettuccine alfredo', 'calzone', 'gnocchi', 'saltimbocca', 'coq au vin', 'bouillabaisse', 'duck confit', 'cassoulet', 'quiche lorraine', 'sole meuniere', 'tartiflette', 'street tacos', 'mole poblano', 'enchiladas', 'pozole', 'tamales', 'cochinita pibil', 'birria', 'carne asada', 'sushi', 'ramen', 'shrimp tempura', 'tonkatsu', 'yakitori', 'udon', 'okonomiyaki', 'shabu-shabu', 'donburi', 'shawarma', 'kofta', 'tabbouleh', 'shakshuka', 'falafel', 'mansaf', 'kibbeh', 'moussaka', 'souvlaki', 'dolma', 'spanakopita', 'gyros', 'stifado', 'fasolada', 'kleftiko', 'peking duck', 'kung pao chicken', 'mapo tofu', 'sweet and sour pork', 'hot pot', 'chow mein', 'zongzi', 'beef and broccoli', 'char siu', 'butter chicken', 'biryani', 'rogan josh', 'paneer tikka', 'chana masala', 'tandoori chicken', 'vindaloo', 'pad thai', 'green curry', 'massaman curry', 'khao soi', 'larb', 'tom kha gai', 'paella', 'tortilla espanola', 'fabada', 'cochinillo', 'bacalao a la vizcaína', 'bibimbap', 'kimchi jjigae', 'bulgogi', 'samgyeopsal', 'sundubu jjigae', 'galbi', 'naengmyeon', 'dakgalbi', "shepard's pie", 'fish and chips', 'poke', 'huli huli', 'fajita', 'quesadilla', 'bbq ribs', 'buffalo wings', 'pot roast', 'jambalaya', 'salmon', 'fried chicken', 'chicken pot pie', 'chicken tenders', 'po boy', 'cobb salad', 'caesar salad', 'italian salad', 'taco salad', 'greek salad', 'fattoush salad', 'wedge salad', 'pasta salad', 'reuben sandwich', 'club sandwich', 'philly cheesesteak', 'fried chicken sandwich', 'pulled pork sandwich', 'tomato soup with grilled cheese', 'blt', 'french dip', 'italian sandwich', 'sloppy joe', 'meatball sub', 'chicken noodle soup', 'pho', 'minestrone soup', 'french onion soup', 'clam chowder soup', 'cream of mushroom soup', 'lentil soup', 'broccoli and cheddar soup', 'tortilla soup']

def update_UTV_swipes(UTV, swipes):
    """Updates the user taste vector based on incoming swipes.

    Args:
        UTV (pd.DataFrame): User Taste Vector for the current user
        swipes (list of dictionaries): Incoming swipes for recommendation engine
    
    Returns:
        a pandas dataframe with dish names as index and a single column 'taste' with the taste vector
    """

    #scale down current UTV
    UTV['taste'] = UTV['taste'] *.8

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
        a pandas dataframe with dish names as index and a single column 'taste' with the taste vector
    """

    #update current UTV based on reactions
    for rec in recs:
        UTV.at[rec['dish name'], 'taste'] += rec['swiped']
    
    #normalize the UTV
    np.arctan(UTV['taste'])

    return UTV
