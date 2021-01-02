#!/env/python3

import sys
import sh

folder = sys.argv[1]
files = sh.ls("-1", folder, _iter=True)
weight_mapping = {
  'Thin': 100,
  'ExtraLight': 200,
  'Light': 300,
  'Medium': 500,
  'SemiBold': 600,
  'Bold': 700,
  'ExtraBold': 800,
  'Black': 900,
}

for file in files:
    file = str(file[:-1])
    print("- asset: fonts/" + folder + "/" + file)
    for key, value in weight_mapping.items():
        if key in file:
            print("  weight:", value)
            break
    if "Italic" in file:
        print("  style: italic")