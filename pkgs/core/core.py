#!/usr/bin/python

import sys

from os.path import basename
from pandas import read_html
from tabulate import tabulate

CONFERENCE_URL = "http://portal.core.edu.au/conf-ranks/?by=all&sort=arank&search="
JOURNAL_URL = "http://portal.core.edu.au/jnl-ranks/?by=all&sort=arank&search="


def usage(program_name: str):
    sys.exit(f"Usage: {basename(program_name)} [j] <search-string>")


def err(msg: str):
    sys.exit(f"[!] {msg}")


def search(url: str, query: str):
    try:
        df = read_html(f"{url}{query}")[0]
    except Exception as e:
        err("query unsuccessful", e)

    try:  # conference columns
        result = df[["Rank", "Acronym", "Title"]]
    except:  # journal columns
        result = df[["Rank", "Title"]]

    print(tabulate(result, headers="keys", tablefmt="plain", showindex=False))


if __name__ == "__main__":
    if len(sys.argv) < 2:
        usage(sys.argv[0])

    if sys.argv[1] == "j":
        search_url = JOURNAL_URL
        query_start = 2
    else:
        search_url = CONFERENCE_URL
        query_start = 1

    if len(sys.argv) >= query_start:
        search(search_url, "+".join(sys.argv[query_start:]))
    else:
        usage(sys.argv[0])
