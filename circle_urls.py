#!/usr/bin/env python

'''
circle_urls.py will rename all url files to not have extension .html
'''
import sys
import os
import re
from glob import glob

site_dir = os.path.abspath(sys.argv[1])
print("Using site directory %s" %(site_dir))

files = glob("%s/*.html" %(site_dir))
for html_file in files:
    if not html_file.endswith('index.html'):
        new_name = html_file.replace('.html','')
        print("Renaming %s to %s." %(html_file,new_name))
        os.rename(html_file, new_name)
