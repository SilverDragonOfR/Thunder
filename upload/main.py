import pyrebase
import sys
import os

firebase_config = {
    # Add config
}

firebase = pyrebase.initialize_app(firebase_config)
storage = firebase.storage()

path_on_local = input("Full image-path: ")
path_on_cloud = os.path.basename(path_on_local)

print(path_on_local)
print(path_on_cloud)

storage.child(path_on_cloud).put(path_on_local)