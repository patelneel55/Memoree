#!/usr/bin/env python3

#################################################################
#   Uploads all video files starting from the provided path to  #
#   GCloud buckets using gsutil                                 #
#                                                               #
#   Ex: python3 video_upload.py <input_path> <gcloud bucket>    #
#################################################################

from sh import ffprobe, find, gsutil, ErrorReturnCode
import sys
import os
import json
import datetime

# Program parameters
source_path = sys.argv[1]
gcloud_bucket = sys.argv[2]

# Constants
gb_limit = 3 # Daily bandwith limit in GB 
duration_limit = 950 # Monthy video duration limit in mins
metadata_file = "./uploaded_files.json"


with open(metadata_file) as json_file:
    try:
        uploaded_json_data = json.load(json_file)
    except Exception:
        uploaded_json_data = {
            "last_update": datetime.date.today().isoformat(),
            "last_month": datetime.datetime.today().month,
            "total_size": 0,
            "total_duration": 0,
            "files": [],
        }

    # Reset metadata values once day/month changes
    if uploaded_json_data["last_update"] != datetime.date.today().isoformat():
        uploaded_json_data["total_size"] = 0
        uploaded_json_data["last_update"] = datetime.date.today().isoformat()
    elif uploaded_json_data["total_size"] >= gb_limit * 1024 * 1024 * 1024:
        print()
        print("Daily bandwith quota exceeded.")
        sys.exit(1)
    
    if uploaded_json_data["last_month"] != datetime.datetime.today().month:
        uploaded_json_data["total_duration"] = 0
        uploaded_json_data["last_month"] = datetime.datetime.today().month
    elif uploaded_json_data["total_duration"] >= duration_limit * 60:
        print()
        print("Monthly duration quota exceeded.")
        sys.exit(1)
    
# Recursively get all video files from the provided source path
file_paths = find(source_path, "-type", "f", "-regex", ".*\.\(mov\|mp4\|avi\|wmv\|mpeg\|vob\)", _iter=True)

file_counter = 0
with open(metadata_file, 'a+') as json_file:
    for file in file_paths:
        file = file[:-1]
        
        # Don't parse data that is already uploaded
        if file in uploaded_json_data["files"]:
            continue

        # Get file metadata
        file_duration = ffprobe("-show_entries", "format=duration", "-of", "default=noprint_wrappers=1:nokey=1", file)
        file_size = os.path.getsize(file)

        if float(file_duration) + uploaded_json_data["total_duration"] > duration_limit * 60 or float(file_size) + uploaded_json_data["total_size"] > gb_limit * 1024 * 1024 * 1024:
            continue

        # Run gsutil to upload file to GCloud
        try:
            gsutil("cp", file, os.path.join(gcloud_bucket, os.path.relpath(file, source_path)))
            print(os.path.join(gcloud_bucket, os.path.relpath(file, source_path)))
        except ErrorReturnCode as exc:
            print("Error:", os.path.join(gcloud_bucket, os.path.relpath(file, source_path)))
            continue

        # Update metadata
        file_counter += 1
        uploaded_json_data["files"].append(file)
        uploaded_json_data["total_duration"] += float(file_duration)
        uploaded_json_data["total_size"] += float(file_size)

        # Rewrite metadata file 
        json_file.truncate(0)
        json.dump(uploaded_json_data, json_file, indent=4)

print()
print(f"{file_counter} files successfully uploaded.")
