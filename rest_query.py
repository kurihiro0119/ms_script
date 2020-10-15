import requests
import json

tenant_id = "<Tenant Id>"
client_id = "<client Id>"
client_secret = "<client secret>"
subscription_id = "<subscription Id>"
work_space_rg "<resource group>"
work_space_name = "<workspace name>"
resource = "https://management.azure.com/"
query = "Perf | limit 10"

# Login_URL
url = ("https://login.microsoftonline.com/%s/oauth2/token" % tenant_id)
payload = {'grant_type': 'client_credentials',
           'client_id': client_id,
           'client_secret': client_secret,
           'resource': resource}
files = [

]
headers = {
    "Content-Type": "application/x-www-form-urlencoded",
    "Keep-Alive": "true"
}

response = requests.request(
    "POST", url, headers=headers, data=payload, files=files).json()

# アクセストークン取得
oauth2 = response["access_token"]

url_query = ("https://management.azure.com/subscriptions/%s/resourceGroups/%s/providers/Microsoft.OperationalInsights/workspaces/%s/api/query?api-version=2017-01-01-preview" %
             (subscription_id, work_space_rg, work_space_name))

headers_query = {
    "Content-Type": "application/json",
    "Authorization": "Bearer " + oauth2,
}


payload_query = {
    "query": query
}

re = requests.post(url_query, headers=headers_query,
                   data=json.dumps(payload_query))

file = "output.json"
fileobj = open(file, "w", encoding="utf-8")
fileobj.write(re.text)
fileobj.close()
