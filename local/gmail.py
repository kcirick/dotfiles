#!/usr/bin/python

import urllib.request
from xml.dom.minidom import parseString

# Enter your username and password below within double quotes
username="username"
password="password"

auth_handler = urllib.request.HTTPBasicAuthHandler()
auth_handler.add_password(realm='New mail feed',
								 uri='https://mail.google.com/',
								 user=username,
								 passwd=password)
opener = urllib.request.build_opener(auth_handler)
urllib.request.install_opener(opener)
msg = urllib.request.urlopen('https://mail.google.com/mail/feed/atom')

atom = parseString(msg.read())
num_email = atom.getElementsByTagName("fullcount")[0].childNodes[0].data

print(str(num_email)+" new")
