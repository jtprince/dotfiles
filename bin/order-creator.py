#!/usr/bin/env python3

import json
import random
import string
from argparse import ArgumentDefaultsHelpFormatter, ArgumentParser
from os import environ

import requests
from faker import Faker


def random_str(size=16, possible=string.ascii_letters + string.digits):
    """ Returns a random string from the possible characters. """
    return "".join(random.choice(possible) for _ in range(size))


DEFAULT_TOKEN = environ.get("AUTH_TOKEN")
DEFAULT_THANOS_ENDPOINT = environ.get("THANOS_API", "http://localhost")

API_VERSION = "current"
SKUS_ENDPOINT = "products/skus/"
CREATE_ORDERS_ENDPOINT = "orders/create/"

parser = ArgumentParser(
    description="creates an order", formatter_class=ArgumentDefaultsHelpFormatter
)

group = parser.add_mutually_exclusive_group(required=True)
group.add_argument(
    "-n", "--number", type=int, help="the max number of skus to submit orders for"
)
group.add_argument("-s", "--sku_ids", nargs="+", help="list of sku_ids")


parser.add_argument("--no-reject-missing-cost", action='store_true', help="will not skip skus w/o cost")
parser.add_argument(
    "--auth-token",
    default=DEFAULT_TOKEN,
    metavar="AUTH_TOKEN",
    help="The authtoken (will try env $AUTH_TOKEN)",
)
parser.add_argument(
    "--thanos-api",
    default=DEFAULT_THANOS_ENDPOINT,
    help="Thanos endpoint (will try env $THANOS_API)",
)


class OrderCreator:
    SHIPPING_DEFAULTS = dict(
        retailer_provided_shipping_carrier="UPS",
        retailer_provided_shipping_method="Ground",
        retailer_line_item_instructions="Ship separately as available",
    )
    DEFAULT_PHONE = "801-555-1212"

    def _generate_address(self):
        fake = Faker()
        address = fake.address()
        address1, postal_line = address.split("\n")
        city, state, postal = postal_line.rsplit(" ", 2)
        return dict(
            name=fake.name(),
            address1=address1,
            city=city.strip(","),
            state=state.strip(","),
            postal_code=postal.strip(","),
            phone_number=self.DEFAULT_PHONE,
        )

    def __init__(self, options):
        self.options = options
        self.skus_endpoint = f"{options.thanos_api}/{API_VERSION}/{SKUS_ENDPOINT}"
        self.create_orders_endpoint = f"{options.thanos_api}/{API_VERSION}/{CREATE_ORDERS_ENDPOINT}"
        self.auth_token_headers = dict(Authorization=f"Token {options.auth_token}")

    def _request(self, *args, **kwargs):
        return requests.request(*args, headers=self.auth_token_headers, **kwargs)

    def _get_sku_data(self, sku):
        lowest_pricing = next(iter(sku["price_tiers"]), {})
        return dict(
            self.SHIPPING_DEFAULTS,
            retailer_provided_sku_cost=lowest_pricing.get("cost"),
            quantity=lowest_pricing.get("minimum_tier_quantity", 1),
            sku_id=sku["sku_id"],
            supplier_org_uuid=sku["supplier"]["uuid"],
        )

    def create_and_submit(self):
        order_data = self.create_order()
        response_data = self.submit_order(order_data)
        return dict(
            po_number=order_data["po_number"],
            **response_data
        )

    def create_order(self):
        response = self._request(
            "GET", url=self.skus_endpoint, params=dict(limit=self.options.number)
        )
        skus_data = response.json()
        if self.options.number:
            sku_data = [self._get_sku_data(sku) for sku in skus_data["skus"]]
        else:
            raise Exception("IMPLEMENT! for specific sku_ids")

        if not self.options.no_reject_missing_cost:
            sku_data = [sku for sku in sku_data if sku["retailer_provided_sku_cost"] is not None]

        return dict(
            address=self._generate_address(),
            skus=sku_data,
            po_number=f"PO-{random_str(10)}",
        )

    def submit_order(self, order_data):
        response = self._request("POST", json=order_data, url=self.create_orders_endpoint)
        return dict(
            response.json(),
            status_code=response.status_code,
        )


if __name__ == "__main__":
    args = parser.parse_args()
    order_creator = OrderCreator(options=args)
    return_data = order_creator.create_and_submit()
    print(json.dumps(return_data, indent=2))
