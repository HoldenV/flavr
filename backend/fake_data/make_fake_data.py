import random
from datetime import datetime, timedelta
import pickle
import os

all_dishes = ['pizza', 'flatbread pizza', 'burrito', 'steak', 'mac and cheese', 'chicken tikka masala', "general tso's chicken", 'chili', 'lasagna', 'pasta carbonara', 'fettuccine alfredo', 'calzone', 'gnocchi', 'saltimbocca', 'coq au vin', 'bouillabaisse', 'duck confit', 'cassoulet', 'quiche lorraine', 'sole meunière', 'tartiflette', 'street tacos', 'mole poblano', 'enchiladas', 'pozole', 'tamales', 'cochinita pibil', 'birria', 'carne asada', 'sushi', 'ramen', 'shrimp tempura', 'tonkatsu', 'yakitori', 'udon', 'okonomiyaki', 'shabu-shabu', 'donburi', 'shawarma', 'kofta', 'tabbouleh', 'shakshuka', 'falafel', 'mansaf', 'kibbeh', 'moussaka', 'souvlaki', 'dolma (stuffed grapeleaves)', 'spanakopita', 'gyros', 'stifado', 'fasolada', 'kleftiko', 'peking duck', 'kung pao chicken', 'mapo tofu', 'sweet and sour pork', 'hot pot', 'chow mein', 'zongzi', 'beef and broccoli', 'char siu', 'butter chicken', 'biryani', 'rogan josh', 'paneer tikka', 'chana masala', 'tandoori chicken', 'vindaloo', 'pad thai', 'green curry', 'massaman curry', 'khao soi', 'larb', 'tom kha gai', 'paella', 'tortilla española', 'fabada', 'cochinillo', 'bacalao a la vizcaína', 'bibimbap', 'kimchi jjigae', 'bulgogi', 'samgyeopsal', 'sundubu jjigae', 'galbi', 'naengmyeon', 'dakgalbi', "shepard's pie", 'fish and chips', 'poke', 'huli huli', 'fajita', 'quesadilla', 'bbq ribs', 'buffalo wings', 'pot roast', 'jambalaya', 'alaskan salmon', 'fried chicken', 'chicken pot pie', 'chicken nuggets or tenders', 'po boy', 'cobb salad', 'caesar salad', 'italian salad', 'taco salad', 'greek salad', 'fattoush', 'wedge salad', 'pasta salad', 'reuben sandwich', 'club sandwich', 'philly cheese steak', 'fried chicken sandwich', 'pulled pork sandwich', 'panini/grilled cheese w/ tomato soup', 'blt', 'french dip', 'italian sandwich', 'sloppy joe', 'meatball sub', 'chicken noodle soup', 'pho', 'minestrone', 'french onion soup', 'clam chowder', 'cream of mushroom soup', 'lentil soup', 'broccoli and cheddar soup', 'tortilla soup']

num_weeks = 5
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
