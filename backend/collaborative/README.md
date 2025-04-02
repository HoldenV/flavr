cre.py is where the magic happens

User taste vector AND survey responses (later will be all user taste vectors on FireStore) MUST be normalized to [-1, 1]
BEFORE running cbe. It NO LONGER checks for this because our data should always be [-1, 1]