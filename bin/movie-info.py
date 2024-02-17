#!/usr/bin/env python

# pip install --user tmdbsimple
import argparse
import os

import tmdbsimple as tmdb

APIKEY_FILE = os.path.join(os.getenv("HOME"), "Dropbox", "env", "tmdb", "APIKEY")

with open(APIKEY_FILE, "r") as infile:
    tmdb.API_KEY = infile.read()

print(tmdb.API_KEY)

parser = argparse.ArgumentParser()
parser.add_argument("-s", "--search", help="search for movie")
# parser.add_argument()
# parser.add_argument()
args = parser.parse_args()

search = tmdb.Search()
response = search.movie(query=args.search)
for movie in search.results:
    print(dir(movie))
    print(movie)

# import rtsimple as rt
# import argparse
# import os

##tmdb_api_file = os.path.join(os.getenv("HOME"), "Dropbox", "env", "tmdb", "APIKEY")
# rt_api_file = os.path.join(os.getenv("HOME"), "Dropbox", "env", "rotten_tomatoes", "APIKEY")

# with open(rt_api_file,'r') as infile:
# rt.API_KEY = infile.read()

##print(rt.API_KEY)

# parser = argparse.ArgumentParser()
# parser.add_argument("-s", "--search", help="search for movie")
##parser.add_argument()
##parser.add_argument()
# args = parser.parse_args()

# movie = rt.Movies()
# response = movie.search(q=args.search)
# for movie in movie.movies:
# print(dir(movie))
# print(movie)
