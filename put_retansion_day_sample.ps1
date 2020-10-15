$tenantId = "<Tenant Id>"
$clientID = "<Client Id>"
$key = "<Secret Key>"
$subscriptionId = "<Subscription Id>"
$workspaceRgName = "<Resource Group>"
$workspacename = "<WorkSpace Name>"
$Table = "<Table Name>"
$day = <day>

$loginURL = "https://login.microsoftonline.com/$tenantId/oauth2/token"
$resource = "https://management.azure.com/"         
$body = @{grant_type = "client_credentials"; resource = $resource; client_id = $clientId; client_secret = $key }
$oauth = Invoke-RestMethod -Method Post -Uri $loginURL -Body $body
$headers = @{
    'Content-Type'  = 'application/json' 
    "Authorization" = "Bearer " + $oauth.access_token
} 

$method = "PUT"
$url = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$workspaceRgName/providers/Microsoft.OperationalInsights/workspaces/$workspacename/Tables/$Table" + "?api-version=2017-04-26-preview"
$json = "{
    `n    `"properties`": 
    `n    {
    `n        `"retentionInDays`": $day
    `n    }
    `n}"

$responseresult = Invoke-RestMethod $url -Method $method -Headers $headers -Body $json
$responseresult
