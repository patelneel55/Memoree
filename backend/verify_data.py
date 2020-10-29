#!/usr/bin/env python3

#################################################################
#   Verifies data integrity between local files and the GCloud  #
#   buckets                                                     #
#                                                               #
#   Ex: python3 verify_data.py                                  #
#################################################################

from sh import gsutil
import os
import json
from collections import Counter

metadata_file = "./uploaded_files.json"
gcloud_video_bucket = "gs://memoree_video_archive/"
gcloud_json_bucket = "gs://video_json_archive/"
prefix_path = "/mnt/e/Video Archive/"
print()

# Verify if all files have been uploaded between the metadata file and GCloud video bucket
print(f"Comparing files between metadata_file, {metadata_file}, and GCloud video bucket, {gcloud_video_bucket}\n")

with open(metadata_file) as json_file:
    metadata = json.load(json_file)
local_video_list = metadata["files"]
gs_video_list = [val[:-1] for val in gsutil("ls", "-r", os.path.join(gcloud_video_bucket, "**"), _iter=True)]

print("File Count:")
print("# of videos uploaded:", len(local_video_list))
print("# of videos in GCloud:", len(gs_video_list))
print()

if len(local_video_list) != len(set(local_video_list)): 
    print("Duplicates found. The following files have duplicate entries in the metadata file:")
    print("\n".join([entry for entry, count in Counter(local_video_list).items() if count > 1]))
    print()

    print("File Count if de-duplication is performed:")
    print("# of videos uploaded:", len(set(local_video_list)))
    print("# of videos in GCloud:", len(gs_video_list))
    print()

if len(set(gs_video_list)) != len(set(local_video_list)):
    gs_video_cut = [os.path.relpath(video, gcloud_video_bucket) for video in set(gs_video_list)]
    local_video_cut = [os.path.relpath(video, prefix_path) for video in set(local_video_list)]

    print("Files in GCloud but not in metadata file:")
    print("\n".join(list(set(gs_video_cut) - set(local_video_cut))))
    print()

    print("Files in metadata file but not in metadata file:")
    print("\n".join(list(set(local_video_cut) - set(gs_video_cut))))
    print()

# Verify if all files have been parsed between the GCloud video bucket and json bucket
print(f"Comparing files between GCloud video bucket, {gcloud_video_bucket}, and the json bucket, {gcloud_json_bucket}\n")

gs_json_list = [val[:-1] for val in gsutil("ls", "-r", os.path.join(gcloud_json_bucket, "**"), _iter=True)]

print("File Count:")
print("# of files in video bucket:", len(gs_video_list))
print("# of files in json bucket:", len(gs_json_list))
print()

if len(gs_video_list) != len(gs_json_list):
    gs_json_cut = [os.path.splitext(os.path.relpath(video, gcloud_json_bucket))[0] for video in set(gs_json_list)]
    gs_video_cut_ext = [os.path.splitext(video)[0] for video in gs_video_cut]
    print([entry for entry, count in Counter(gs_video_cut).items() if count > 1])
    
    print("Files in the video bucket but not in json bucket:")
    print("\n".join(list(set(gs_video_cut) - set(gs_json_cut))))
    print()

    print("Files in the json bucket but not in video bucket:")
    print("\n".join(list(set(gs_json_cut) - set(gs_video_cut))))
    print()