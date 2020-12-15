#送信元
$destEmailAddress = "<From Address>";
$fromEmailAddress = "<To Address>";
$subject = "<Subject>"
$content = "<Content>"
$VaultName = "<key Value Name>"

#Key Value を作成しない場合、SendGrid の認証キーを設定します。
# $SENDGRID_API_KEY_TEXT = "<SendGrid App Key>"

# Log Analytics information
$WorkspaceID = "<Workspace Id>"
$Query = "<Quewry>"

# 実行アカウント認証
$Conn = Get-AutomationConnection -Name AzureRunAsConnection
Connect-AzAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint | Out-Null

#Key Value 取得 ※Key Value が不要の場合、以下 3 行はコメントアウト

$SENDGRID_API_KEY = (Get-AzKeyVaultSecret -VaultName $VaultName -Name "SendGridAPIKey").SecretValue
$SENDGRID_API_KEY_TEXT = [System.Net.NetworkCredential]::new("", $SENDGRID_API_KEY).Password

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer " + $SENDGRID_API_KEY_TEXT)
$headers.Add("Content-Type", "application/json")

# Getting log
$QueryResults = Invoke-AzOperationalInsightsQuery `
    -WorkspaceId $WorkspaceID `
    -Query $Query 

$content += $QueryResults.Results | out-string

$body = @{
    personalizations = @(
        @{
            to = @(
                @{
                    email = $destEmailAddress
                }
            )
        }
    )
    from             = @{
        email = $fromEmailAddress
    }
    subject          = $subject
    content          = @(
        @{
            type  = "text/plain"
            value = $content
        }
    )
}


$bodyJson = $body | ConvertTo-Json -Depth 4

$response = Invoke-RestMethod -Uri https://api.sendgrid.com/v3/mail/send -Method Post -Headers $headers -Body $bodyJson