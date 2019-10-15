#!/usr/bin/env python3

import argparse
import json
import time
from html import unescape

import requests

parser = argparse.ArgumentParser()
parser.add_argument("user")
parser.add_argument("--before_utc", default=None)
args = parser.parse_args()

BASE_URL = "https://api.pushshift.io/reddit/comment/search/"
REDDIT_BASE = "https://reddit.com"
MESSAGE_SIZE = 500

SLEEP_BETWEEN_REQUESTS = 5


def get_author_comments(**kwargs):
    r = requests.get(BASE_URL, params=kwargs)
    data = r.json()
    return data['data']



def get_comments(args):
    """ Return a generator of comments. """
    before = args.before_utc
    while True:
        comments = get_author_comments(author=args.user, size=MESSAGE_SIZE, before=before, sort='desc', sort_type='created_utc')
        if not comments: break

        for comment in comments:
            yield comment
            before = comment['created_utc'] # This will keep track of your position for the next call in the while loop
            # Do stuff with each comment object
            # Example (print comment id, epoch time of comment and subreddit and score)


        time.sleep(SLEEP_BETWEEN_REQUESTS)


for comment in get_comments(args):
    body = comment.get('body', '')
    permalink = comment.get('permalink')
    if not (body and permalink):
        continue
    structured = {key: comment.get(key) for key in ['author', 'created_utc']}
    structured['url'] = REDDIT_BASE + permalink
    structured['reddit_markdown'] = unescape(body)
    print(json.dumps(structured))
