import os
import sys
from bs4 import BeautifulSoup

folder_path = sys.argv[1]

for root, dirs, files in os.walk(folder_path):

  for filename in files:
    # Check for .html file
    if filename.endswith('.html') or filename.endswith('.htm') :

      file_path = os.path.join(root, filename)
      
      # Open and process file
      with open(file_path) as file:
        soup = BeautifulSoup(file, 'html.parser')
        soup.decode()

      # Overwrite with decoded HTML
      with open(file_path, 'w') as file:
        file.write(str(soup))

print('Done!')