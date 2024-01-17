#!/usr/bin/env python3

import requests
import json
import subprocess
import re
import glob


def extract_packages(file_path):
    with open(file_path, 'r') as file:
        tex_content = file.read()
        package_names = re.findall(pattern, tex_content)
        return package_names


pattern = r'\\usepackage\{([^{}]+)\}'
url = "https://portalparts.acm.org/hippo/latex_templates/taps_accepted-packages.json"
user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.45 Safari/537.36"
tex_files = glob.glob('**/*.tex', recursive = True)


all_packages = []
for file_path in tex_files:
    packages = extract_packages(file_path)
    all_packages.extend(packages)


response = requests.get(url, headers = {'User-Agent' : user_agent} )
approved_packages = response.json()

unapproved_packages = set(all_packages) - set(approved_packages)

# Printing the unapproved packages
print('\n'.join(unapproved_packages))
