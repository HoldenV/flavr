IF YOU ADD A DISH:
    re-run dish_matrix_builder.py with the new dishes.json in the same dir
        * we need to make dishes.json automatically re-download from firestore for future
    
Test stuff:
    run make_fake_data.py and enter in your swipes, then see the output



! ! ! FRONTEND ! ! !
The only thing the FRONTEND needs to run is cbe.py, you need to import it and run it with the USER TASTE VECTOR

I guess if you need to GENERATE the USER TASTE VECTOR you will need to run user_taste_vector.py
    - Send in the historical swipe data and current swipes of the user to get_user_taste_vector()