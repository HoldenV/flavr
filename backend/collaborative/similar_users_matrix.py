import pandas as pd
import json

def make_similar_users_matrix(json_name, download=False):
    # support "file_name" and "file_name.json"
    if json_name[-5:] != ".json":
        json_name += ".json"

    # load data, survey_responses.json could be loaded dynamically from firestore
    with open(json_name) as f:
        json_data = json.load(f)
        
    df = pd.DataFrame(json_data)
    df.columns = df.columns.str.lower()
    df.set_index('user_number', inplace=True)

    # do some pandas magic, convert "Looks good" to 1, "" to 0, and "Doesn't look good" to -1
    df.replace({"Looks good": 1, "": 0, "Doesn't look good": -1}, inplace=True)

    return df

def main():
    print(make_similar_users_matrix("survey_responses.json"))

if __name__ == "__main__":
    main()