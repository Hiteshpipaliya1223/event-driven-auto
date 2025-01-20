import json

def lambda_handler(event, context):
    message = {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
    return message
