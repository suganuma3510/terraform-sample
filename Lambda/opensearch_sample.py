import json
from urllib import request
import base64
import codecs

def lambda_handler(event, context):
    endpoint = 'https://vpc-sample-opensearch-XXXXXXXXXX.ap-northeast-1.es.amazonaws.com'
    path = '/_search'
    user_pass = 'admin:passwprd'
    auth_header = b'Basic ' + base64.b64encode(codecs.encode(user_pass, 'ascii'))
    data = {
        'query': {
            'match_all': {}
          }
    }
    headers = {
        'Content-Type': 'application/json',
        'Authorization': auth_header
    }
    req = request.Request(endpoint + path, data=json.dumps(data).encode(), headers=headers, method='GET')
    with request.urlopen(req) as res:
        body = json.load(res)
        print(body)

    return {'statusCode': 200, 'body': body}