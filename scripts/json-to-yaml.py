import json
import yaml

with open('habits.json', 'r') as json_file:
    data = json.load(json_file)

with open('habits.yaml', 'w') as yaml_file:
    yaml.dump(data, yaml_file)

