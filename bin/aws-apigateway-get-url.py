#!/usr/bin/env python

import argparse

import boto3

# for example:
# https://jvfiea6jub.execute-api.us-east-2.amazonaws.com/mocklive

SUBDOMAIN = 'execute-api'
SECOND_LEVEL_DOMAIN = "amazonaws"
EXT = "com"

session = boto3.session.Session()
default_region = session.region_name

DEFAULT_PROTOCOL = 'https'

parser = argparse.ArgumentParser(description="guess the urls given a rest endpoint")
parser.add_argument("name", help="name of the rest-api endpoint")
parser.add_argument("--region", default=default_region, help=f"region (default: {default_region})")
parser.add_argument("--protocol", default=DEFAULT_PROTOCOL, help=f"protocol (default: {DEFAULT_PROTOCOL})")
parser.add_argument("--profile", help="profile to use")
args = parser.parse_args()
print(args)

session = boto3.Session(**({'profile_name': args.profile} if args.profile else {}))
client = session.client('apigateway')

response = client.get_rest_apis()

name_to_result = {result.get('name'): result for result in response.get('items')}

api_endpoint = name_to_result[args.name]
api_id = api_endpoint['id']

response = client.get_stages(restApiId=api_id)
for stage in response['item']:
    stage_name = stage['stageName']
    domain_name = ".".join([api_id, SUBDOMAIN, args.region, SECOND_LEVEL_DOMAIN, EXT])
    url = f"{args.protocol}://{domain_name}/{stage_name}"
    print(url)
