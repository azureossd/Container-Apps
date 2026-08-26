"""Call the localhost animal service and print one machine-readable response."""

from __future__ import annotations

import json
import sys
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


def main() -> int:
    if len(sys.argv) != 3:
        print(json.dumps({"error": "usage: request.py METHOD PATH"}))
        return 2

    method, path = sys.argv[1:]
    if method not in {"GET", "POST"} or not path.startswith("/"):
        print(json.dumps({"error": "invalid method or path"}))
        return 2

    request = Request(f"http://127.0.0.1:8080{path}", method=method)
    try:
        with urlopen(request, timeout=15) as response:
            body = json.loads(response.read().decode("utf-8"))
            print(json.dumps({"httpStatus": response.status, "body": body}, sort_keys=True))
            return 0
    except HTTPError as error:
        body = json.loads(error.read().decode("utf-8"))
        print(json.dumps({"httpStatus": error.code, "body": body}, sort_keys=True))
        return 0
    except URLError as error:
        print(json.dumps({"error": str(error.reason)}, sort_keys=True))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())