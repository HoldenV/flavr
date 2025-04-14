IF we ever add dishes, we need to update utv.py to have the dish in its `dishes` array
And RE-RUN DM_prebaker.py to get a NEW dish_metadata.csv and REPLACE the old one

-- Test the Content Recommendation Engine (CRE) --
    cd backend
    python cre.py data/dish_metadata.csv data/survey_responses.csv data/user_taste_vector.csv

Abbreviations used:
    CRE - Content Recommendation Engine
    CBE - Content-Based Engine
    UBE - User-Based Engine
    UTV - User Taste Vector
    DM  - Dish Metadata
    UM  - User matrix (stacked UTVs)


~~~ FRONTEND ~~~
We need to discuss how we're storing USER TASTE HISTORIES and OTHER RELEVANT DATA
Then we need to be passed the CURRENT USERS SWIPES into cre.py
cre.py will spit out a list of ALL DISHES RANKED so long as it has ALL THE DATA
