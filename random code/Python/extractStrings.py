import json 

file_path = r"C:/GitHub/botDevJustinPope/working-docs/Story Notes/20250507_20250520_VisualizePackages1/16243/Surfaces_All.json"

try:
    with open(file_path, 'r') as file:
        data = json.load(file)
except json.JSONDecodeError as e:
    print(f"Error decoding JSON: {e}")
    data = {}

surfaces = set()
for item in data.get("responseObject", {}):
    surfaces.update(item.get("renderableSurfaceList", []))

distinct_surfaces = sorted(surfaces)

for surface in distinct_surfaces:
    print(surface)