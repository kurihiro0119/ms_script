# Azure に接続する
$connectionName = "AzureRunAsConnection"
try {
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName

    "Logging in to Azure..."
    Add-AzAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
}
catch {
    if (!$servicePrincipalConnection) {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    }
    else {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

# import module
Import-Module Az.OperationalInsights

# Workspace Id
$WorkspaceId = "<Workspace ID>"

# 検索クエリを定義する
$KustoQuery = @"
<カスタムクエリ>
"@

# クエリを実行する
$result = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceId -Query $KustoQuery
$result.Results | ConvertTo-Csv > C:\temp\result_query.csv

# Azure Storage context の作成
$StorageAccountName = "<ストレージアカウント名>"
$StorageAccountKey = "<ストレージアカウントキー>"
$storageAcct = New-AzStorageContext -StorageAccountName　$StorageAccountName -StorageAccountKey $StorageAccountKey

# Blob Storage へ upload する
$containerName = "<コンテナー名>"
$localFilePath = "C:\temp\result_query.csv"
$fileName = Get-Date -Format "yyyyMMddHHmmss"

Set-AzStorageBlobContent `
    -Context $storageAcct.Context `
    -Container $containerName `
    -File $localFilePath `
    -Blob "result_query_$filename.csv"  `
    -StandardBlobTier Archive
