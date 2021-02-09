#!/env/bin/python3

#################################################################
#   Use the secrets.json file to setup API configurations       #
#   for frontend and backend services                           #
#                                                               #
#   Ex: python3 video_upload.py <secret_file>                   #
#################################################################

from sh import firebase
import json
import os
import argparse

# Program argument parser
arg_parser = argparse.ArgumentParser(description='Configure secrets for API services by loading into SDK and moving to their respective locations.')
arg_parser.add_argument("secret_file", help="Path to json file with application secrets")
arg_parser.add_argument("project_id", help="Firebase project id")
args = arg_parser.parse_args()

# Path parameters
secret_file = args.secret_file
firebase_project_id = args.project_id

with open(secret_file) as file:
    json_secrets = json.load(file)

# # Backend configuration
print("Configuring backend services...\n")

def flattenTree(tree):
    flatten_vals = []
    for key, value in tree.items():
        if isinstance(value, dict):
            children = flattenTree(value)
            for child in children:
                flatten_vals.append(key + "." + child)
        else:
            flatten_vals.append (key + "=" + value)
    return flatten_vals

backend_secrets = json_secrets["backend"]
backend_secrets = flattenTree(backend_secrets)
for i in range(len(backend_secrets)):
    backend_secrets[i] = "memoree." + backend_secrets[i]

print("Found properties:")
for secret in backend_secrets:
    print("\t▷ " + secret)
print()

backend_output = firebase("--project", firebase_project_id, "functions:config:set", backend_secrets)

# Frontend configuration
print("Configuring frontend services...\n")

frontend_secrets = json_secrets["frontend"]

print("Found properties:")
for secret in flattenTree(frontend_secrets):
    print("\t▷ " + secret)
print()

target_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "frontend/memoree_client/web/secrets.js")
with open(target_path, 'w') as f:
    f.write("let secrets = " + json.dumps(frontend_secrets, indent=4))

print("Done.")
