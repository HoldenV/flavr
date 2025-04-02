from datetime import datetime, timedelta
import os, sys, pickle, random

# Get the parent directory
parent_dir = os.path.abspath(os.path.join(os.getcwd(), ".."))

# Add it to sys.path
sys.path.append(parent_dir)

# Import the user_taste_vector function
from user_taste_vector import get_user_taste_vector
from content_based import cbe
from collaborative import cre


all_dishes = ['pizza', 'flatbread pizza', 'burrito', 'steak', 'mac and cheese', 'chicken tikka masala', "general tso's chicken", 'chili', 'lasagna', 'pasta carbonara', 'fettuccine alfredo', 'calzone', 'gnocchi', 'saltimbocca', 'coq au vin', 'bouillabaisse', 'duck confit', 'cassoulet', 'quiche lorraine', 'sole meunière', 'tartiflette', 'street tacos', 'mole poblano', 'enchiladas', 'pozole', 'tamales', 'cochinita pibil', 'birria', 'carne asada', 'sushi', 'ramen', 'shrimp tempura', 'tonkatsu', 'yakitori', 'udon', 'okonomiyaki', 'shabu-shabu', 'donburi', 'shawarma', 'kofta', 'tabbouleh', 'shakshuka', 'falafel', 'mansaf', 'kibbeh', 'moussaka', 'souvlaki', 'dolma (stuffed grapeleaves)', 'spanakopita', 'gyros', 'stifado', 'fasolada', 'kleftiko', 'peking duck', 'kung pao chicken', 'mapo tofu', 'sweet and sour pork', 'hot pot', 'chow mein', 'zongzi', 'beef and broccoli', 'char siu', 'butter chicken', 'biryani', 'rogan josh', 'paneer tikka', 'chana masala', 'tandoori chicken', 'vindaloo', 'pad thai', 'green curry', 'massaman curry', 'khao soi', 'larb', 'tom kha gai', 'paella', 'tortilla española', 'fabada', 'cochinillo', 'bacalao a la vizcaína', 'bibimbap', 'kimchi jjigae', 'bulgogi', 'samgyeopsal', 'sundubu jjigae', 'galbi', 'naengmyeon', 'dakgalbi', "shepard's pie", 'fish and chips', 'poke', 'huli huli', 'fajita', 'quesadilla', 'bbq ribs', 'buffalo wings', 'pot roast', 'jambalaya', 'alaskan salmon', 'fried chicken', 'chicken pot pie', 'chicken nuggets or tenders', 'po boy', 'cobb salad', 'caesar salad', 'italian salad', 'taco salad', 'greek salad', 'fattoush', 'wedge salad', 'pasta salad', 'reuben sandwich', 'club sandwich', 'philly cheese steak', 'fried chicken sandwich', 'pulled pork sandwich', 'panini/grilled cheese w/ tomato soup', 'blt', 'french dip', 'italian sandwich', 'sloppy joe', 'meatball sub', 'chicken noodle soup', 'pho', 'minestrone', 'french onion soup', 'clam chowder', 'cream of mushroom soup', 'lentil soup', 'broccoli and cheddar soup', 'tortilla soup']

num_weeks = 2
print(f"First, you'll generate some swipe data, simulating the last {num_weeks} weeks of swipes.")
swipe_data = []

# First, generate some swipes
for i in range(0, num_weeks):
    # get a random selection of 4-8 dishes
    print("\nWeek", i+1)
    num_dishes = random.randint(4, 8)
    dishes = random.sample(all_dishes, num_dishes)

    swipes = []

    for dish in dishes:
        swipe = input(f"Swipe left or right on {dish} (l/r): ").lower()
        swipes.append({'dish name': dish, 'swiped': 1 if swipe == 'r' else -1})

    swipe_data.append(swipes)


# Now let's convert the swipes to history
print("\nConverting swipes to history and current swipes...")
history = []

# loop through all swipes except the most recent
for i in range(0, num_weeks-1):
    # get the time for this swipe
    time = datetime.now() - timedelta(weeks=i)

    # loop through all swipes in this week
    cur_swipes = swipe_data[i]
    for swipe in cur_swipes:
        # add a random was_recommended value, should be 0 90% of the time
        was_recommended = 1 if random.random() < .1 and swipe['swiped'] != -1 else 0            
        history.append({'dish name': swipe['dish name'], 
                        'swiped': swipe['swiped'], 
                        'was_recommended': was_recommended, 
                        'timestamp': time})

# pickle history
with open('data/history.pickle', 'wb') as f:
    pickle.dump(history, f)

# pickle the most recent swipes
with open('data/swipes.pickle', 'wb') as f:
    pickle.dump(swipe_data[num_weeks-1], f)

print("Making user taste vector from history and swipes...")
user_taste_vector = get_user_taste_vector(swipes, history)
user_taste_vector.to_csv('data/user_taste_vector.csv')

print("Running CBE...")
cbe_recs = cbe.cbe(user_taste_vector, fake_data=True)

print("Running CRE...")
cre_recs = cre.cre(user_taste_vector, fake_data=True)

# Combine recommendations based on ranking
combine_recs = cbe_recs.merge(cre_recs, on='dish name', suffixes=('_cbe', '_cre'))
combine_recs['combined_score'] = combine_recs['wave_rating_cbe'] + combine_recs['wave_rating_cre']
combine_recs['comined_rank'] = combine_recs['rank_cbe'] + combine_recs['rank_cre']
combine_recs.sort_values(by='combined_score', ascending=False, inplace=True)

print(combine_recs)