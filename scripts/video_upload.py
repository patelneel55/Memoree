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
import argparse

# Program argument parser
arg_parser = argparse.ArgumentParser(description='Bulk upload all video files under the provided path to GCloud buckets using gsutil.')
arg_parser.add_argument("input_path", help="Input path of all the video files.")
arg_parser.add_argument("gcp_bucket_path", help="GCloud URI of the target bucket.")
arg_parser.add_argument("--gb", "-d", help="Daily upload bandwidth limit in GB. Default: 5GB", default=5)
arg_parser.add_argument("--duration", "-m", help="Monthly duration limit of videos in min. Default: 950min", default=950)

args = arg_parser.parse_args();

# Path parameters
source_path = args.input_path
gcloud_bucket = args.gcp_bucket_path

# Constants
gb_limit = float(args.gb) # Daily bandwith limit in GB
duration_limit = float(args.duration) # Monthy video duration limit in mins
metadata_file = os.path.abspath(os.path.join(os.path.dirname(__file__), "uploaded_files.json"))

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
    
    secs_rem = (duration_limit * 60) - uploaded_json_data["total_duration"]
    bytes_rem = (gb_limit * 1024 * 1024 * 1024) - uploaded_json_data["total_size"] 

    def sizeof_fmt(num, suffix='B'):
        for unit in ['','Ki','Mi','Gi','Ti','Pi','Ei','Zi']:
            if abs(num) < 1024.0:
                return "%3.1f%s%s" % (num, unit, suffix)
            num /= 1024.0
        return "%.1f%s%s" % (num, 'Yi', suffix)
    print("Daily data quota remaining:", sizeof_fmt(bytes_rem))
    print("Monthly minute quota remaining:", str(datetime.timedelta(seconds=secs_rem)))
    print()

# Recursively get all video files from the provided source path
file_paths = find(source_path, "-type", "f", "-iregex", ".*\.\(mov\|mp4\|avi\|wmv\|mpeg\|vob\)", _iter=True)

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

        # TODO: Fix this, what should we do if ffprobe fails
        if "N/A" in str(file_duration):
            continue

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
