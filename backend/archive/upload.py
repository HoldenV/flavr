import firebase_admin
from firebase_admin import credentials, firestore
import json

cred = credentials.Certificate("firebase_key.json")
app = firebase_admin.initialize_app(cred)

store = firestore.client()
dishes = store.collection("dishes")

input("WARNING! Will upload to Firebase Firestore. If you don't want to, hit Ctrl+C to exit now. Otherwise, press Enter to continue.")

with open("dishes.json", "r") as file:
    data = json.load(file)

    for dish in data:
        dish_name = dish["dish"]
        
        # add the dish and label the document with the dish
        dishes.document(dish_name).set(dish)
        print(f"Uploaded {dish_name}")