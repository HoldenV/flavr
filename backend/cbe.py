import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate("firebase_key.json")
app = firebase_admin.initialize_app(cred)

store = firestore.client()
dishes = store.collection("dishes")
dish_similarity = store.collection("dish_similarity")

input("WARNING! Will upload to Firebase Firestore. If you don't want to, hit Ctrl+C to exit now. Otherwise, press Enter to continue.")

query = dishes.stream()

for dish in query:
    for dish2 in query:
        if dish.id != dish2.id:
            # Get the dish and dish2 documents
            dish_data = dish.to_dict()
            dish2_data = dish2.to_dict()

            # Calculate the similarity score 
            #TODO: Implement a more sophisticated similarity algorithm
            similarity_score = 0
            for ingredient in dish_data["ingredients"]:
                if ingredient in dish2_data["ingredients"]:
                    similarity_score += 1

            # Store the similarity score in Firestore
            similarity_doc = {
                "dish1": dish.id,
                "dish2": dish2.id,
                "similarity_score": similarity_score
            }


            dish_similarity.document(f"{dish.id}_{dish2.id}").set(similarity_doc)