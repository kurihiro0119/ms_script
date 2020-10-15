import requests
import json
import uuid
from time import sleep

tenant_id = "<Tenant Id>"
client_id = "<client Id>"
client_secret = "<client secret>"
subscription_id = "<subscription Id>"
resource_group = "<resource group>"
AutomaitonAccount = "<automation account>"
runbook_name = "<runbook name>"
run_on = "<Hybrid runbook worker machine>"

resource = "https://management.azure.com/"

# Login_URL
url = ("https://login.microsoftonline.com/%s/oauth2/token" % tenant_id)
payload = {'grant_type': 'client_credentials',
           'client_id': client_id,
           'client_secret': client_secret,
           'resource': resource}
files = []
headers = {
    "Content-Type": "application/x-www-form-urlencoded",
    "Keep-Alive": "true"
}

response = requests.request(
    "POST", url, headers=headers, data=payload, files=files).json()

job_name = "job_name" + str(uuid.uuid4())

# アクセストークン取得
oauth2 = response["access_token"]
url = ("https://management.azure.com/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Automation/automationAccounts/%s/jobs/%s?api-version=2017-05-15-preview" %
       (subscription_id, resource_group, AutomaitonAccount, job_name))

headers_request = {
    "Authorization": "Bearer " + oauth2,
    'Content-Type': 'application/json'
}

payload_request = ("{\"properties\": {\r\n    \"runbook\": {\r\n      \"name\": \"%s\"\r\n    },\r\n    \"parameters\": {\r\n      \"key01\": \"value01\",\r\n      \"key02\": \"value02\"\r\n    },\r\n    \"runOn\": \"%s\"\r\n }\r\n}" % (runbook_name, run_on))

re = requests.request("PUT", url, headers=headers_request,
                      data=payload_request)

if str(re) == "<Response [201]>":
    print("success job create")

status = "No Data"
count = 0
while status != "Completed":
    sleep(5)
    re_status = requests.request("GET", url, headers=headers_request)
    re_status_json = json.loads(re_status.text)
    status = str(re_status_json['properties']['status'])
    count = count + 1
    if count > 20:
        break
if count < 20:
    print("status: " + status)

else:
    print("status: failed")
