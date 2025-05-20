# this script is intended to extract specific elements from a json file
# from the json file, I want to extract sceneId, roomName and surface
# then with the extracted elements, I want to create a new CSV file


import json 
import csv

#defining Scene Object
class Scene:
    def __init__(self, sceneId, roomName, surfaces):
        self.scene_id = sceneId
        self.room_name = roomName
        self.surfaces = surfaces

    def __repr__(self):
        return f"Scene(scene_id={self.scene_id}, room_name={self.room_name}, surfaces={self.surfaces})"

file_path = r"C:/GitHub/botDevJustinPope/working-docs/Story Notes/20250507_20250520_VisualizePackages1/16243/Surfaces_All.json"

try:
    with open(file_path, 'r') as file:
        data = json.load(file)
except json.JSONDecodeError as e:
    print(f"Error decoding JSON: {e}")
    data = {}

scenes = []
for item in data.get("responseObject", []):
    scene_id = item.get("sceneId")
    room_name = item.get("roomName")
    surfaces = item.get("renderableSurfaceList", [])
    
    # Create a Scene object and add it to the list
    scene = Scene(scene_id, room_name, surfaces)
    scenes.append(scene)

# Print the list of Scene objects
for scene in scenes:
    print(scene)