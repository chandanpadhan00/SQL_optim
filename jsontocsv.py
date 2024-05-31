import pandas as pd
import json

# Function to flatten nested JSON
def flatten_json(y):
    out = {}

    def flatten(x, name=''):
        if type(x) is dict:
            for a in x:
                flatten(x[a], name + a + '_')
        elif type(x) is list:
            i = 0
            for a in x:
                flatten(a, name + str(i) + '_')
                i += 1
        else:
            out[name[:-1]] = x

    flatten(y)
    return out

# Read JSON file
with open('input.json', 'r') as f:
    data = json.load(f)

# If the JSON data is an array of objects, flatten each object
if isinstance(data, list):
    flat_data = [flatten_json(record) for record in data]
else:
    flat_data = [flatten_json(data)]

# Convert to DataFrame
df = pd.DataFrame(flat_data)

# Save DataFrame to CSV
df.to_csv('output.csv', index=False)

print("JSON data has been successfully converted to output.csv")