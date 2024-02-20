#!/usr/bin/env python

import argparse
import os

import firebase_admin
from firebase_admin import db

parser = argparse.ArgumentParser(
    description=str(
        "reads at one level of data from given top-level node "
        "and outputs data in yaml-ish format. "
        "Assumes data is in dict form."
    )
)
parser.add_argument("root_node", help="the root node you want to examine")
parser.add_argument("--id", help="an optional id for the node of interest")
args = parser.parse_args()


firebase_admin.initialize_app(options={"databaseURL": os.environ["FIREBASE_DB_URL"]})

indent = "  "

root_node = db.reference(args.root_node)


def print_node(root_node, id):
    print(f"{id}:")
    data = root_node.child(id).get()
    for key, val in data.items():
        print(f"{indent}{key}: {repr(val)}")


if args.id:
    print_node(root_node, args.id)

else:
    for id in root_node.get():
        print_node(root_node, id)
