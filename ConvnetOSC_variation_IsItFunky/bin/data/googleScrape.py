from bs4 import BeautifulSoup
import requests
import re
import urllib2
import os

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--search", help="search term")
args = parser.parse_args()

def get_soup(url,header):
  return BeautifulSoup(urllib2.urlopen(urllib2.Request(url,headers=header)))

image_type = "Action"
# you can change the query for the image  here  
query = args.search
print(query)
#query = "Banana Img"
query= query.split()
query='+'.join(query)
url=url="https://www.google.co.in/search?q="+query+"&source=lnms&tbm=isch"
print url
header = {'User-Agent': 'Mozilla/5.0'} 
soup = get_soup(url,header)

images = [a['src'] for a in soup.find_all("img", {"src": re.compile("gstatic.com")})]
#print images
for img in images:
  raw_img = urllib2.urlopen(img).read()
  #add the directory for your image here 
  #DIR="/Users/andreasrefsgaard/Desktop/GoogleImageScrape/"
  DIR="/Users/andreasrefsgaard/Documents/OpenFrameworks/of_v0.9.0_osx_release/apps/ml4a-ofx/apps/ConvnetOSC_variation_IsItFunky/bin/data/googleImages/"
  cntr = len([i for i in os.listdir(DIR) if image_type in i]) + 1
  print cntr
  f = open(DIR + image_type + "_"+ str(cntr)+".jpg", 'wb')
  f.write(raw_img)
  f.close()