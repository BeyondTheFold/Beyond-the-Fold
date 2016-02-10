#!/usr/bin/env python2.7

import sys
from instagram import InstagramAPI, InstagramClientError

access_token = '1385549703.e396c17.4b84386ced484fa18bb1d3b0ff94686e'
client_id = "e396c177fc424d24bdd0c0a3c7539c79"
client_secret = "e2339ecc858d49478a9d6b8b1e873b3a"
redirect_uri = 'http://www.drewgun.com'
scope = ['basic', 'public_content']

api = InstagramAPI(client_id=client_id, client_secret=client_secret, redirect_uri=redirect_uri)
auth_url = api.get_authorize_login_url(scope=scope)

if len(sys.argv) > 1:
    if sys.argv[1] == '--get-access-token':
        print ("Visit this page and authorize access in your browser: \n"+ auth_url)
        code = (str(input("Paste in code in query string after redirect: ").strip()))
        access_token = api.exchange_code_for_access_token(code)
        print(access_token[0])
    else:
        print('Options      --get-access-token')

try:
    recent_media = api.media_popular(count=10)
except InstagramClientError as error:
    print(error)

'''
for media in recent_media:
    print(media.caption.text)
'''
