import requests


def lambda_handler(event, context):
    req = requests.get("https://www.google.com/")
    try:
        req.raise_for_status()
        print("Request succeeded")
        return req.text
    except requests.RequestException as e:
        print("Request failed: %s", e)
