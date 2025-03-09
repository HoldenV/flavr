import pickle

# Load the history and current swipes
with open('data/history.pickle', 'rb') as f:
    history = pickle.load(f)
    for swipe in history:
        print(swipe)

print("\n\n")

with open('data/swipes.pickle', 'rb') as f:
    swipes = pickle.load(f)
    for swipe in swipes:
        print(swipe)