#!/usr/bin/env python2.7

import twitter

consumer_key = 'fdvUeRarf28C0oCIio6j6rHXf'
consumer_secret = 'LX6m7KCw3d2nNmd2DNUTdBZuTJx9rWGvzq03cAydhZBr5eFugs'
access_token_key = '2208367327-clHFxxYYdSTEhIW18OM2E1LMR4Jb6vhIrVdH0f7'
access_token_secret = 'zJ2aoLqidjdRCKebrqygfksMmzhcZtMIeJrafGXboMzBf'

api = twitter.Api(
    consumer_key=consumer_key, 
    consumer_secret=consumer_secret, 
    access_token_key=access_token_key,
    access_token_secret=access_token_secret
)

trends = api.GetTrendsCurrent()
print(trends[0])
