#!/usr/bin/env python3
 
import os
import csv
import requests

output_dir = "var/cache/organisation-collection/dataset/"
URL = "https://files.planning.data.gov.uk/organisation-collection/dataset/"

os.makedirs(output_dir, exist_ok=True)

with open("specification/dataset.csv","r") as f:
    reader = csv.DictReader(f)
    for row in reader:
        if row["typology"] == "organisation" and row["end-date"] == "":
            csv_name = row["dataset"]+".csv"
            r = requests.get(URL+csv_name)
            if r.status_code == 200:
                with open(os.path.join(output_dir, csv_name), "wb") as t:
                    t.write(r.content)
